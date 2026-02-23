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

Or specify a device directly:

```bash
flutter run -d <device_id>
```

## Configuration

The app uses a default OneSignal App ID for testing. To use your own, update the `oneSignalAppId` constant in `lib/main.dart`.

## Build Guide

See [../build.md](../build.md) for the full set of prompts and requirements used to build this app.
