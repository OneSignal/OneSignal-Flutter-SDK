# OneSignal Flutter Sample App - Build Guide

This document contains all the prompts and requirements needed to build the OneSignal Flutter Sample App from scratch. Give these prompts to an AI assistant or follow them manually to recreate the app.

---

## Phase 0: Reference Screenshots (REQUIRED)

### Prompt 0.1 - Capture Reference UI

```
Before building anything, an Android emulator MUST be running with the
reference OneSignal demo app installed. These screenshots are the source
of truth for the UI you are building. Do NOT proceed to Phase 1 without them.

Check for connected emulators:
  adb devices

If no device is listed, stop and ask the user to start one.

Identify which emulator has com.onesignal.sdktest installed by checking each listed device, e.g.:
  adb -s emulator-5554 shell pm list packages 2>/dev/null | grep -i onesignal
  adb -s emulator-5556 shell pm list packages 2>/dev/null | grep -i onesignal

Use that emulator's serial (e.g. emulator-5556) for all subsequent adb commands via the -s flag.

Launch the reference app:
  adb -s <emulator-serial> shell am start -n com.onesignal.sdktest/.ui.main.MainActivity

Dismiss any in-app messages that appear on launch. Tap the X or
click-through button on each IAM until the main UI is fully visible
with no overlays.

Create an output directory:
  mkdir -p /tmp/onesignal_reference

Capture screenshots by scrolling through the full UI:
1. Take a screenshot from the top of the screen:
     adb shell screencap -p /sdcard/ref_01.png && adb pull /sdcard/ref_01.png /tmp/onesignal_reference/ref_01.png
2. Scroll down by roughly one viewport height:
     adb shell input swipe 500 1500 500 500
3. Take the next screenshot (ref_02.png, ref_03.png, etc.)
4. Repeat until you've reached the bottom of the scrollable content

You MUST read each captured screenshot image so you can see the actual UI.
These images define the visual target for every section you build later.
Pay close attention to:
  - Section header style and casing
  - Card vs non-card content grouping
  - Button placement (inside vs outside cards)
  - List item layout (stacked vs inline key-value)
  - Icon choices (delete, close, info, etc.)
  - Typography, spacing, and colors

You can also interact with the reference app to observe specific flows:

Dump the UI hierarchy to find elements by resource-id, text, or content-desc:
  adb shell uiautomator dump /sdcard/ui.xml && adb pull /sdcard/ui.xml /tmp/onesignal_reference/ui.xml

Parse the XML to find an element's bounds, then tap it:
  adb shell input tap <centerX> <centerY>

Type into a focused text field:
  adb shell input text "test"

Example flow to observe "Add Tag" behavior:
  1. Dump UI -> find the ADD button bounds -> tap it
  2. Dump UI -> find the Key and Value fields -> tap and type into them
  3. Tap the confirm button -> screenshot the result
  4. Compare the tag list state before and after

Also capture screenshots of key dialogs to match their layout:
  - Add Alias (single pair input)
  - Add Multiple Aliases/Tags (dynamic rows with add/remove)
  - Remove Selected Tags (checkbox multi-select)
  - Login User
  - Send Outcome (radio options)
  - Track Event (with JSON properties field)
  - Custom Notification (title + body)
These dialog screenshots are important for matching field layout,
button placement, spacing, and validation behavior.

Refer back to these screenshots throughout all remaining phases whenever
you need to decide on layout, spacing, section order, dialog flows, or
overall look and feel.
```

---

## Phase 1: Initial Setup

### Prompt 1.1 - Project Foundation

```
Create a new Flutter project at examples/demo/ (relative to the SDK repo root).

Build the app with:
- Clean architecture: repository pattern with ChangeNotifier-based state management (Provider)
- Dart 3+ with null safety
- Material 3 theming with OneSignal brand colors
- App name: "OneSignal Demo"
- Top app bar: centered title with OneSignal logo SVG + "Sample App" text (use centerTitle: true on AppBar)
- Support for both Android and iOS
- Android package name: com.onesignal.example
- iOS bundle identifier: com.onesignal.example
- All dialogs should have EMPTY input fields (for Appium testing - test framework enters values)
- Use const constructors wherever possible for performance
- Separate widget files per section to keep files focused and readable

Download the app bar logo SVG from:
  https://raw.githubusercontent.com/OneSignal/sdk-shared/refs/heads/main/assets/onesignal_logo.svg
Save it to the demo project at assets/onesignal_logo.svg and use it for the AppBar logo via flutter_svg.

Download the padded app icon PNG from:
  https://raw.githubusercontent.com/OneSignal/sdk-shared/refs/heads/main/assets/onesignal_logo_icon_padded.png
Save it to assets/onesignal_logo_icon_padded.png, generate all platform app icons, then delete the downloaded file:
  dart run flutter_launcher_icons
  rm assets/onesignal_logo_icon_padded.png

Reference the OneSignal Flutter SDK from the parent repo using a path dependency:
  onesignal_flutter:
    path: ../../
```

### Prompt 1.2 - Dependencies (pubspec.yaml)

