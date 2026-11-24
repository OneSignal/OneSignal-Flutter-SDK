# OneSignal No-Location Demo

Minimal Flutter app for verifying OneSignal push without linking the native
location module.

## Why This Exists

Some apps use OneSignal for push notifications and in-app messages but do not use
`OneSignal.Location`. Linking the native location module can still make app
stores detect location APIs. On iOS, that can lead to App Store Connect warnings
such as `ITMS-90683` and may require location usage descriptions that the app
does not actually need.

This demo proves the no-location configuration works in a small app:

- push initialization and notification permission requests still work
- the native location module is excluded from the build
- iOS does not need `NSLocationWhenInUseUsageDescription` or
  `NSLocationAlwaysAndWhenInUseUsageDescription`
- Android does not request fine or coarse location permissions

## Setup

The demo runs on the shared OneSignal demo app (`1154c350-e715-4b71-a58b-1b84b6745baa`) without any setup. To use your own app, copy `.env.example` to `env/.env` (gitignored) and set `ONESIGNAL_APP_ID`:

```sh
cp .env.example env/.env
```

Older checkouts kept `.env` in the demo root; move it to `env/.env`, since the root file is no longer read.

## iOS

Run with the helper script so Flutter resolves native dependencies with
`ONESIGNAL_DISABLE_LOCATION=true`:

```sh
./run.sh -d ios
```

The app does not include `NSLocationWhenInUseUsageDescription` or
`NSLocationAlwaysAndWhenInUseUsageDescription`.

The iOS project includes a `OneSignalNotificationServiceExtension` and a
`OneSignalWidgetExtension` using Swift Package Manager. On iOS 16.2 or newer,
use the app's **Start Live Activity** button to launch the sample widget.

To test the bundled notification action icons, follow
[Testing iOS Action Button Icons](../ios-action-button-icons.md).

## Android

Run with the same helper script:

```sh
./run.sh -d android
```

The Android manifest does not request fine or coarse location permissions.
