# OneSignal Flutter Sample App - Build Guide

This document extends the shared build guide with Flutter-specific details.

**Read the shared guide first:**
https://raw.githubusercontent.com/OneSignal/sdk-shared/refs/heads/main/demo/build.md

Replace `{{PLATFORM}}` with `Flutter` everywhere in that guide. Everything below either overrides or supplements sections from the shared guide.

---

## Project Setup

Create a new Flutter project at `examples/demo/` (relative to the SDK repo root).

- Dart 3+ with null safety
- Material 3 theming with `ColorScheme.fromSeed`
- Use `const` constructors wherever possible for performance
- Reference the OneSignal Flutter SDK via path dependency:
  ```yaml
  onesignal_flutter:
    path: ../../
  ```

App bar logo: render via `flutter_svg` with `centerTitle: true` on `AppBar`.

App icon generation:
```bash
dart run flutter_launcher_icons
rm assets/onesignal_logo_icon_padded.png
```

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  onesignal_flutter:
    path: ../../
  provider: ^6.1.0
  shared_preferences: ^2.3.0
  http: ^1.2.0
  url_launcher: ^6.2.0
  flutter_svg: ^2.0.0
  flutter_dotenv: ^5.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.14.3

flutter_launcher_icons:
  android: true
  ios: true
  remove_alpha_ios: true
  image_path: "assets/onesignal_logo_icon_padded.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/onesignal_logo_icon_padded.png"
```

`assets/onesignal_logo_icon_padded.png` is referenced in `pubspec.yaml` but is not checked in -- it is generated via `flutter_launcher_icons` from `assets/onesignal_logo.svg`. Remove the generated PNG after icon generation if desired.

### Environment variables

- `flutter_dotenv` loads `.env` from the `pubspec.yaml` `assets:` block (`.env` is listed alongside `assets/onesignal_logo.svg`).
- `ONESIGNAL_APP_ID` -- OneSignal app id. Falls back to the hard-coded `_defaultAppId` in `main.dart` when unset or empty.
- `ONESIGNAL_API_KEY` -- REST API key used by `OneSignalApiService` for Live Activity update/end and notification sends.
- `ONESIGNAL_ANDROID_CHANNEL_ID` -- optional Android notification channel id used by the REST send paths.

### Theme types

- `lib/theme.dart` exports `AppSpacing`, `AppColors`, and `AppTheme` classes alongside the `AppSnackBar` extension on `BuildContext`.
- `AppTheme.light` is the Material 3 `ThemeData` applied to `MaterialApp`.

---

## State Management

Use **Provider** for dependency injection and **ChangeNotifier** for reactive state.

- `ChangeNotifierProvider<AppViewModel>` at the root widget tree in `main.dart`
- `AppViewModel extends ChangeNotifier` holds all UI state as private fields with public getters
- Exposes action methods that update state and call `notifyListeners()`
- Receives `OneSignalApiService` and `PreferencesService` via constructor injection
- Initialize OneSignal SDK before `runApp()`
- Section widgets read the viewmodel via `context.watch<AppViewModel>()` (for rebuilds) or `context.read<AppViewModel>()` (one-shot, for callbacks). No `Consumer`/`Selector` usage anywhere in `lib/`.
- SDK calls (`OneSignal.User.*`, `OneSignal.Notifications.*`, `OneSignal.InAppMessages.*`, etc.) are invoked directly from `AppViewModel`. There is no repository wrapper.

### REST client

- `OneSignalApiService` is a plain Dart class (not a `ChangeNotifier`) that owns the OneSignal REST API calls -- send notification, fetch user, Live Activity update/end.

### Persistence

- `PreferencesService` wraps `SharedPreferences`
- In-memory lists use `List<MapEntry<String, String>>` for triggers, aliases, tags
- Triggers list (`triggersList`) is NOT persisted to `SharedPreferences`
- After fetching the user from the REST API, merge results into existing in-memory lists (`_mergePairs` for tag/alias maps, `_mergeUnique` for emails/SMS) so locally-added entries that have not yet round-tripped through the API are preserved.

### SDK State Restoration

In `main.dart`, restore SDK state from `SharedPreferences` cache BEFORE `initialize`:
```dart
OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
OneSignal.consentRequired(prefs.consentRequired);
OneSignal.consentGiven(prefs.privacyConsent);
await OneSignal.initialize(appId);
```

Then AFTER initialize:
```dart
OneSignal.LiveActivities.setupDefault(
  options: LiveActivitySetupOptions(
    enablePushToStart: true,
    enablePushToUpdate: true,
  ),
);
OneSignal.InAppMessages.paused(prefs.iamPaused);
OneSignal.Location.setShared(prefs.locationShared);
```

`main.dart` also registers listeners before `runApp()`:
- IAM: `addWillDisplayListener`, `addDidDisplayListener`, `addWillDismissListener`, `addDidDismissListener`, `addClickListener`
- Notifications: `addClickListener`, `addForegroundWillDisplayListener` (calls `event.notification.display()`)
- `TooltipHelper().init()` fetches tooltip content in the background.
- `appId` falls back to a hard-coded `_defaultAppId` constant when `ONESIGNAL_APP_ID` is not set in `.env`.

`PreferencesService` is the source of truth for restored UI state. In `AppViewModel.loadInitialState(appId)`, read UI state from `_prefs` (not from the SDK):
```dart
_consentRequired = _prefs.consentRequired;
_privacyConsentGiven = _prefs.privacyConsent;
_externalUserId = _prefs.externalUserId;
_iamPaused = _prefs.iamPaused;
_locationShared = _prefs.locationShared;