```
Add these dependencies to pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter
  onesignal_flutter: ^5.4.0    # OneSignal SDK
  provider: ^6.1.0              # State management
  shared_preferences: ^2.3.0    # Local persistence
  http: ^1.2.0                  # REST API calls
  flutter_svg: ^2.0.0           # SVG rendering (AppBar logo)

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

### Prompt 1.3 - OneSignal Repository

```
Create a OneSignalRepository class that centralizes all OneSignal SDK calls.
This is a plain Dart class (not a ChangeNotifier) injected into the ViewModel.

User operations:
- loginUser(String externalUserId) -> Future<void>
- logoutUser() -> Future<void>

Alias operations:
- addAlias(String label, String id) -> void
- addAliases(Map<String, dynamic> aliases) -> void

Email operations:
- addEmail(String email) -> void
- removeEmail(String email) -> void

SMS operations:
- addSms(String smsNumber) -> void
- removeSms(String smsNumber) -> void

Tag operations:
- addTag(String key, String value) -> void
- addTags(Map<String, dynamic> tags) -> void
- removeTag(String key) -> void
- removeTags(List<String> keys) -> void
- getTags() -> Future<Map<String, String>>

Trigger operations (via OneSignal.InAppMessages):
- addTrigger(String key, String value) -> void
- addTriggers(Map<String, String> triggers) -> void
- removeTrigger(String key) -> void
- removeTriggers(List<String> keys) -> void
- clearTriggers() -> void

Outcome operations (via OneSignal.Session):
- sendOutcome(String name) -> void
- sendUniqueOutcome(String name) -> void
- sendOutcomeWithValue(String name, double value) -> void

Track Event:
- trackEvent(String name, Map<String, dynamic>? properties) -> void

Push subscription:
- getPushSubscriptionId() -> String?
- isPushOptedIn() -> bool?
- optInPush() -> void
- optOutPush() -> void

Notifications:
- hasPermission() -> bool
- requestPermission(bool fallbackToSettings) -> Future<bool>

In-App Messages:
- setInAppMessagesPaused(bool paused) -> void
- isInAppMessagesPaused() -> Future<bool>

Location:
- setLocationShared(bool shared) -> void
- isLocationShared() -> Future<bool>
- requestLocationPermission() -> void

Privacy consent:
- setConsentRequired(bool required) -> void
- setConsentGiven(bool granted) -> void

User IDs:
- getExternalId() -> Future<String?>
- getOnesignalId() -> Future<String?>

Notification sending (via REST API, delegated to OneSignalApiService):
- sendNotification(NotificationType type) -> Future<bool>
- sendCustomNotification(String title, String body) -> Future<bool>
- fetchUser(String onesignalId) -> Future<UserData?>
```

### Prompt 1.4 - OneSignalApiService (REST API Client)

```
Create OneSignalApiService class for REST API calls using the http package:

Properties:
- _appId: String (set during initialization)

Methods:
- setAppId(String appId)
- getAppId() -> String
- sendNotification(NotificationType type, String subscriptionId) -> Future<bool>
- sendCustomNotification(String title, String body, String subscriptionId) -> Future<bool>
- fetchUser(String onesignalId) -> Future<UserData?>

sendNotification endpoint:
- POST https://onesignal.com/api/v1/notifications
- Accept header: "application/vnd.onesignal.v1+json"
- Uses include_subscription_ids (not include_player_ids)
- Includes big_picture for Android image notifications
- Includes ios_attachments for iOS image notifications (needed for the NSE to download and attach images)

fetchUser endpoint:
- GET https://api.onesignal.com/apps/{app_id}/users/by/onesignal_id/{onesignal_id}
- NO Authorization header needed (public endpoint)
- Returns UserData with aliases, tags, emails, smsNumbers, externalId
```

### Prompt 1.5 - SDK Observers

```
In main.dart, set up OneSignal initialization and listeners before runApp():

OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
OneSignal.consentRequired(cachedConsentRequired);
OneSignal.consentGiven(cachedPrivacyConsent);
OneSignal.initialize(appId);

Then register listeners:
- OneSignal.InAppMessages.addWillDisplayListener(...)
- OneSignal.InAppMessages.addDidDisplayListener(...)
- OneSignal.InAppMessages.addWillDismissListener(...)
- OneSignal.InAppMessages.addDidDismissListener(...)
- OneSignal.InAppMessages.addClickListener(...)
- OneSignal.Notifications.addClickListener(...)
- OneSignal.Notifications.addForegroundWillDisplayListener(...)

After initialization, restore cached SDK states from SharedPreferences:
- OneSignal.InAppMessages.paused(cachedPausedStatus)
- OneSignal.Location.setShared(cachedLocationShared)

