# OneSignal No-Location CocoaPods Demo

Minimal Flutter app for verifying OneSignal push without linking the native
location module. This variant uses CocoaPods for iOS dependencies.

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

The helper script installs the CocoaPods dependencies before launching the app.
The app does not include `NSLocationWhenInUseUsageDescription` or
`NSLocationAlwaysAndWhenInUseUsageDescription`.

The iOS project includes `OneSignalNotificationServiceExtension` and
`OneSignalWidgetExtension` targets like the main demo. On iOS 16.2 or newer, use
the app's **Start Live Activity** button to launch the sample widget.

Both extension targets declare `OneSignalXCFramework/OneSignal` and
`OneSignalXCFramework/OneSignalInAppMessages`, matching what the Flutter plugin
resolves when location is disabled. CocoaPods only builds one
`OneSignalXCFramework` when every target requests the same subspec set;
mismatched sets produce duplicate framework outputs and the build error reported
in [GitHub issue #1173](https://github.com/OneSignal/OneSignal-Flutter-SDK/issues/1173).

To test the bundled notification action icons, follow
[Testing iOS Action Button Icons](../ios-action-button-icons.md).

## Android

Run with the same helper script:

```sh
./run.sh -d android
```

The Android manifest does not request fine or coarse location permissions.
