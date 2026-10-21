# TetherCam (working name) — iPhone as a USB camera for OBS on Windows

Open-source, free alternative to Camo-style apps. The iPhone streams its camera to OBS Studio on a Windows PC **over the USB cable only**. Anyone should be able to fork this repo, build it for free, and install it on their own iPhone.

## Hard constraints (never break these)

- **USB only.** The camera stream must never travel over Wi-Fi or any network. The iPhone server binds to `127.0.0.1` only, which is reachable via the USB tunnel but not from the network.
- **€0 to build and use.** No paid tools, no paid Apple Developer account, no paid libraries.
- **No Mac.** Development happens on Windows 11 in VS Code. iOS builds run on GitHub Actions macOS runners (Apple hardware), never locally.
- **Stay within Apple's terms.** Do not suggest xtool, Theos, or anything that puts Xcode or the iOS SDK on non-Apple hardware.
- **Clean-room.** Use only public Apple APIs and open-source libraries with permissive licences. Never decompile or copy code from Camo, Iriun, EpocCam, DroidCam, or any other closed-source app.
- **Minimum iOS 16.** The primary test device is an iPhone 8 Plus, which tops out at iOS 16.
- **Video only.** Audio is handled by the PC's own mic, so do not capture or stream audio.
- **No telemetry, accounts, ads or analytics.**
- **Licence:** MIT.

## Architecture

```
iPhone app                              USB cable                 Windows PC
-----------                             ---------                 ----------
AVCaptureSession (camera)
  -> VideoToolbox H.264 encoder
  -> MPEG-TS muxer (pure Swift)
  -> TCP server on 127.0.0.1:5000  ==== usbmux tunnel ====>  localhost:5000
                                       (iproxy or go-ios)          -> OBS Media Source
                                                                      tcp://127.0.0.1:5000
                                                                      input format: mpegts
```

### iOS app
- AVFoundation capture with the back wide camera by default, plus a lens switch (wide/tele on dual-camera iPhones).
- VideoToolbox `VTCompressionSession` tuned for low latency:
  - real-time mode on
  - frame reordering off (no B-frames)
  - keyframe interval of 1–2 s
  - selectable bitrate presets
- MPEG-TS muxing:
  - converts H.264 to Annex-B
  - writes PAT/PMT/PES with correct 90 kHz PTS/DTS taken from the sample buffer timestamps
  - lives in a **separate pure-Swift package (`TSMuxer`) with unit tests**, so it can be tested in CI without a device
- TCP listener (Network.framework) bound to `127.0.0.1`. It serves one client at a time, and a new connection replaces the old one. It must survive the client disconnecting and reconnecting (OBS restarting the source).
- Keep the screen awake with `isIdleTimerDisabled`. The app must stay in the foreground because iOS suspends the camera in the background; show this clearly in the UI.
- Thermal handling: watch `ProcessInfo.thermalState` and step down from 60 fps to 30 fps, or lower the bitrate, when it hits `.serious`.
- Check whether a Local Network permission prompt is triggered. It shouldn't be for loopback-only connections; confirm this and document the result.

### Windows side
- Prerequisite: Apple's USB driver, from the Apple Devices app (Microsoft Store) or iTunes.
- Tunnel tool: evaluate **go-ios** (single exe, `forward`) against **libimobiledevice `iproxy`**, then pick one and document why. Provide `windows/start-tunnel.ps1` that checks the device is connected, starts the forward on port 5000, and prints clear errors.
- OBS: no plugin in Phase 1. Document the exact Media Source settings (uncheck "Local File", input `tcp://127.0.0.1:5000`, input format `mpegts`, lowest network buffering, reconnect behaviour).

## Repo layout

```
/CLAUDE.md                   this file
/README.md                   what it is, screenshots, quick start for non-developers
/LICENSE                     MIT
/ios/project.yml             XcodeGen spec (do NOT commit a hand-edited .xcodeproj)
/ios/TetherCam/              app sources (SwiftUI + AVFoundation + VideoToolbox)
/ios/TSMuxer/                Swift package with the MPEG-TS muxer + unit tests
/windows/start-tunnel.ps1    USB tunnel helper
/docs/SETUP.md               end-to-end setup for a new user
/docs/OBS.md                 OBS Media Source settings + troubleshooting
/docs/SIDELOADING.md         installing the unsigned IPA with your own free Apple ID
/.github/workflows/ios.yml   CI build
```

## CI (GitHub Actions)

- Runner: `macos-latest`, which is free for public repos.
- Steps:
  1. install XcodeGen
  2. generate the project
  3. run the `TSMuxer` tests
  4. `xcodebuild` with `CODE_SIGNING_ALLOWED=NO`
  5. package `Payload/TetherCam.app` into an **unsigned `.ipa`**
  6. upload it as a build artifact
- On a git tag `v*`: attach the IPA to a GitHub Release.
- Users sign the IPA themselves with their own free Apple ID via AltStore or SideStore. **Never put signing certificates, Apple IDs or secrets in the repo or workflow.**

## How to work in this repo (instructions for Claude Code)

- You are running on **Windows** and cannot build iOS code locally. The loop is: edit → commit → push → watch CI with `gh run watch` → read failures with `gh run view --log-failed` → fix.
- Keep pure logic (muxing, timestamp maths, settings) in testable Swift packages so CI catches bugs before they reach a device.
- For on-device debugging, log with `os_log` under subsystem `app.tethercam`, and tell the user how to read logs over USB from Windows (e.g. `idevicesyslog` or the go-ios equivalent).
- Before any step that needs the user to do something physical (install a driver, plug in the phone, sideload, change an OBS setting), stop and give short numbered instructions.
- Ask before adding any third-party dependency. Prefer Apple frameworks and small in-house code.
- Small, focused commits with clear messages. Keep the README accurate as features land.
- If a requirement conflicts with the hard constraints above, stop and flag it rather than working around it.

## Milestones (each one must work on a real device before moving on)

1. **M0 – Scaffold + CI:** repo structure, XcodeGen project, a minimal SwiftUI app with a camera permission prompt, and CI producing an unsigned IPA. *Done when* the user can sideload it and the app opens.
2. **M1 – Camera preview:** live back-camera preview at 1080p30 on the phone.
3. **M2 – Encode + serve:** H.264 encoding and a loopback TCP server. *Done when* `ffplay` on Windows shows the feed through the USB tunnel (raw H.264 is fine at this stage).
4. **M3 – MPEG-TS + OBS:** a TSMuxer with tests. *Done when* OBS Media Source shows a stable 1080p30 feed for 60+ minutes with no drift, and recovers after the cable is unplugged and replugged.
5. **M4 – Controls + reliability:** 1080p60 option, lens switch, tap to focus/expose, exposure/focus/white-balance lock, mirror toggle, bitrate presets, an on-screen status overlay (client connected, fps, bitrate, thermal state), a dim-screen mode, and thermal step-down. Settings persist.
6. **M5 – Release:** finish `docs/` for non-developers, add a screenshot in the README, and publish a tagged release with the IPA.

### Phase 2 (only after M5)
- A native OBS plugin (C++, built on GitHub Actions Windows runners) that talks to the phone over usbmux directly. This removes the tunnel script and lets the app expose camera controls inside OBS.
- Manual ISO/shutter, zoom, saved presets.