In AppViewModel (ChangeNotifier), register observers:
- OneSignal.User.pushSubscription.addObserver(...) - react to push subscription changes
- OneSignal.Notifications.addPermissionObserver(...) - react to permission changes
- OneSignal.User.addObserver(...) - call fetchUserDataFromApi() when user changes
```

---

## Phase 2: UI Sections

### Section Order (top to bottom)

1. **App Section** (App ID, Guidance Banner, Consent Toggle, Logged-in-as display, Login/Logout)
2. **Push Section** (Push ID, Enabled Toggle, Auto-prompts permission on load)
3. **Send Push Notification Section** (Simple, With Image, Custom buttons)
4. **In-App Messaging Section** (Pause toggle)
5. **Send In-App Message Section** (Top Banner, Bottom Banner, Center Modal, Full Screen - with icons)
6. **Aliases Section** (Add/Add Multiple, read-only list)
7. **Emails Section** (Collapsible list >5 items)
8. **SMS Section** (Collapsible list >5 items)
9. **Tags Section** (Add/Add Multiple/Remove Selected)
10. **Outcome Events Section** (Send Outcome dialog with type selection)
11. **Triggers Section** (Add/Add Multiple/Remove Selected/Clear All - IN MEMORY ONLY)
12. **Track Event Section** (Track Event with JSON validation)
13. **Location Section** (Location Shared toggle, Prompt Location button)
14. **Next Page Button**

### Prompt 2.1 - App Section

```
App Section layout:

1. App ID display (readonly Text showing the OneSignal App ID)

2. Sticky guidance banner below App ID:
   - Text: "Add your own App ID, then rebuild to fully test all functionality."
   - Link text: "Get your keys at onesignal.com" (clickable, opens browser via url_launcher)
   - Light background color to stand out

3. Consent card with up to two toggles:
   a. "Consent Required" toggle (always visible):
      - Label: "Consent Required"
      - Description: "Require consent before SDK processes data"
      - Calls OneSignal.consentRequired(value)
   b. "Privacy Consent" toggle (only visible when Consent Required is ON):
      - Label: "Privacy Consent"
      - Description: "Consent given for data collection"
      - Calls OneSignal.consentGiven(value)
      - Separated from the above toggle by a horizontal divider
   - NOT a blocking overlay - user can interact with app regardless of state

4. User status card (always visible, ABOVE the login/logout buttons):
   - Card with two rows separated by a divider
   - Row 1: "Status" label on the left, value on the right
   - Row 2: "External ID" label on the left, value on the right
   - When logged out:
     - Status shows "Anonymous"
     - External ID shows "–" (dash)
   - When logged in:
     - Status shows "Logged In" with green styling (Color(0xFF2E7D32))
     - External ID shows the actual external user ID

5. LOGIN USER button:
   - Shows "LOGIN USER" when no user is logged in
   - Shows "SWITCH USER" when a user is logged in
   - Opens dialog with empty "External User Id" field

6. LOGOUT USER button (only visible when a user is logged in)
```

### Prompt 2.2 - Push Section

```
Push Section:
- Section title: "Push" with info icon for tooltip
- Push Subscription ID display (readonly)
- Enabled toggle switch (controls optIn/optOut)
- Notification permission is automatically requested when home screen loads
- PROMPT PUSH button:
  - Only visible when notification permission is NOT granted (fallback if user denied)
  - Requests notification permission when clicked
  - Hidden once permission is granted
```

### Prompt 2.3 - Send Push Notification Section

```
Send Push Notification Section (placed right after Push Section):
- Section title: "Send Push Notification" with info icon for tooltip
- Three buttons:
  1. SIMPLE - title: "Simple Notification", body: "This is a simple push notification"
  2. WITH IMAGE - title: "Image Notification", body: "This notification includes an image"
     big_picture (Android): https://media.onesignal.com/automated_push_templates/ratings_template.png
     ios_attachments (iOS): {"image": "https://media.onesignal.com/automated_push_templates/ratings_template.png"}
  3. CUSTOM - opens dialog for custom title and body

Tooltip should explain each button type.
```

### Prompt 2.4 - In-App Messaging Section

```
In-App Messaging Section (placed right after Send Push):
- Section title: "In-App Messaging" with info icon for tooltip
- Pause In-App Messages toggle switch:
  - Label: "Pause In-App Messages"
  - Description: "Toggle in-app message display"
```

### Prompt 2.5 - Send In-App Message Section

```
Send In-App Message Section (placed right after In-App Messaging):
- Section title: "Send In-App Message" with info icon for tooltip
- Four FULL-WIDTH buttons (not a grid):
  1. TOP BANNER - Icons.vertical_align_top, trigger: "iam_type" = "top_banner"
  2. BOTTOM BANNER - Icons.vertical_align_bottom, trigger: "iam_type" = "bottom_banner"
  3. CENTER MODAL - Icons.crop_square, trigger: "iam_type" = "center_modal"
  4. FULL SCREEN - Icons.fullscreen, trigger: "iam_type" = "full_screen"
- Button styling:
  - RED background color (Color(0xFFE9444E))
  - WHITE text
  - Type-specific icon on LEFT side only (no right side icon)
  - Full width of the card
  - Left-aligned text and icon content (not centered)
  - UPPERCASE button text
- On tap: adds trigger and shows SnackBar "Sent In-App Message: {type}"

