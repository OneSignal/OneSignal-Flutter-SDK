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
  onesignal_flutter: ^5.4.0
  provider: ^6.1.0
  shared_preferences: ^2.3.0
  http: ^1.2.0
  flutter_svg: ^2.0.0

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

---

## State Management

Use **Provider** for dependency injection and **ChangeNotifier** for reactive state.

- `ChangeNotifierProvider<AppViewModel>` at the root widget tree in `main.dart`
- `AppViewModel extends ChangeNotifier` holds all UI state as private fields with public getters
- Exposes action methods that update state and call `notifyListeners()`
- Receives `OneSignalRepository` and `PreferencesService` via constructor injection
- Initialize OneSignal SDK before `runApp()`
- Use `Consumer`/`Selector` from Provider to scope rebuilds and minimize re-renders
- `OneSignalRepository` is a plain Dart class (not a ChangeNotifier)

### Persistence

- `PreferencesService` wraps `SharedPreferences`
- In-memory lists use `List<MapEntry<String, String>>` for triggers, aliases, tags
- Triggers list (`triggersList`) is NOT persisted to `SharedPreferences`

### SDK State Restoration

In `main.dart`, restore SDK state from `SharedPreferences` cache BEFORE `initialize`:
```dart
OneSignal.consentRequired(cachedConsentRequired);
OneSignal.consentGiven(cachedPrivacyConsent);
OneSignal.initialize(appId);
```

Then AFTER initialize:
```dart
OneSignal.InAppMessages.paused(cachedPausedStatus);
OneSignal.Location.setShared(cachedLocationShared);
```

In `AppViewModel.loadInitialState()`, read UI state from the SDK (not cached prefs):
- `OneSignal.InAppMessages.arePaused()` for IAM paused state
- `OneSignal.Location.isShared()` for location state
- `OneSignal.User.getExternalId()` for external user ID

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
- Call `viewModel.promptPush()` in `initState()` of `HomeScreen`

### Loading Overlay
- `CircularProgressIndicator` centered in a full-screen semi-transparent overlay
- `Stack` + `Visibility` based on `isLoading` state
- Use `await Future.delayed(const Duration(milliseconds: 100))` after setting state for render delay

### SnackBar Messages
- `AppViewModel` exposes a `snackBarMessage` stream or `ValueNotifier<String?>`
- `HomeScreen` shows via `ScaffoldMessenger.of(context).showSnackBar()`
- Clear previous SnackBar with `ScaffoldMessenger.of(context).clearSnackBars()`

### Send In-App Message Icons
- TOP BANNER: `Icons.vertical_align_top`
- BOTTOM BANNER: `Icons.vertical_align_bottom`
- CENTER MODAL: `Icons.crop_square`
- FULL SCREEN: `Icons.fullscreen`

### Dialogs
- All dialogs use `insetPadding: EdgeInsets.symmetric(horizontal: 16)` and `SizedBox(width: double.maxFinite)` on content for full-width layout
- `MultiSelectRemoveDialog` uses `CheckboxListTile`
- `TextEditingController`s are properly disposed in `StatefulWidget`s
- JSON parsing via `jsonDecode` returns `Map<String, dynamic>` for Track Event

### Accessibility (Appium)
- Use `Semantics` widget with `label` property:
  ```dart
  Semantics(label: 'log_entry_${index}_message', child: Text(entry.message))
  ```

### Log Manager
- Singleton with `ChangeNotifier` for reactive UI updates
- `LogManager().d(tag, message)`, `.i()`, `.w()`, `.e()`
- Also prints via `debugPrint` for development

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
│   │   ├── tooltip_helper.dart
│   │   └── log_manager.dart
│   ├── repositories/
│   │   └── onesignal_repository.dart
│   ├── viewmodels/
│   │   └── app_viewmodel.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── secondary_screen.dart
│   └── widgets/
│       ├── section_card.dart
│       ├── toggle_row.dart
│       ├── action_button.dart
│       ├── list_widgets.dart
│       ├── loading_overlay.dart
│       ├── log_view.dart
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
│           ├── track_event_section.dart
│           └── location_section.dart
├── android/
├── ios/
├── pubspec.yaml
├── google-services.json
└── agconnect-services.json
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
- **Minimal rebuilds** via `Consumer`/`Selector` from Provider
- **No platform channels needed** since the OneSignal Flutter SDK handles all bridging
