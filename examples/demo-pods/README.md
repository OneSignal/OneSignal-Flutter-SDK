# OneSignal Flutter SDK Demo

A demo app showcasing all OneSignal Flutter SDK features including push notifications, in-app messaging, user management, tags, triggers, outcomes, and more.

## Prerequisites

- Flutter with Dart 3.7+
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
flutter run -d <device_id>
```

The `../run-android.sh` and `../run-ios.sh` helper scripts launch `examples/demo`, not this app.

To test the bundled iOS notification action icons, follow
[Testing iOS Action Button Icons](../ios-action-button-icons.md).

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

The `.env` file must exist before the first build because Flutter bundles it as an app asset. If `ONESIGNAL_APP_ID` is empty, the app falls back to a built-in default App ID.

## Build Guide

See [../build.md](../build.md) for the full set of prompts and requirements used to build this app.
