# OneSignal + Firebase Messaging Demo

The main demo app with `firebase_messaging` added, for reproducing issues where OneSignal runs alongside FlutterFire, such as notification click listeners not firing on Android background or killed taps ([#1138](https://github.com/OneSignal/OneSignal-Flutter-SDK/issues/1138)).

## Setup

1. Copy the environment template and set your OneSignal credentials. The `.env` file must exist before the first build because Flutter bundles it as an app asset:

   ```bash
   cp .env.example .env
   ```

2. Add your Firebase project's `google-services.json` to `android/app/`. The Android build needs it because this app applies the `com.google.gms.google-services` Gradle plugin. OneSignal push itself doesn't depend on it. The file is for FlutterFire and `tools/send_fcm.sh`.

3. Fetch dependencies:

   ```bash
   flutter pub get
   ```

## Run

```bash
flutter run -d <device_id>
```

The app logs the FCM token as `[FCM token]` and FlutterFire events as `[FCM fg]`, `[FCM bg]` and `[FCM open]`.

## Sending FCM pushes

[`tools/send_fcm.sh`](tools/send_fcm.sh) sends a non-OneSignal push through the FCM HTTP v1 API:

```bash
FCM_TOKEN=<device-token> ./tools/send_fcm.sh notif   # notification message
FCM_TOKEN=<device-token> ./tools/send_fcm.sh data    # data-only message
FCM_TOKEN=<device-token> ./tools/send_fcm.sh both    # notification + data
```

It authenticates with `$ACCESS_TOKEN`, `tools/service-account.json` (gitignored), or your active `gcloud` credentials.

To test the bundled iOS notification action icons, follow
[Testing iOS Action Button Icons](../ios-action-button-icons.md).