Tooltip should explain each IAM type.
```

### Prompt 2.6 - Aliases Section

```
Aliases Section (placed after Send In-App Message):
- Section title: "Aliases" with info icon for tooltip
- List showing key-value pairs (read-only, no delete icons)
- Each item shows: Label | ID
- Filter out "external_id" and "onesignal_id" from display (these are special)
- "No Aliases Added" text when empty
- ADD button -> PairInputDialog with empty Label and ID fields (single add)
- ADD MULTIPLE button -> MultiPairInputDialog (dynamic rows, add/remove)
- No remove/delete functionality (aliases are add-only from the UI)
```

### Prompt 2.7 - Emails Section

```
Emails Section:
- Section title: "Emails" with info icon for tooltip
- List showing email addresses
- Each item shows email with delete icon
- "No Emails Added" text when empty
- ADD EMAIL button -> dialog with empty email field
- Collapse behavior when >5 items:
  - Show first 5 items
  - Show "X more" text (tappable)
  - Expand to show all when tapped
```

### Prompt 2.8 - SMS Section

```
SMS Section:
- Section title: "SMS" with info icon for tooltip
- List showing phone numbers
- Each item shows phone number with delete icon
- "No SMS Added" text when empty
- ADD SMS button -> dialog with empty SMS field
- Collapse behavior when >5 items (same as Emails)
```

### Prompt 2.9 - Tags Section

```
Tags Section:
- Section title: "Tags" with info icon for tooltip
- List showing key-value pairs
- Each item shows: Key | Value with delete icon
- "No Tags Added" text when empty
- ADD button -> PairInputDialog with empty Key and Value fields (single add)
- ADD MULTIPLE button -> MultiPairInputDialog (dynamic rows)
- REMOVE SELECTED button:
  - Only visible when at least one tag exists
  - Opens MultiSelectRemoveDialog with checkboxes
```

### Prompt 2.10 - Outcome Events Section

```
Outcome Events Section:
- Section title: "Outcome Events" with info icon for tooltip
- SEND OUTCOME button -> opens dialog with 3 radio options:
  1. Normal Outcome -> shows name input field
  2. Unique Outcome -> shows name input field
  3. Outcome with Value -> shows name and value (double) input fields
```

### Prompt 2.11 - Triggers Section (IN MEMORY ONLY)

```
Triggers Section:
- Section title: "Triggers" with info icon for tooltip
- List showing key-value pairs
- Each item shows: Key | Value with delete icon
- "No Triggers Added" text when empty
- ADD button -> PairInputDialog with empty Key and Value fields (single add)
- ADD MULTIPLE button -> MultiPairInputDialog (dynamic rows)
- Two action buttons (only visible when triggers exist):
  - REMOVE SELECTED -> MultiSelectRemoveDialog with checkboxes
  - CLEAR ALL -> Removes all triggers at once

IMPORTANT: Triggers are stored IN MEMORY ONLY during the app session.
- triggersList is a List<MapEntry<String, String>> in AppViewModel
- Triggers are NOT persisted to SharedPreferences
- Triggers are cleared when the app is killed/restarted
- This is intentional - triggers are transient test data for IAM testing
```

### Prompt 2.12 - Track Event Section

```
Track Event Section:
- Section title: "Track Event" with info icon for tooltip
- TRACK EVENT button -> opens TrackEventDialog with:
  - "Event Name" label + empty input field (required, shows error if empty on submit)
  - "Properties (optional, JSON)" label + input field with placeholder hint {"key": "value"}
    - If non-empty and not valid JSON, shows "Invalid JSON format" error on the field
    - If valid JSON, parsed via jsonDecode and converted to Map<String, dynamic> for the SDK call
    - If empty, passes null
  - TRACK button disabled until name is filled AND JSON is valid (or empty)
- Calls OneSignal.User.trackEvent(name, properties)
```

### Prompt 2.13 - Location Section

```
Location Section:
- Section title: "Location" with info icon for tooltip
- Location Shared toggle switch:
  - Label: "Location Shared"
  - Description: "Share device location with OneSignal"
- PROMPT LOCATION button
```

### Prompt 2.14 - Secondary Activity

```
Secondary Activity (launched by "Next Activity" button at bottom of main screen):
- Activity title: "Secondary Activity"
- Page content: centered text "Secondary Activity" using headlineMedium style
- Simple screen, no additional functionality needed
```

---

## Phase 3: View User API Integration

### Prompt 3.1 - Data Loading Flow

```
Loading indicator overlay:
- Full-screen semi-transparent overlay with centered CircularProgressIndicator
- isLoading flag in AppViewModel
- Show/hide via Stack + Visibility based on isLoading state
- IMPORTANT: Add 100ms delay after populating data before dismissing loading indicator
  - This ensures UI has time to render
  - Use await Future.delayed(const Duration(milliseconds: 100)) after setting state

On cold start:
- Check if OneSignal onesignalId is not null (via getOnesignalId())
- If exists: show loading -> call fetchUserDataFromApi() -> populate UI -> delay 100ms -> hide loading
- If null: just show empty state (no loading indicator)

On login (LOGIN USER / SWITCH USER):
- Show loading indicator immediately
- Call OneSignal.login(externalUserId)
- Clear old user data (aliases, emails, sms, triggers)
- Wait for onUserStateChange callback
- onUserStateChange calls fetchUserDataFromApi()
- fetchUserDataFromApi() populates UI, delays 100ms, then hides loading

