# TetherCam

Use your iPhone as a USB camera in OBS on Windows. Free and open source (MIT).

- **USB only:** the video never travels over Wi-Fi or the network.
- **Free:** no paid Apple Developer account, no Mac needed. You install the app with your own free Apple ID.
- **Private:** no accounts, ads, analytics or telemetry.
- Works on iOS 16 and later.

## Status

Early development, milestone **M0**: the app installs and asks for camera access, but does not stream yet. See [CLAUDE.md](CLAUDE.md) for the roadmap.

## Install

Download the latest unsigned IPA and follow [docs/SIDELOADING.md](docs/SIDELOADING.md).

## Building

You don't need a Mac. GitHub Actions builds the app on every pull request and push to `main` (see [.github/workflows/ios.yml](.github/workflows/ios.yml)) and uploads `TetherCam-unsigned.ipa` as a build artifact. Tagging `v*` attaches it to a GitHub Release.

The Xcode project is generated from [ios/project.yml](ios/project.yml) with [XcodeGen](https://github.com/yonaskolb/XcodeGen); the MPEG-TS code lives in the [ios/TSMuxer](ios/TSMuxer) Swift package with its own tests.
