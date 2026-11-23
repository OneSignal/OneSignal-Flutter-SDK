# OneSignal Flutter SDK Demo

A demo app showcasing all OneSignal Flutter SDK features including push notifications, in-app messaging, user management, tags, triggers, outcomes, live activities, and more. It uses the in-repo SDK via a path dependency and Swift Package Manager for iOS.

## Prerequisites

- Flutter with Dart 3.7+
- Android emulator or iOS simulator (or a physical device)
- For iOS: Xcode with a valid signing configuration

## Setup

The demo runs on the shared OneSignal demo app (`1154c350-e715-4b71-a58b-1b84b6745baa`) without any setup. To use your own credentials, create `env/.env` (gitignored; Flutter bundles the `env/` folder as an app asset):

```bash
cp .env.example env/.env
```

Then set your values in `env/.env`:

```
ONESIGNAL_APP_ID=your-onesignal-app-id
ONESIGNAL_API_KEY=your-onesignal-api-key
ONESIGNAL_ANDROID_CHANNEL_ID=
```

- `ONESIGNAL_APP_ID`: optional. Defaults to the shared demo app.
- `ONESIGNAL_API_KEY`: REST API key, used to update and end live activities. Sending notifications from the demo doesn't need it.
- `ONESIGNAL_ANDROID_CHANNEL_ID`: optional Android notification channel for the sound test notification. Falls back to a built-in default channel.

Older checkouts kept `.env` in the demo root; move it to `env/.env`, since the root file is no longer read.

The OneSignal app needs FCM credentials for the `com.onesignal.example` Android package and APNs credentials for the `com.onesignal.example` bundle ID on iOS. On Android, build with `-PDEMO_BUNDLE_ID=<package>` to use a different package.

iOS builds use bundle ID `com.onesignal.example` and team `99SW8E36CT` by default, set in `ios/demo.xcconfig`. To sign with your own team, copy `ios/local.xcconfig.example` to `ios/local.xcconfig` (gitignored) and set `DEMO_BUNDLE_ID` and `DEMO_TEAM_ID`. The NSE, widget and app group IDs derive from `DEMO_BUNDLE_ID`. E2E builds write `ios/e2e.xcconfig` (gitignored) with `DEMO_BUNDLE_ID = com.onesignal.sdkdemo` and `DEMO_TEAM_ID = DL8TF3X4K3`, and pass `-PDEMO_BUNDLE_ID=com.onesignal.sdkdemo` to Gradle.

Then fetch dependencies:

```bash
flutter pub get
```

### Firebase Installation IDs (optional)

E2E builds register with Firebase Installation IDs. To match locally, put a `google-services.json` for your package in `android/app/` (it is gitignored) and build with:

```bash
flutter build apk -PFIREBASE_INSTALLATION_ID_ENABLED=true
```

The flag is off by default, and the build fails if it is on without `google-services.json`.

## Run

```bash
flutter run -d <device_id>
```

Or use a helper script, which picks from running Android emulators or booted iOS simulators:

```bash
../run-android.sh
../run-ios.sh
```

To test the bundled iOS notification action icons, follow
[Testing iOS Action Button Icons](../ios-action-button-icons.md).

## Other demos

- [`demo-pods`](../demo-pods): same app using CocoaPods for iOS
- [`demo-no-location`](../demo-no-location) and [`demo-no-location-pods`](../demo-no-location-pods): minimal apps without the native location module
- [`flutter-local-notif`](../flutter-local-notif): OneSignal alongside `flutter_local_notifications`

## Build Guide

See [../build.md](../build.md) for the full set of prompts and requirements used to build this app, and [../build-ios.md](../build-ios.md) for the iOS push and live activity setup.