On logout:
- Show loading indicator
- Call OneSignal.logout()
- Clear local lists (aliases, emails, sms, triggers)
- Hide loading indicator

On onUserStateChange callback:
- Call fetchUserDataFromApi() to sync with server state
- Update UI with new data (aliases, tags, emails, sms)

Note: REST API key is NOT required for fetchUser endpoint.
```

### Prompt 3.2 - UserData Model

```
class UserData {
  final Map<String, String> aliases;    // From identity object (filter out external_id, onesignal_id)
  final Map<String, String> tags;       // From properties.tags object
  final List<String> emails;            // From subscriptions where type=="Email" -> token
  final List<String> smsNumbers;        // From subscriptions where type=="SMS" -> token
  final String? externalId;             // From identity.external_id

  const UserData({
    required this.aliases,
    required this.tags,
    required this.emails,
    required this.smsNumbers,
    this.externalId,
  });

  factory UserData.fromJson(Map<String, dynamic> json) { ... }
}
```

---

## Phase 4: Info Tooltips

### Prompt 4.1 - Tooltip Content (Remote)

```
Tooltip content is fetched at runtime from the sdk-shared repo. Do NOT bundle a local copy.

URL:
https://raw.githubusercontent.com/OneSignal/sdk-shared/main/demo/tooltip_content.json

This file is maintained in the sdk-shared repo and shared across all platform demo apps.
```

### Prompt 4.2 - Tooltip Helper

```
Create TooltipHelper as a singleton:

class TooltipHelper {
  static final TooltipHelper _instance = TooltipHelper._internal();
  factory TooltipHelper() => _instance;
  TooltipHelper._internal();

  Map<String, TooltipData> _tooltips = {};
  bool _initialized = false;

  static const _tooltipUrl =
      'https://raw.githubusercontent.com/OneSignal/sdk-shared/main/demo/tooltip_content.json';

  Future<void> init() async {
    if (_initialized) return;

    try {
      // Fetch tooltip_content.json from _tooltipUrl using http.get
      // Parse JSON into _tooltips map
      // On failure (no network, etc.), leave _tooltips empty — tooltips are non-critical
    } catch (_) {}

    _initialized = true;
  }

  TooltipData? getTooltip(String key) => _tooltips[key];
}

class TooltipData {
  final String title;
  final String description;
  final List<TooltipOption>? options;

  const TooltipData({required this.title, required this.description, this.options});
}

class TooltipOption {
  final String name;
  final String description;

  const TooltipOption({required this.name, required this.description});
}
```

### Prompt 4.3 - Tooltip UI Integration

```
For each section, pass an onInfoTap callback to SectionCard:
- SectionCard has an optional info icon that calls onInfoTap when tapped
- In HomeScreen, wire onInfoTap to show a TooltipDialog
- TooltipDialog displays title, description, and options (if present)

Example in HomeScreen:
AliasesSection(
    ...,
    onInfoTap: () => _showTooltipDialog(context, 'aliases'),
)

void _showTooltipDialog(BuildContext context, String key) {
    final tooltip = TooltipHelper().getTooltip(key);
    if (tooltip != null) {
        showDialog(
            context: context,
            builder: (_) => TooltipDialog(tooltip: tooltip),
        );
    }
}
```

---

## Phase 5: Data Persistence & Initialization

### What IS Persisted (SharedPreferences)

```
PreferencesService stores:
- OneSignal App ID
- Consent required status
- Privacy consent status
- External user ID (for login state restoration)
- Location shared status
- In-app messaging paused status
```

### Initialization Flow

```
On app startup, state is restored in two layers:

1. main.dart restores SDK state from SharedPreferences cache BEFORE initialize:
   - OneSignal.consentRequired(cachedConsentRequired)
   - OneSignal.consentGiven(cachedPrivacyConsent)
   - OneSignal.initialize(appId)
   Then AFTER initialize, restores remaining SDK state:
   - OneSignal.InAppMessages.paused(cachedPausedStatus)
   - OneSignal.Location.setShared(cachedLocationShared)
   This ensures consent settings are in place before the SDK initializes.

2. AppViewModel.loadInitialState() reads UI state from the SDK (not SharedPreferences):
   - consentRequired from cached prefs (no SDK getter)
   - privacyConsentGiven from cached prefs (no SDK getter)
   - inAppMessagesPaused from OneSignal.InAppMessages.arePaused()
   - locationShared from OneSignal.Location.isShared()
   - externalUserId from OneSignal.User.getExternalId()
   - appId from PreferencesService (app-level config)

This two-layer approach ensures:
- The SDK is configured with the user's last preferences before anything else runs
- The ViewModel reads the SDK's actual state as the source of truth for the UI
- The UI always reflects what the SDK reports, not stale cache values
```

### What is NOT Persisted (In-Memory Only)

```
AppViewModel holds in memory:
- triggersList: List<MapEntry<String, String>>
  - Triggers are session-only
  - Cleared on app restart
  - Used for testing IAM trigger conditions

