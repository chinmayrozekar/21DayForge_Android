# 21DayForge (Android)

A Flutter-based Android application for building productive habits through a 21-day challenge.

## Download

Get the latest APK from the [Releases](https://github.com/chinmayrozekar/21DayForge_Android/releases) page.

### Install the APK

1. Download the latest `21DayForge.apk` from Releases
2. On your Android device, enable **Install from unknown sources** (Settings → Security → Unknown sources)
3. Open the downloaded APK and tap **Install**
4. Launch **21DayForge** from your app drawer

> **Note:** This app is not distributed through the Google Play Store. You must install it manually (sideloading).

## Build from Source

If you prefer to build the APK yourself:

1. Install [Flutter](https://docs.flutter.dev/get-started/install)
2. Clone this repository:
   ```bash
   git clone git@github.com:chinmayrozekar/21DayForge_Android.git
   cd 21DayForge_Android
   ```
3. Build the release APK:
   ```bash
   flutter build apk --release
   ```
4. Find the APK at `build/app/outputs/flutter-apk/app-release.apk`

## Features

- 21-day habit challenge tracking
- Local data storage (no account required)
- Daily notifications to stay on track
- Profile customization

## Tech Stack

- **Framework:** Flutter
- **State Management:** Riverpod
- **Local Storage:** Hive
- **Notifications:** flutter_local_notifications

## License

This project is available for free personal use.