if (_externalUserId != null) {
  OneSignal.login(_externalUserId!);
}
```

The cached `externalUserId` is the only value that drives an SDK call inside `loadInitialState()` -- it triggers `OneSignal.login(...)` so the SDK identity matches the persisted UI state. Push subscription id, opted-in flag, and permission are then read from the live SDK state, and the OneSignal ID is fetched via `OneSignal.User.getOnesignalId()`.

### Observers

Register in `AppViewModel`:
```dart
OneSignal.User.pushSubscription.addObserver(...)
OneSignal.Notifications.addPermissionObserver(...)
OneSignal.User.addObserver(...)
```

---

## Flutter-Specific UI Details

### Notification Permission
- Wraps the call in `WidgetsBinding.instance.addPostFrameCallback` inside `initState()` (`home_screen.dart` lines ~39-41) so the prompt fires after the first frame.

### Loading State
- No global loading overlay. `vm.isLoading` is passed to `PairList(loading: ...)` in **aliases**, **emails**, **sms**, and **tags** sections only. `user_section.dart` has no loading UI.
- The viewmodel uses a request-sequence counter (`_fetchSequence`) so stale REST results are dropped when a newer fetch is already in flight.

### SnackBar Messages
- `AppSnackBar` extension on `BuildContext` defined in `lib/theme.dart` exposes `context.showSnackBar(message)`.
- The extension calls `ScaffoldMessenger.of(this)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message), duration: _toastDuration))` for replace-on-show behavior.
- Duration is the file-private constant `const Duration _toastDuration = Duration(seconds: 3);` in `theme.dart`.
- Section widgets call `context.showSnackBar(...)` from button callbacks, guarded by `if (context.mounted)`. Only Outcomes, Custom Events, and Location check trigger snackbars; everything else uses `debugPrint(...)`. Outcomes and Custom Events call synchronous viewmodel methods then show the snackbar (no `await` on the SDK). Only Location's `CHECK LOCATION SHARED` button truly awaits (`vm.checkLocationShared()`) before showing the result.
- The `ChangeNotifier` / viewmodel must not hold snackbar state or expose snackbar messages.

### Dialogs
- The home screen widget owns layout + the tooltip dialog only. Tooltip presentation is via a private method `_showTooltipDialog(BuildContext, String key)` on the home state (`home_screen.dart` line ~44), wired to each section through an `onInfoTap` callback. No `_activeTooltipKey` field, no `ChangeNotifier` involvement.
- Section action dialogs call `showDialog<T>(context: context, builder: ...)` inline inside each button's `onPressed` handler (see `aliases_section.dart`, `outcomes_section.dart`) and `await` the typed result. Only `HomeScreen` has a private `_show*Dialog` method, and only for the tooltip. No `*Open` booleans are required because Flutter presents dialogs imperatively; the awaited result drives the SDK call + optional `context.showSnackBar(...)`.
- Shared dialog widgets live in `lib/widgets/dialogs.dart` (or `lib/widgets/dialogs/`). Reuse the single `SingleInputDialog` widget for any one-field input (takes `title`, `fieldLabel`, `confirmLabel`, `semanticsLabel`) -- do not create per-screen one-field dialogs.
- All dialogs use `insetPadding: EdgeInsets.symmetric(horizontal: 16)` and `SizedBox(width: double.maxFinite)` on content for full-width layout. `MultiSelectRemoveDialog` uses `CheckboxListTile`. `TextEditingController`s are disposed in the dialog's `StatefulWidget`. JSON parsing via `jsonDecode` returns `Map<String, dynamic>` for Track Event.
- `dialogs.dart` also defines `PairInputDialog`, `MultiPairInputDialog`, `OutcomeDialog`, `TrackEventDialog`, `CustomNotificationDialog`, and `TooltipDialog` beyond `SingleInputDialog` and `MultiSelectRemoveDialog`.
- The viewmodel must not hold dialog visibility flags or dialog input drafts.

### Live Activities (iOS only)
- `LiveActivitiesSection` is rendered only when `defaultTargetPlatform == TargetPlatform.iOS` (`home_screen.dart` line ~118).
- `OneSignal.LiveActivities.setupDefault(options: LiveActivitySetupOptions(enablePushToStart: true, enablePushToUpdate: true))` is called in `main.dart` after `OneSignal.initialize`.
- REST update/end is performed via `OneSignalApiService` using `ONESIGNAL_API_KEY`. The update/end buttons are disabled when `vm.hasApiKey` is false.
- While an update is in flight, `isLaUpdating` disables the update button rather than showing a spinner (`live_activities_section.dart`).
- Native sources live at `ios/OneSignalWidget/` (Live Activity widget extension) and `ios/OneSignalNotificationServiceExtension/`.

---

## iOS native config

- `ios/Runner/Info.plist` includes:
  - `NSSupportsLiveActivities` (enables ActivityKit-backed Live Activities).
  - Location usage strings (`NSLocationWhenInUseUsageDescription`, etc.).
  - `UIBackgroundModes` containing `remote-notification` for silent push handling.

---

## File Structure

```
examples/demo/
├── lib/
│   ├── main.dart
│   ├── theme.dart
│   ├── models/
│   │   ├── user_data.dart
│   │   ├── notification_type.dart
│   │   └── in_app_message_type.dart
│   ├── services/
│   │   ├── onesignal_api_service.dart
│   │   ├── preferences_service.dart
│   │   └── tooltip_helper.dart
│   ├── viewmodels/
│   │   └── app_viewmodel.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── secondary_screen.dart
│   └── widgets/
│       ├── section_card.dart
│       ├── toggle_row.dart
│       ├── action_button.dart
│       ├── app_text_field.dart
│       ├── list_widgets.dart
│       ├── dialogs.dart
│       └── sections/
│           ├── app_section.dart
│           ├── user_section.dart
│           ├── push_section.dart
│           ├── send_push_section.dart
│           ├── in_app_section.dart
│           ├── send_iam_section.dart
│           ├── aliases_section.dart
│           ├── emails_section.dart
│           ├── sms_section.dart
│           ├── tags_section.dart
│           ├── outcomes_section.dart
│           ├── triggers_section.dart
│           ├── custom_events_section.dart
│           ├── live_activities_section.dart
│           └── location_section.dart
├── assets/
│   └── onesignal_logo.svg
├── android/
│   └── app/
│       └── build.gradle.kts
├── ios/
│   ├── OneSignalWidget/
│   └── OneSignalNotificationServiceExtension/
├── .env
└── pubspec.yaml
```

---

## Flutter Best Practices

- **const constructors** on all stateless widgets and immutable data classes
- **Provider** for dependency injection, avoiding global mutable state
- **Single responsibility** per file: one widget/class per file, sections split into their own files
- **TextEditingController disposal** in all StatefulWidgets
- **Keys** on list items via `ValueKey` for efficient rebuilds
- **Semantics** widgets for accessibility and Appium test automation
- **Immutable state** where possible; lists exposed as unmodifiable views from the ViewModel
- **Material 3** theming with `ColorScheme.fromSeed`
- **Scoped rebuilds** via `context.watch<AppViewModel>()` in `build`, `context.read<AppViewModel>()` in callbacks
- **No platform channels needed** since the OneSignal Flutter SDK handles all bridging

---

## Sibling examples

- `examples/demo_pods/` exists alongside the pub-based `examples/demo/` in the SDK repo. It is a separate sample whose dependency wiring differs from `demo/`.