- aliasesList:
  - Populated from REST API on each session start
  - When user adds alias locally, added to list immediately (SDK syncs async)
  - Fetched fresh via fetchUserDataFromApi() on login/app start

- emailsList, smsNumbersList:
  - Populated from REST API on each session
  - Not cached locally
  - Fetched fresh via fetchUserDataFromApi()

- tagsList:
  - Can be read from SDK via getTags()
  - Also fetched from API for consistency
```

---

## Phase 6: Testing Values (Appium Compatibility)

```
All dialog input fields should be EMPTY by default.
The test automation framework (Appium) will enter these values:

- Login Dialog: External User Id = "test"
- Add Alias Dialog: Key = "Test", Value = "Value"
- Add Multiple Aliases Dialog: Key = "Test", Value = "Value" (first row; supports multiple rows)
- Add Email Dialog: Email = "test@onesignal.com"
- Add SMS Dialog: SMS = "123-456-5678"
- Add Tag Dialog: Key = "Test", Value = "Value"
- Add Multiple Tags Dialog: Key = "Test", Value = "Value" (first row; supports multiple rows)
- Add Trigger Dialog: Key = "trigger_key", Value = "trigger_value"
- Add Multiple Triggers Dialog: Key = "trigger_key", Value = "trigger_value" (first row; supports multiple rows)
- Outcome Dialog: Name = "test_outcome", Value = "1.5"
- Track Event Dialog: Name = "test_event", Properties = "{\"key\": \"value\"}"
- Custom Notification Dialog: Title = "Test Title", Body = "Test Body"
```

---

## Phase 7: Important Implementation Details

### Alias Management

```
Aliases are managed with a hybrid approach:

