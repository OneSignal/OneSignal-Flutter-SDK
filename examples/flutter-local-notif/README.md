# OneSignal + Flutter local notifications

Minimal Android and iOS example using both
[`onesignal_flutter`](https://pub.dev/packages/onesignal_flutter) for push
notifications and
[`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications)
for notifications created by the app.

## Setup

1. Create or select an app in the [OneSignal dashboard](https://dashboard.onesignal.com/).
2. Configure its Android and iOS platforms using bundle ID
   `com.onesignal.flutterLocalNotif`, or replace the generated application IDs
   with your own.
3. On iOS, select the `Runner` target in Xcode and choose your development team.
   The Push Notifications entitlement and remote notification background mode
   are already present. Add a OneSignal Notification Service Extension if you
   need rich media and confirmed delivery.
4. Fetch dependencies:

   ```sh
   flutter pub get
   ```

## Run

Pass your OneSignal app ID with a Dart define:

```sh
flutter run --dart-define=ONESIGNAL_APP_ID=YOUR_APP_ID
```

The app initializes `flutter_local_notifications` before OneSignal so both
notification delegates can coexist on iOS. Use the buttons to request the shared
system notification permission and display a local notification. OneSignal push
receive/open events and local notification taps appear in the event list.

Push notifications require a physical iOS device. Without
`ONESIGNAL_APP_ID`, the app remains usable for local notification testing.
