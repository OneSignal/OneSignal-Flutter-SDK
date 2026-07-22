# OneSignal + Flutter local notifications

Android and iOS compatibility harness using both
[`onesignal_flutter`](https://pub.dev/packages/onesignal_flutter) for push
notifications and
[`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications)
for notifications created by the app. Its layout and test flow mirror the
`examples/expo-notif` app in the OneSignal Expo plugin repository.

## Setup

1. Create or select an app in the [OneSignal dashboard](https://dashboard.onesignal.com/).
2. Configure its Android and iOS platforms using bundle ID
   `com.onesignal.example`.
3. On iOS, select the `Runner` target in Xcode and choose your development team.
   The Push Notifications entitlement and remote notification background mode
   are already present. Add a OneSignal Notification Service Extension if you
   need rich media and confirmed delivery.
4. Copy the environment template and set your OneSignal app ID:

   ```sh
   cp .env.example .env
   ```

   ```dotenv
   ONESIGNAL_APP_ID=your-onesignal-app-id
   ```

5. Fetch dependencies:

   ```sh
   flutter pub get
   ```

## Run

```sh
flutter run
```

The app initializes `flutter_local_notifications` before OneSignal so both
notification delegates can coexist on iOS.

Push notifications require a physical iOS device. Without
`ONESIGNAL_APP_ID`, the app remains usable for local notification testing.

### iOS compatibility handling

`AppDelegate.swift` preserves the foreground presentation options embedded by
`flutter_local_notifications`. This keeps local banners, sounds, and list
entries working after OneSignal installs its notification center delegate.

## Test flow

1. Tap **Request Permissions**.
2. Tap **Schedule Flutter Local Notification**, background the app if needed,
   then tap the notification. The event log should show `Local response`.
3. Wait for a OneSignal push ID, then tap **Send OneSignal Push** and tap the
   push notification. Compare the local and OneSignal response events.
