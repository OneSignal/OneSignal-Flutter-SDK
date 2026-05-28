# Draft issue for `OneSignal/OneSignal-Android-SDK`

Suggested title:

> Notifications silently dropped on Android when app coexists with another `FirebaseMessagingService` (e.g. `firebase_messaging` / FlutterFire)

---

## Summary

`com.onesignal.notifications.receivers.FCMBroadcastReceiver` registers an
intent filter that requires both:

```xml
<intent-filter android:priority="999">
  <action   android:name="com.google.android.c2dm.intent.RECEIVE" />
  <category android:name="<APP_PACKAGE_NAME>" />
</intent-filter>
```

The `<category>` requirement is a vestige from GCM, where each broadcast
carried the target app's package name as a category. **Modern FCM
(`firebase-messaging` 22.x+) no longer sets that category on its
broadcasts**, so the filter never matches and OneSignal's receiver is
silently skipped on apps that also have another `FirebaseMessagingService`
registered.

The reason this is invisible in OneSignal-only apps is that GMS's own
`com.google.firebase.iid.FirebaseInstanceIdReceiver` (which has no
category filter) handles the broadcast and the modern service-dispatch
path routes the payload to OneSignal indirectly. As soon as a customer
adds an FCM-based plugin that registers its own
`FirebaseMessagingService` (FlutterFire's `firebase_messaging` being the
common case, but also `aws_amplify_push_notifications`, OEM SDKs, custom
services), that other service wins service-dispatch and OneSignal's
broadcast path stops being exercised. Net result: pushes "vanish" — no
foreground listener, no notification displayed, no click event.

## Repro (Flutter, but architecture-level — same applies to any Android app)

1. Empty Flutter app, add `onesignal_flutter: ^5.5.5` and
   `firebase_messaging: ^15.2.10`.
2. Configure Firebase (`google-services.json`) and OneSignal as normal.
3. `await OneSignal.initialize(...)`.
4. Register both
   ```dart
   FirebaseMessaging.onMessage.listen((m) => print('[FCM] $m'));
   OneSignal.Notifications.addForegroundWillDisplayListener((e) {
     print('[OS fg] ${e.notification.title}');
     e.notification.display();
   });
   ```
5. Send a push from the OneSignal dashboard with app in foreground.

Observed: only `[FCM]` fires. No OneSignal log, no banner.
Expected: both fire; OneSignal shows the banner.

Full Flutter-side reproduction (with `adb logcat` evidence) lives in
[OneSignal-Flutter-SDK#1138](https://github.com/OneSignal/OneSignal-Flutter-SDK/issues/1138)
and the `fadi/issue-1138-repro-current-with-firebase` branch there.

## Why the existing manifest filter was OK in 2016 and isn't now

| Era | How FCM/GCM routed to apps | What OneSignal's filter saw |
|---|---|---|
| GCM (≤2018) | Ordered broadcast with `<category>` matching app package | Matched, processed, optionally aborted |
| Early FCM | Same ordered broadcast, category still set | Matched |
| Modern FCM (firebase-messaging 22+) | Either service-only dispatch, OR an ordered broadcast WITHOUT the package category | Never matches |

`firebase-messaging` source confirms it: `FirebaseInstanceIdReceiver`
has no category filter and is the de-facto sink for the broadcast.

## Suggested fixes (any one of these unblocks customers)

**(a) One-line manifest fix — preferred, fully backward-compatible**

Drop the `<category>` element from `FCMBroadcastReceiver`'s intent
filter. The remaining `android:permission="com.google.android.c2dm.permission.SEND"`
plus the app-package-scoped delivery semantics of `c2dm.intent.RECEIVE`
already prevent cross-app spoofing. No customer code changes required.

**(b) Modern entry point — service base class**

Ship a public `OneSignalFirebaseMessagingService extends FirebaseMessagingService`
that customers can register at higher priority than competing services,
or extend in their own service:

```java
public class MyService extends OneSignalFirebaseMessagingService {
  @Override public void onMessageReceived(RemoteMessage m) {
    super.onMessageReceived(m); // OneSignal handles its payloads
    if (isMine(m)) handleMine(m);
  }
}
```

**(c) Public ingestion API — most flexible for SDK-on-SDK coexistence**

```java
OneSignal.getNotifications().handleRemoteMessage(remoteMessage);
```

Callable from any `FirebaseMessagingService.onMessageReceived`. This is
what the OneSignal Flutter SDK is currently re-implementing in
[OneSignalFcmServiceBridge](https://github.com/OneSignal/OneSignal-Flutter-SDK/blob/fadi/issue-1138-repro-current-with-firebase/android/src/main/java/com/onesignal/flutter/OneSignalFcmServiceBridge.java)
by synthesizing a `c2dm.intent.RECEIVE` `Intent` and feeding it back
into `FCMBroadcastReceiver.onReceive` — which works but produces a noisy
`NullPointerException` on the receiver's `goAsync().finish()` tail
because that call is meaningless outside of a real ordered broadcast.

## Reference workaround (Flutter plugin, until upstream lands)

See `android/src/main/AndroidManifest.xml` and
`android/src/main/java/com/onesignal/flutter/OneSignalFcmServiceBridge.java`
on the
[`fadi/issue-1138-repro-current-with-firebase`](https://github.com/OneSignal/OneSignal-Flutter-SDK/tree/fadi/issue-1138-repro-current-with-firebase)
branch. The plugin registers its own `FirebaseMessagingService` at
`android:priority="100"`, wins the modern service dispatch race, and
synthesizes the legacy intent to feed the OneSignal SDK. This is a
band-aid we'd happily delete the moment any of (a)/(b)/(c) lands.

## Severity

This affects every OneSignal Android customer who also uses any other
FCM plugin or service — most Flutter + push deployments fall in this
bucket. The failure mode is silent (no exception, no log line, no
notification), so it's high-cost to diagnose and easy to misattribute
to OneSignal's foreground-listener bridge (which is the symptom, not
the cause).
