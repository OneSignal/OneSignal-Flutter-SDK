# OneSignal Flutter SDK Demo

A demo app showcasing all OneSignal Flutter SDK features including push notifications, in-app messaging, user management, tags, triggers, outcomes, live activities, and more. It uses the in-repo SDK via a path dependency and Swift Package Manager for iOS.

## Prerequisites

- Flutter with Dart 3.7+
- Android emulator or iOS simulator (or a physical device)
- For iOS: Xcode with a valid signing configuration

## Setup

Create a `.env` file. It must exist before the first build because Flutter bundles it as an app asset:

```bash
cp .env.example .env
```

Set your OneSignal credentials in `.env`:

```
ONESIGNAL_APP_ID=your-onesignal-app-id
ONESIGNAL_API_KEY=your-onesignal-api-key
ONESIGNAL_ANDROID_CHANNEL_ID=
```

- `ONESIGNAL_APP_ID`: falls back to a built-in default App ID when empty.
- `ONESIGNAL_API_KEY`: REST API key, used by the in-app buttons that send notifications and update or end live activities.
- `ONESIGNAL_ANDROID_CHANNEL_ID`: optional Android notification channel for the sound test notification.

The OneSignal app needs FCM credentials for Android and APNs credentials for the `com.onesignal.example` bundle ID on iOS.

Then fetch dependencies:

```bash
flutter pub get
```

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
- [`demo-fm`](../demo-fm): OneSignal alongside Firebase Messaging

## Build Guide

See [../build.md](../build.md) for the full set of prompts and requirements used to build this app, and [../build-ios.md](../build-ios.md) for the iOS push and live activity setup.
