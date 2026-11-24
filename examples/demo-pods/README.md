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

The demo runs on the shared OneSignal demo app (`1154c350-e715-4b71-a58b-1b84b6745baa`) without any setup. To use your own credentials, copy the example file to `env/.env` (gitignored):

```bash
cp .env.example env/.env
```

Then set your values in `env/.env`:

```
ONESIGNAL_APP_ID=your-onesignal-app-id
ONESIGNAL_API_KEY=your-onesignal-api-key
```

An empty `ONESIGNAL_APP_ID` falls back to the shared demo app. Older checkouts kept `.env` in the demo root; move it to `env/.env`, since the root file is no longer read.

The OneSignal app needs FCM credentials for the `com.onesignal.example` Android package and APNs credentials for the `com.onesignal.example` bundle ID on iOS. On Android, build with `-PDEMO_BUNDLE_ID=<package>` to use a different package.

iOS builds use bundle ID `com.onesignal.example` and team `99SW8E36CT` by default, set in `ios/demo.xcconfig`. To sign with your own team, copy `ios/local.xcconfig.example` to `ios/local.xcconfig` (gitignored) and set `DEMO_BUNDLE_ID` and `DEMO_TEAM_ID`. The NSE, widget and app group IDs derive from `DEMO_BUNDLE_ID`.

## Build Guide

See [../build.md](../build.md) for the full set of prompts and requirements used to build this app.
