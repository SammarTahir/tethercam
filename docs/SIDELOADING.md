# Installing TetherCam on your iPhone (free Apple ID)

TetherCam ships as an **unsigned** `.ipa`. You sign it yourself with your own free Apple ID, so no paid developer account is needed and nobody else's certificate is involved.

## Things to know first

- With a free Apple ID an installed app **expires after 7 days**. Re-install (or refresh) it to keep using it; your settings are kept.
- A free Apple ID can have at most **3 sideloaded apps** active at once, and register up to **10 app IDs per week**.
- Consider using a secondary Apple ID: the signing tool needs to sign in with it.

## 1. Get the IPA

- **Release:** download `TetherCam-unsigned.ipa` from the [Releases page](https://github.com/SammarTahir/tethercam/releases).
- **Latest build:** open the [Actions tab](https://github.com/SammarTahir/tethercam/actions), pick the newest green **iOS** run, and download the `TetherCam-unsigned-ipa` artifact (you must be signed in to GitHub). It arrives as a `.zip`; extract it to get the `.ipa`.

## 2. Install Apple's software on Windows

AltServer needs the versions of iTunes and iCloud **downloaded from apple.com**, not the Microsoft Store versions. If you have the Store versions installed, uninstall them first.

1. Install iTunes: <https://www.apple.com/itunes/download/win64>
2. Install iCloud for Windows from Apple's website, and sign in.
3. Install AltServer for Windows from <https://altstore.io>.

## 3. Pair your iPhone

1. Connect the iPhone with a USB cable and unlock it.
2. Tap **Trust** on the phone and enter your passcode.
3. Open iTunes once and check the phone shows up.

## 4. Sideload TetherCam with AltServer

1. Start **AltServer** (right-click → *Run as administrator* if it can't find your device). It appears in the system tray.
2. Hold **Shift** and click the AltServer tray icon, then choose **Install AltStore → *your iPhone***. Holding Shift makes AltServer ask for an `.ipa` instead of installing AltStore.
3. Pick `TetherCam-unsigned.ipa` and sign in with your Apple ID when asked.
4. Wait for the "Installation succeeded" notification.

## 5. First launch on the iPhone

1. **Settings → General → VPN & Device Management**: tap your Apple ID under *Developer App* and tap **Trust**.
2. **Settings → Privacy & Security → Developer Mode**: turn it on, let the phone restart, and confirm **Turn On** after it boots. (This setting only appears after a developer-signed app is installed.)
3. Open TetherCam and allow camera access.

## Refreshing every 7 days

Repeat step 4 with the same IPA, or install the AltStore app itself (step 4 without holding Shift) and use it to refresh TetherCam while AltServer is running on the same Wi-Fi network.

## Alternative: SideStore

[SideStore](https://sidestore.io) can refresh apps on the phone without a PC, after a one-time setup from Windows with [iloader](https://github.com/nab138/iloader). It needs a VPN app (LocalDevVPN) turned on whenever it refreshes. Either tool works with the same IPA.

## Troubleshooting

- **"Could not find AltServer" / device not listed:** restart the *Apple Mobile Device Service* in Windows Services, unplug and replug the phone, and run AltServer as administrator.
- **"Untrusted Developer" when opening the app:** do step 5.1.
- **App won't open after a week:** it expired. Re-sign it (step 4).
