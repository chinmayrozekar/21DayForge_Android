# 21DayForge (Android)

A free, no-nonsense Android app for building productive habits through a 21-day challenge.

## Motivation

### Why 21 Days?

Psychological research suggests that it takes approximately 21 days to form a new habit. Yet, most habit trackers and challenge-monitoring apps lock this simple concept behind expensive paywalls.

Something as fundamental as building good habits should not require a monthly subscription. You shouldn't have to pay to become a better version of yourself.

### A Service, Not a Product

This app was built with a simple belief: **a tool that helps people grow should be free and accessible to everyone**. No ads. No subscriptions. No data harvesting. Just a clean, focused experience that helps you build lasting habits — one day at a time.

### Inspired by the Bhagavad Gita

The philosophy behind 21DayForge draws from the Bhagavad Gita, which teaches that self-discipline, consistency, and detachment from results are the pillars of personal growth. As Krishna says:

> *"योगः कर्मसु कौशलम्"* — Excellence in action is Yoga.

This app embodies that principle — showing up every day, putting in the work, and trusting the process.

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