1. On app start/login: Fetched from REST API via fetchUserDataFromApi()
2. When user adds alias locally:
   - Call OneSignal.User.addAlias(label, id) - syncs to server async
   - Immediately add to local aliasesList (don't wait for API)
   - This ensures instant UI feedback while SDK syncs in background
3. On next app launch: Fresh data from API includes the synced alias
```

### Notification Permission

```
Notification permission is automatically requested when the home screen loads:
- Call viewModel.promptPush() in initState() of HomeScreen
- This ensures prompt appears after user sees the app UI
- PROMPT PUSH button remains as fallback if user initially denied
- Button hidden once permission is granted
```

---

## Phase 8: Flutter Architecture

### Prompt 8.1 - State Management with Provider

```
Use Provider for dependency injection and ChangeNotifier for state management.

main.dart:
- ChangeNotifierProvider<AppViewModel> at the root of the widget tree
- Initialize OneSignal SDK before runApp()
- Fetch tooltips in the background (non-blocking)

AppViewModel extends ChangeNotifier:
- Holds all UI state as private fields with public getters
- Exposes action methods that update state and call notifyListeners()
- Receives OneSignalRepository via constructor injection
- Receives PreferencesService via constructor injection
```

### Prompt 8.2 - Reusable Widgets

```
Create reusable widgets in lib/widgets/:

section_card.dart:
- Card with title Text and optional info IconButton
- Column child slot
- onInfoTap callback for tooltips
- Consistent padding and styling

toggle_row.dart:
- Label, optional description, Switch
- Row layout with MainAxisAlignment.spaceBetween

action_button.dart:
- PrimaryButton (filled, primary color background)
- DestructiveButton (outlined, red accent)
- Full-width buttons with SizedBox(width: double.infinity)

list_widgets.dart:
- PairItem (key-value with optional delete IconButton)
- SingleItem (single value with delete IconButton)
- EmptyState (centered "No items" Text)
- CollapsibleList (shows 5 items, expandable)
- PairList (simple list of key-value pairs)

loading_overlay.dart:
- Semi-transparent full-screen overlay using Stack + Container
- Centered CircularProgressIndicator
- Shown via isLoading state from AppViewModel

dialogs.dart:
- All dialogs use insetPadding: EdgeInsets.symmetric(horizontal: 16) and SizedBox(width: double.maxFinite) on content for full-width layout
- SingleInputDialog (one TextField)
- PairInputDialog (key-value TextFields, single pair)
- MultiPairInputDialog (dynamic rows with dividers between them, X icon to delete a row, full-width dialog, batch submit)
- MultiSelectRemoveDialog (CheckboxListTile for batch remove)
- LoginDialog, OutcomeDialog, TrackEventDialog
- CustomNotificationDialog, TooltipDialog
```

### Prompt 8.3 - Reusable Multi-Pair Dialog

```
Tags, Aliases, and Triggers all share a reusable MultiPairInputDialog widget
for adding multiple key-value pairs at once.

Behavior:
- Dialog opens full-width (insetPadding: EdgeInsets.symmetric(horizontal: 16))
- Starts with one empty key-value row (Key and Value fields side by side)
- "Add Row" TextButton below the rows adds another empty row
- Dividers separate each row for visual clarity
- Each row shows an X (Icons.close) delete button on the right (hidden when only one row)
- "Add All" button is disabled until ALL key and value fields in every row are filled
- Validation runs on every text change and after row add/remove
- On "Add All" press, all rows are collected and submitted as a batch
- Batch operations use SDK bulk APIs (addAliases, addTags, addTriggers)
- TextEditingControllers are properly disposed in the StatefulWidget

Used by:
- ADD MULTIPLE button (Aliases section) -> calls viewModel.addAliases(pairs)
- ADD MULTIPLE button (Tags section) -> calls viewModel.addTags(pairs)
- ADD MULTIPLE button (Triggers section) -> calls viewModel.addTriggers(pairs)
```

### Prompt 8.4 - Reusable Remove Multi Dialog

```
Tags and Triggers share a reusable MultiSelectRemoveDialog widget
for selectively removing items from the current list.

Behavior:
- Accepts the current list of items as List<MapEntry<String, String>>
- Renders one Checkbox per item on the left with just the key as the label (not "key: value")
- User can check 0, 1, or more items
- "Remove (N)" button shows count of selected items, disabled when none selected
- On confirm, checked items' keys are collected as List<String> and passed to the callback

Used by:
- REMOVE SELECTED button (Tags section) -> calls viewModel.removeSelectedTags(keys)
- REMOVE SELECTED button (Triggers section) -> calls viewModel.removeSelectedTriggers(keys)
```

### Prompt 8.5 - Theme

```
Create OneSignal theme in lib/theme.dart:

Colors:
- oneSignalRed = Color(0xFFE54B4D) (primary)
- oneSignalGreen = Color(0xFF34A853) (success)
- oneSignalGreenLight = Color(0xFFE6F4EA) (success background)
- lightBackground = Color(0xFFF8F9FA)
- cardBackground = Colors.white
- dividerColor = Color(0xFFE8EAED)
- warningBackground = Color(0xFFFFF8E1)

AppTheme class with static ThemeData get light:
- useMaterial3: true
- ColorScheme.fromSeed with OneSignalRed as seed
- Override primary to oneSignalRed
- Custom CardTheme with rounded corners (12dp)
- Custom ElevatedButtonTheme with rounded corners (8dp)
- Custom InputDecorationTheme with OutlineInputBorder
```

### Prompt 8.6 - Log View (Appium-Ready)

```
Add collapsible log view at top of screen for debugging and Appium testing.

Files:
- lib/services/log_manager.dart - Singleton logger
- lib/widgets/log_view.dart - Log viewer widget with Semantics labels

LogManager Features:
- Singleton with ChangeNotifier for reactive UI updates
- Thread-safe (all updates on main isolate via Flutter's single-thread model)
- API: LogManager().d(tag, message), .i(), .w(), .e() mimics debugPrint levels
- Also prints to console via debugPrint for development

LogView Features:
- STICKY at the top of the screen (always visible while scrolling content below)
- Full width, no horizontal margin, no rounded corners, no top margin (touches appbar)
- Background color: 0xFF1A1B1E
- Single horizontal scroll on the entire log list (not per-row), no text truncation
- Use LayoutBuilder + ConstrainedBox(minWidth) so content is at least screen-wide
- Use vertical SingleChildScrollView + Column instead of ListView.builder (100dp container is small)
- Fixed 100dp height
- Default expanded
- Trash icon button (Icons.delete) for clearing logs, not a text button
- Auto-scroll to newest using ScrollController

Appium Semantic Labels:
| Label | Description |
|-------|-------------|
| log_view_container | Main container |
| log_view_header | Tappable expand/collapse |
| log_view_count | Shows "(N)" log count |
| log_view_clear_button | Clear all logs |
| log_view_list | Scrollable ListView |
| log_view_empty | "No logs yet" state |
| log_entry_N | Each log row (N=index) |
| log_entry_N_timestamp | Timestamp text |
| log_entry_N_level | D/I/W/E indicator |
| log_entry_N_message | Log message content |

Use Semantics widget with label property for Appium accessibility:
Semantics(label: 'log_entry_${index}_message', child: Text(entry.message))
```

### Prompt 8.7 - SnackBar Messages

```
All user actions should display SnackBar messages:

- Login: "Logged in as: {userId}"
- Logout: "Logged out"
- Add alias: "Alias added: {label}"
- Add multiple aliases: "{count} alias(es) added"
- Similar patterns for tags, triggers, emails, SMS
- Notifications: "Notification sent: {type}" or "Failed to send notification"
- In-App Messages: "Sent In-App Message: {type}"
- Outcomes: "Outcome sent: {name}"
- Events: "Event tracked: {name}"
- Location: "Location sharing enabled/disabled"
- Push: "Push enabled/disabled"

Implementation:
- AppViewModel exposes a snackBarMessage stream or ValueNotifier<String?>
- HomeScreen listens and shows ScaffoldMessenger.of(context).showSnackBar()
- All SnackBar messages are also logged via LogManager().i()
- Clear previous SnackBar before showing new one via ScaffoldMessenger.of(context).clearSnackBars()
```

---

## Key Files Structure

```
examples/demo/
├── lib/
│   ├── main.dart                        # App entry, SDK init, Provider setup
│   ├── theme.dart                       # OneSignal Material 3 theme
│   ├── models/
│   │   ├── user_data.dart               # UserData model from API
│   │   ├── notification_type.dart       # Enum with bigPicture and iosAttachments
│   │   └── in_app_message_type.dart     # Enum with Material icons
│   ├── services/
│   │   ├── onesignal_api_service.dart   # REST API client (http)
│   │   ├── preferences_service.dart     # SharedPreferences wrapper
│   │   ├── tooltip_helper.dart          # Fetches tooltips from remote URL
│   │   └── log_manager.dart             # Singleton logger with ChangeNotifier
│   ├── repositories/
│   │   └── onesignal_repository.dart    # Centralized SDK calls
│   ├── viewmodels/
│   │   └── app_viewmodel.dart           # ChangeNotifier with all UI state
│   ├── screens/
│   │   ├── home_screen.dart             # Main scrollable screen (includes LogView)
│   │   └── secondary_screen.dart        # "Secondary Activity" page
│   └── widgets/
│       ├── section_card.dart            # Card with title and info icon
│       ├── toggle_row.dart              # Label + Switch
│       ├── action_button.dart           # Primary/Destructive buttons
│       ├── list_widgets.dart            # PairList, SingleList, EmptyState
│       ├── loading_overlay.dart         # Full-screen loading spinner
│       ├── log_view.dart                # Collapsible log viewer (Appium-ready)
│       ├── dialogs.dart                 # All dialog widgets
│       └── sections/
│           ├── app_section.dart         # App ID, consent, login/logout
│           ├── push_section.dart        # Push subscription controls
│           ├── send_push_section.dart   # Send notification buttons
│           ├── in_app_section.dart      # IAM pause toggle
│           ├── send_iam_section.dart    # Send IAM buttons with icons
│           ├── aliases_section.dart     # Alias management
│           ├── emails_section.dart      # Email management
│           ├── sms_section.dart         # SMS management
│           ├── tags_section.dart        # Tag management
│           ├── outcomes_section.dart    # Outcome events
│           ├── triggers_section.dart    # Trigger management (in-memory)
│           ├── track_event_section.dart # Event tracking with JSON
│           └── location_section.dart    # Location controls
├── android/
│   └── app/
│       └── src/main/
│           └── AndroidManifest.xml      # Package: com.onesignal.example
├── ios/
│   └── Runner/
│       └── Info.plist
├── pubspec.yaml                         # Dependencies
├── google-services.json                 # Firebase config (Android)
└── agconnect-services.json              # Huawei config (Android, if needed)
```

Note:
- All UI is Flutter widgets (no platform-specific UI)
- Tooltip content is fetched from remote URL (not bundled locally)
- LogView at top of screen displays SDK and app logs for debugging/Appium testing
- Provider is used at the root for dependency injection and state management

---

## Configuration

### App ID Placeholder

```dart
// In main.dart or a constants file
const String oneSignalAppId = '77e32082-ea27-42e3-a898-c72e141824ef';
```

Note: REST API key is NOT required for the fetchUser endpoint.

### Package / Bundle Identifier

The identifiers MUST be `com.onesignal.example` to work with the existing:
- `google-services.json` (Firebase configuration)
- `agconnect-services.json` (Huawei configuration)

If you change the identifier, you must also update these files with your own Firebase/Huawei project configuration.

---

## Flutter Best Practices Applied

- **const constructors** on all stateless widgets and immutable data classes
- **Provider** for dependency injection and reactive state, avoiding global mutable state
- **Single responsibility** per file: one widget/class per file, sections split into their own files
- **TextEditingController disposal** in all StatefulWidgets that create controllers
- **Keys** on list items via ValueKey for efficient rebuilds
- **Semantics** widgets for accessibility and Appium test automation
- **async/await** over raw Future chaining for readability
- **Immutable state** where possible; lists exposed as unmodifiable views from the ViewModel
- **Material 3** theming with ColorScheme.fromSeed for consistent design tokens
- **Minimal rebuilds** by using Consumer/Selector from Provider to scope rebuilds
- **Error handling** with try/catch on all network and SDK async calls
- **No platform channels needed** since the OneSignal Flutter SDK handles all bridging

---

## Summary

This app demonstrates all OneSignal Flutter SDK features:
- User management (login/logout, aliases with batch add)
- Push notifications (subscription, sending with images, auto-permission prompt)
- Email and SMS subscriptions
- Tags for segmentation (batch add/remove support)
- Triggers for in-app message targeting (in-memory only, batch operations)
- Outcomes for conversion tracking
- Event tracking with JSON properties validation
- In-app messages (display testing with type-specific icons)
- Location sharing
- Privacy consent management

The app is designed to be:
1. **Testable** - Empty dialogs with Semantics labels for Appium automation
2. **Comprehensive** - All SDK features demonstrated
3. **Clean** - Repository pattern with Provider-based state management
4. **Cross-platform** - Single codebase for Android and iOS
5. **Session-based triggers** - Triggers stored in memory only, cleared on restart
6. **Responsive UI** - Loading indicator with delay to ensure UI populates before dismissing
7. **Performant** - Tooltip JSON loaded asynchronously, const widgets, scoped rebuilds
8. **Modern UI** - Material 3 theming with reusable widget components
9. **Batch Operations** - Add multiple items at once, select and remove multiple items
