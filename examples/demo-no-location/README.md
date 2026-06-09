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

Copy `.env.example` to `.env` and set your OneSignal app ID:

```sh
cp .env.example .env
```

## iOS

Run or build with the Swift Package Manager location opt-out in the environment:

```sh
ONESIGNAL_DISABLE_LOCATION=true flutter run -d ios
```

The app does not include `NSLocationWhenInUseUsageDescription` or
`NSLocationAlwaysAndWhenInUseUsageDescription`.

## Android

Run or build with the same location opt-out in the environment:

```sh
ONESIGNAL_DISABLE_LOCATION=true flutter run -d android
```

The Android manifest does not request fine or coarse location permissions.
