# Issue #1138 reproduction — Branch B-2 (manifest-override-only variant)

Branch: `fadi/issue-1138-manifest-override-only`

This branch keeps the demo app on the **in-tree OneSignal SDK** (currently
`5.5.5` via `path: ../..`) and adds `firebase_core` + `firebase_messaging`
to mimic the affected users' setup in
[issue #1138](https://github.com/OneSignal/OneSignal-Flutter-SDK/issues/1138).

Use this branch as the **suspected-broken case**. According to the users
in the issue, with this combo (OneSignal >= 5.4 + FCM in the same app)
`addClickListener` does not fire on Android when the app is in the
background, even though it fires correctly when the app is killed and
when the app is in the foreground.

Companion control branch: `fadi/issue-1138-repro-5.3.4-with-firebase`,
which is the same demo with OneSignal pinned to 5.3.4. Diffing the two
branches isolates the change set introduced between 5.3.4 and 5.5.x.

## Setup

1. Add your own Firebase project's `google-services.json` to
   `examples/demo_fm/android/app/google-services.json`.

   The `com.google.gms.google-services` Gradle plugin is wired in
   (`android/settings.gradle.kts` and `android/app/build.gradle.kts`) so the
   Android build will FAIL without this file. We do not commit one because it
   is per-developer.

2. Make sure the Firebase project's package name matches the Android
   `applicationId` (`com.onesignal.example` by default in this demo).

3. Configure your OneSignal app for FCM as usual (Server Key / V1 in
   OneSignal dashboard) and put the OneSignal app id in
   `examples/demo_fm/.env`:

   ```
   ONESIGNAL_APP_ID=<your-app-id>
   ONESIGNAL_API_KEY=<your-rest-api-key>
   ```

4. Run on a real Android device:

   ```
   cd examples/demo_fm
   flutter pub get
   flutter run -d <android-device>
   ```

## Reproduction steps

The click listener is registered **before `runApp`**, mirroring the snippet
in the issue:

```dart
WidgetsFlutterBinding.ensureInitialized();
await OneSignal.initialize(appId);
OneSignal.Notifications.addClickListener((event) {
  debugPrint('[ISSUE-1138] addClickListener fired ...');
});
```

For each app state, send a push from the OneSignal dashboard and tap it:

| State                          | Expected (per the bug report)         |
| ------------------------------ | ------------------------------------- |
| Foreground                     | `[ISSUE-1138] addClickListener fired` |
| **Background (home button)**   | **NO log line — bug reproduces**      |
| Killed (swiped away)           | `[ISSUE-1138] addClickListener fired` (some users see this fail too) |

Watch `flutter logs` (or `adb logcat | grep ISSUE-1138`) to confirm whether
the callback runs.

## Differences from `main`

- `examples/demo_fm/pubspec.yaml`: added `firebase_core` + `firebase_messaging`.
- `examples/demo_fm/lib/main.dart`: Firebase initialization + FCM handlers,
  early `addClickListener` registration tagged `[ISSUE-1138]`.
- `examples/demo_fm/android/{settings,app/build}.gradle.kts`: apply
  `com.google.gms.google-services` plugin.

## Experimental fixes to the SDK (also on this branch)

### Fix 1 — click-listener lifecycle

The change extends the defensive unsubscribe added in PR #1140 (5.5.4) to
also cover the case where the host activity is destroyed but the Flutter
engine survives.

Files changed:

- `android/src/main/java/com/onesignal/flutter/OneSignalNotifications.java`
  - Tracks whether Dart has requested a click listener.
  - Adds `onAttachedToActivity()` / `onDetachedFromActivity()` that
    add/remove the native-SDK click listener so clicks delivered while
    the JNI is detached get queued by the native SDK instead of being
    dispatched into a dead channel.
- `android/src/main/java/com/onesignal/flutter/OneSignalPlugin.java`
  - Wires the `ActivityAware` lifecycle (previously no-ops) into the
    `OneSignalNotifications` hooks above, including the
    config-change variants.
- Adds verbose lifecycle logging tagged `[ISSUE-1138]` to make the
  attach/detach + dispatch ordering visible in `adb logcat`.

### Fix 2 — `firebase_messaging` coexistence (manifest-override, no bridge service)

This branch takes a different approach than its sibling
`fadi/issue-1138-repro-current-with-firebase`. Instead of adding a
competing `FirebaseMessagingService` that wins service dispatch and
fans the message out manually, we **address the root cause** by
removing the offending `<category>` filter from OneSignal Android SDK's
`FCMBroadcastReceiver` directly, via the Android manifest merger.

Background: OneSignal's `FCMBroadcastReceiver` is registered with an
intent filter that requires a `<category>` matching the app package
name (e.g. `<category android:name="com.onesignal.example" />`). That
category was set on the GCM-era ordered broadcast but **modern FCM no
longer sets it**, so OneSignal's receiver never matches the broadcast
when a competing `FirebaseMessagingService` (e.g. FlutterFire's) takes
over the modern dispatch path. The result: OneSignal pushes silently
disappear.

Files changed:

- `android/src/main/AndroidManifest.xml`
  - Re-declares the `com.onesignal.notifications.receivers.FCMBroadcastReceiver`
    with `tools:node="replace"`, providing an intent-filter that has
    only `<action android:name="com.google.android.c2dm.intent.RECEIVE" />`
    — no `<category>`. The manifest merger replaces the AAR-bundled
    receiver definition with ours because the Flutter plugin's manifest
    has higher merge priority than the OneSignal Android SDK AAR's.

Trade-offs vs. the bridge-service approach on the sibling branch:

| | Bridge service (sibling branch) | Manifest override (this branch) |
| --- | --- | --- |
| Code surface | ~80 LOC of Java + new manifest service | ~10 LOC of manifest only |
| Failure mode if OneSignal SDK changes the receiver layout | Bridge still calls `FCMBroadcastReceiver.onReceive` — generally stable | `tools:node="replace"` may diverge from upstream if they add other attributes (e.g. a new intent-filter) |
| Failure mode if modern FCM stops sending the legacy broadcast | Bridge still works (we win the service path) | Receiver stops being called — needs a real upstream fix |
| Coexistence with other FCM SDKs in the same app | Generic — bridge sees all messages | Only fixes OneSignal — other SDKs still need their own fix if they have the same category-filter bug |
| Noise in logs | NPE on `goAsync().finish()` after each push (harmless) | None |

The bridge wins on forward-compatibility (it doesn't rely on the legacy
broadcast continuing to exist). The manifest override wins on
simplicity and on producing a clean log surface. Either is a viable
band-aid until OneSignal Android SDK fixes the upstream manifest — see
`examples/demo_fm/UPSTREAM_ISSUE_DRAFT.md` for the proposed upstream
report.

## Verifying the fixes

After running on Android, filter logs by `[ISSUE-1138]`:

```
adb logcat | rg 'ISSUE-1138|FlutterJNI was detached|NotificationWorkManager|FLTFireMsgReceiver'
```

A healthy **foreground** push (with `firebase_messaging` present) should
now look like:

```
... OneSignal: NotificationWorkManager enqueueing notification work ...
... OneSignal: Fire notificationWillShowInForegroundHandler ...
... I flutter : [FCM fg] received: <msgId> ...   (FlutterFire's onMessage fires)
... I flutter : Notification foreground will display: <title>   (OneSignal foreground listener fires)
```

A healthy **background-tap** flow should look like:

```
[ISSUE-1138] OneSignalFcmServiceBridge.onMessageReceived ...
[ISSUE-1138] OneSignalPlugin.onDetachedFromActivity()
[ISSUE-1138] OneSignalNotifications.onDetachedFromActivity() — removing native click listener
... (user taps notification) ...
[ISSUE-1138] OneSignalPlugin.onAttachedToActivity()
[ISSUE-1138] OneSignalNotifications.onAttachedToActivity() — re-adding native click listener (queued events should drain)
[ISSUE-1138] OneSignalNotifications.onClick() — native SDK dispatched click; forwarding to MethodChannel
[ISSUE-1138 late] addClickListener fired: ...   (from main.dart)
```

If you still see `W/FlutterJNI ... Channel: OneSignal#notifications` AND
no `[ISSUE-1138 late] addClickListener fired`, the fix didn't help in your
scenario — capture the surrounding 50 lines of logs and we'll iterate.
