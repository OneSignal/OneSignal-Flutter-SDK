# OneSignal Flutter SDK Demo

A demo app showcasing all OneSignal Flutter SDK features including push notifications, in-app messaging, user management, tags, triggers, outcomes, and more.

## Prerequisites

- Flutter 3.7+
- Android emulator or iOS simulator (or a physical device)
- For iOS: Xcode with a valid signing configuration

## Setup

```bash
flutter pub get
```

For iOS, install CocoaPods dependencies:

```bash
cd ios && pod install && cd ..
```

## Run

```bash
flutter run
```

For Android with multiple emulators, use the helper script to pick by AVD name:

```bash
../run-android.sh
```

For iOS with multiple simulators:

```bash
../run-ios.sh
```

Or specify a device directly:

```bash
flutter run -d <device_id>
```

## Configuration

Copy the example environment file and fill in your values:

```bash
cp .env.example .env
```

Set your OneSignal credentials in `.env`:

```
ONESIGNAL_APP_ID=your-onesignal-app-id
ONESIGNAL_API_KEY=your-onesignal-api-key
```

If no `.env` is provided, the app falls back to a built-in default App ID.

## Build Guide

See [../build.md](../build.md) for the full set of prompts and requirements used to build this app.
