# OneSignal Sample App V2 - Build Guide

This document contains all the prompts and requirements needed to build the OneSignal Sample App V2 from scratch. Give these prompts to an AI assistant or follow them manually to recreate the app.

---

## Phase 1: Initial Setup

### Prompt 1.1 - Project Foundation

```
Build a sample Android app with:
- MVVM architecture with Jetpack Compose UI
- Kotlin Coroutines for background threading (Dispatchers.IO, Dispatchers.Main)
- Gradle Kotlin DSL with buildSrc for type-safe dependency management
- Support for Google FCM and Huawei HMS product flavors (matching existing OneSignalDemo setup)
- Package name: com.onesignal.sdktest (must match google-services.json and agconnect-services.json)
- All dialogs should have EMPTY input fields (for Appium testing - test framework enters values)
- Material3 theming with OneSignal brand colors
```

### Prompt 1.2 - OneSignal Code Organization

```
Centralize all OneSignal SDK calls in a single OneSignalRepository.kt class:

User operations:
- loginUser(externalUserId: String)
- logoutUser()

Alias operations:
- addAlias(label: String, id: String)
- addAliases(aliases: Map<String, String>)  // Batch add

Email operations:
- addEmail(email: String)
- removeEmail(email: String)

SMS operations:
- addSms(smsNumber: String)
- removeSms(smsNumber: String)

Tag operations:
- addTag(key: String, value: String)
- addTags(tags: Map<String, String>)  // Batch add
- removeTag(key: String)
- removeTags(keys: Collection<String>)  // Batch remove
- getTags(): Map<String, String>

Trigger operations:
- addTrigger(key: String, value: String)
- addTriggers(triggers: Map<String, String>)  // Batch add
- removeTrigger(key: String)
- clearTriggers(keys: Collection<String>)

Outcome operations:
- sendOutcome(name: String)
- sendUniqueOutcome(name: String)
- sendOutcomeWithValue(name: String, value: Float)

Track Event:
- trackEvent(name: String, properties: Map<String, Any?>?)  // Properties as parsed JSON map

Push subscription:
- getPushSubscriptionId(): String?
- isPushEnabled(): Boolean
- setPushEnabled(enabled: Boolean)

In-App Messages:
- setInAppMessagesPaused(paused: Boolean)
- isInAppMessagesPaused(): Boolean

Location:
- setLocationShared(shared: Boolean)
- isLocationShared(): Boolean
- promptLocation()

Privacy consent:
- setConsentRequired(required: Boolean)
- getConsentRequired(): Boolean
- setPrivacyConsent(granted: Boolean)
- getPrivacyConsent(): Boolean

Notification sending (via REST API, delegated to OneSignalService):
- sendNotification(type: NotificationType): Boolean
- sendCustomNotification(title: String, body: String): Boolean
- fetchUser(onesignalId: String): UserData?
```

### Prompt 1.3 - OneSignalService (REST API Client)

```
Create OneSignalService.kt object for REST API calls:

Properties:
- appId: String (set from MainApplication)

Methods:
- setAppId(appId: String)
- getAppId(): String
- sendNotification(type: NotificationType): Boolean
- sendCustomNotification(title: String, body: String): Boolean
- fetchUser(onesignalId: String): UserData?

sendNotification endpoint:
- POST https://onesignal.com/api/v1/notifications
- Accept header: "application/vnd.onesignal.v1+json"
- Uses include_subscription_ids (not include_player_ids)
- Includes big_picture for image notifications

fetchUser endpoint:
- GET https://api.onesignal.com/apps/{app_id}/users/by/onesignal_id/{onesignal_id}
- NO Authorization header needed (public endpoint)
- Returns UserData with aliases, tags, emails, smsNumbers, externalId
```

### Prompt 1.4 - SDK Observers

```
In MainApplication.kt, set up OneSignal listeners:
- IInAppMessageLifecycleListener (onWillDisplay, onDidDisplay, onWillDismiss, onDidDismiss)
- IInAppMessageClickListener
- INotificationClickListener
- INotificationLifecycleListener (with preventDefault() for async display testing)
- IUserStateObserver (log when user state changes)
- After registering listeners, restore cached SDK states from SharedPreferences:
  - OneSignal.InAppMessages.paused = cached paused status
  - OneSignal.Location.isShared = cached location shared status

In MainViewModel.kt, implement observers:
- IPushSubscriptionObserver - react to push subscription changes
- IPermissionObserver - react to notification permission changes
- IUserStateObserver - call fetchUserDataFromApi() when user changes (login/logout)
```

---

## Phase 2: UI Sections

### Section Order (top to bottom) - FINAL

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
14. **Next Activity Button**

### Prompt 2.1 - App Section

```
App Section layout:

1. App ID display (readonly Text showing the OneSignal App ID)

2. Sticky guidance banner below App ID:
   - Text: "Add your own App ID, then rebuild to fully test all functionality."
   - Link text: "Get your keys at onesignal.com" (clickable, opens browser)
   - Light background color to stand out

3. Consent card with up to two toggles:
   a. "Consent Required" toggle (always visible):
      - Label: "Consent Required"
      - Description: "Require consent before SDK processes data"
      - Sets OneSignal.consentRequired
   b. "Privacy Consent" toggle (only visible when Consent Required is ON):
      - Label: "Privacy Consent"
      - Description: "Consent given for data collection"
      - Sets OneSignal.consentGiven
      - Separated from the above toggle by a horizontal divider
   - NOT a blocking overlay - user can interact with app regardless of state

4. "Logged in as" display (ABOVE the buttons, only visible when logged in):
   - Prominent green Card background (#E8F5E9)
   - "Logged in as:" label
   - External User ID displayed large and centered (bold, green #2E7D32)
   - Positioned ABOVE the Login/Switch User button

5. LOGIN USER button:
   - Shows "LOGIN USER" when no user is logged in
   - Shows "SWITCH USER" when a user is logged in
   - Opens dialog with empty "External User Id" field

6. LOGOUT USER button
```

### Prompt 2.2 - Push Section

```
Push Section:
- Section title: "Push" with info icon for tooltip
- Push Subscription ID display (readonly)
- Enabled toggle switch (controls optIn/optOut)
- Notification permission is automatically requested when MainActivity loads
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
  1. SIMPLE - sends basic notification with title/body
  2. WITH IMAGE - sends notification with big picture
     (use https://media.onesignal.com/automated_push_templates/ratings_template.png)
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
  1. TOP BANNER - VerticalAlignTop icon
  2. BOTTOM BANNER - VerticalAlignBottom icon
  3. CENTER MODAL - CropSquare icon
  4. FULL SCREEN - Fullscreen icon
- Button styling:
  - RED background color (#E9444E)
  - WHITE text
  - Type-specific icon on LEFT side only (no right side icon)
  - Full width of the card
- On click: adds trigger and shows toast "Sent In-App Message: {type}"

Tooltip should explain each IAM type.
```

### Prompt 2.6 - Aliases Section

```
Aliases Section (placed after Send In-App Message):
- Section title: "Aliases" with info icon for tooltip
- Compose list showing key-value pairs (read-only, no delete icons)
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
- Compose list showing email addresses
- Each item shows email with delete icon
- "No Emails Added" text when empty
- ADD EMAIL button -> dialog with empty email field
- Collapse behavior when >5 items:
  - Show first 5 items
  - Show "X more" text (clickable)
  - Expand to show all when clicked
```

### Prompt 2.8 - SMS Section

```
SMS Section:
- Section title: "SMS" with info icon for tooltip
- Compose list showing phone numbers
- Each item shows phone number with delete icon
- "No SMS Added" text when empty
- ADD SMS button -> dialog with empty SMS field
- Collapse behavior when >5 items (same as Emails)
```

### Prompt 2.9 - Tags Section

```
Tags Section:
- Section title: "Tags" with info icon for tooltip
- Compose list showing key-value pairs
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
  3. Outcome with Value -> shows name and value (float) input fields
```

### Prompt 2.11 - Triggers Section (IN MEMORY ONLY)

```
Triggers Section:
- Section title: "Triggers" with info icon for tooltip
- Compose list showing key-value pairs
- Each item shows: Key | Value with delete icon
- "No Triggers Added" text when empty
- ADD button -> PairInputDialog with empty Key and Value fields (single add)
- ADD MULTIPLE button -> MultiPairInputDialog (dynamic rows)
- Two action buttons (only visible when triggers exist):
  - REMOVE SELECTED -> MultiSelectRemoveDialog with checkboxes
  - CLEAR ALL -> Removes all triggers at once

IMPORTANT: Triggers are stored IN MEMORY ONLY during the app session.
- triggersList is a mutableListOf<Pair<String, String>>() in MainViewModel
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
    - If valid JSON, parsed via JSONObject and converted to Map<String, Any?> for the SDK call
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

---

## Phase 3: View User API Integration

### Prompt 3.1 - Data Loading Flow

```
Loading indicator overlay:
- Full-screen semi-transparent overlay with centered spinner
- isLoading LiveData in MainViewModel
- Show/hide based on isLoading state
- IMPORTANT: Add 100ms delay after populating data before dismissing loading indicator
  - This ensures UI has time to render
  - Use kotlinx.coroutines.delay(100) after setting all LiveData values

On cold start:
- Check if OneSignal.User.onesignalId is not null
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
data class UserData(
    val aliases: Map<String, String>,    // From identity object (filter out external_id, onesignal_id)
    val tags: Map<String, String>,        // From properties.tags object
    val emails: List<String>,             // From subscriptions where type="Email" -> token
    val smsNumbers: List<String>,         // From subscriptions where type="SMS" -> token
    val externalId: String?               // From identity.external_id
)
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
Create TooltipHelper.kt:

object TooltipHelper {
    private var tooltips: Map<String, TooltipData> = emptyMap()
    private var initialized = false

    private const val TOOLTIP_URL =
        "https://raw.githubusercontent.com/OneSignal/sdk-shared/main/demo/tooltip_content.json"

    fun init(context: Context) {
        if (initialized) return

        // IMPORTANT: Fetch on background thread to avoid blocking app startup
        CoroutineScope(Dispatchers.IO).launch {
            // Fetch tooltip_content.json from TOOLTIP_URL using HttpURLConnection
            // Parse JSON into tooltips map
            // On failure (no network, etc.), leave tooltips empty — tooltips are non-critical

            withContext(Dispatchers.Main) {
                // Update tooltips map on main thread
                initialized = true
            }
        }
    }

    fun getTooltip(key: String): TooltipData?
}

data class TooltipData(
    val title: String,
    val description: String,
    val options: List<TooltipOption>? = null
)

data class TooltipOption(
    val name: String,
    val description: String
)
```

### Prompt 4.3 - Tooltip UI Integration (Compose)

```
For each section, pass an onInfoClick callback to SectionCard:
- SectionCard has an optional info icon that calls onInfoClick when tapped
- In MainScreen, wire onInfoClick to show a TooltipDialog composable
- TooltipDialog displays title, description, and options (if present)

Example in MainScreen.kt:
AliasesSection(
    ...,
    onInfoClick = { showTooltipDialog = "aliases" }
)

showTooltipDialog?.let { key ->
    val tooltip = TooltipHelper.getTooltip(key)
    if (tooltip != null) {
        TooltipDialog(
            title = tooltip.title,
            description = tooltip.description,
            options = tooltip.options?.map { it.name to it.description },
            onDismiss = { showTooltipDialog = null }
        )
    }
}
```

---

## Phase 5: Data Persistence & Initialization

### What IS Persisted (SharedPreferences)

```
SharedPreferenceUtil.kt stores:
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

1. MainApplication.kt restores SDK state from SharedPreferences cache BEFORE init:
   - OneSignal.consentRequired = SharedPreferenceUtil.getCachedConsentRequired(context)
   - OneSignal.consentGiven = SharedPreferenceUtil.getUserPrivacyConsent(context)
   - OneSignal.initWithContext(this, appId)
   Then AFTER init, restores remaining SDK state:
   - OneSignal.InAppMessages.paused = SharedPreferenceUtil.getCachedInAppMessagingPausedStatus(context)
   - OneSignal.Location.isShared = SharedPreferenceUtil.getCachedLocationSharedStatus(context)
   This ensures consent settings are in place before the SDK initializes.

2. MainViewModel.loadInitialState() reads UI state from the SDK (not SharedPreferences):
   - _consentRequired from repository.getConsentRequired() (reads OneSignal.consentRequired)
   - _privacyConsentGiven from repository.getPrivacyConsent() (reads OneSignal.consentGiven)
   - _inAppMessagesPaused from repository.isInAppMessagesPaused() (reads OneSignal.InAppMessages.paused)
   - _locationShared from repository.isLocationShared() (reads OneSignal.Location.isShared)
   - _externalUserId from OneSignal.User.externalId (empty string means no user logged in)
   - _appId from SharedPreferenceUtil (app-level config, no SDK getter)

This two-layer approach ensures:
- The SDK is configured with the user's last preferences before anything else runs
- The ViewModel reads the SDK's actual state as the source of truth for the UI
- The UI always reflects what the SDK reports, not stale cache values
```

### What is NOT Persisted (In-Memory Only)

```
MainViewModel holds in memory:
- triggersList: MutableList<Pair<String, String>>
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
Notification permission is automatically requested when MainActivity loads:
- Call viewModel.promptPush() at end of onCreate()
- This ensures prompt appears after user sees the app UI
- PROMPT PUSH button remains as fallback if user initially denied
- Button hidden once permission is granted
```

---

## Phase 8: Jetpack Compose Architecture

### Prompt 8.1 - Compose Setup

```
Enable Jetpack Compose in the project:

build.gradle.kts (app):
- buildFeatures { compose = true }
- composeOptions { kotlinCompilerExtensionVersion = "1.5.10" }

Dependencies (via BOM):
- composeBom = "2024.02.00"
- composeUi, composeUiGraphics, composeUiToolingPreview
- composeMaterial3
- composeMaterialIconsExtended (for IAM type icons)
- composeRuntime, composeRuntimeLivedata
- activityCompose
- lifecycleViewModelCompose, lifecycleRuntimeCompose
```

### Prompt 8.2 - Reusable Components

```
Create reusable Compose components in ui/components/:

SectionCard.kt:
- Card with title text and optional info icon
- Column content slot
- OnInfoClick callback for tooltips

ToggleRow.kt:
- Label, optional description, Switch
- Horizontal layout with space between

ActionButton.kt:
- PrimaryButton (filled, primary color background)
- DestructiveButton (outlined, red accent)
- Full-width buttons for consistent styling

ListComponents.kt:
- PairItem (key-value with delete icon)
- SingleItem (single value with delete icon)
- EmptyState (centered "No items" text)
- CollapsibleSingleList (shows 5, expandable)
- PairList (simple list of pairs)

LoadingOverlay.kt:
- Semi-transparent full-screen overlay
- Centered CircularProgressIndicator
- Shown via isLoading state

Dialogs.kt:
- SingleInputDialog (one text field)
- PairInputDialog (key-value fields, single pair)
- MultiPairInputDialog (dynamic rows, add/remove, batch submit)
- MultiSelectRemoveDialog (checkboxes for batch remove)
- LoginDialog, OutcomeDialog, TrackEventDialog
- CustomNotificationDialog, TooltipDialog
```

### Prompt 8.3 - Reusable Multi-Pair Dialog (Compose)

```
Tags, Aliases, and Triggers all share a reusable MultiPairInputDialog composable
for adding multiple key-value pairs at once.

Behavior:
- Dialog opens with one empty key-value row
- "Add Row" button below the rows adds another empty row
- Each row has a remove button (hidden when only one row exists)
- "Add All" button is disabled until ALL key and value fields in every row are filled
- Validation runs on every text change and after row add/remove
- On "Add All" press, all rows are collected and submitted as a batch
- Batch operations use SDK bulk APIs (addAliases, addTags, addTriggers)

Used by:
- ADD MULTIPLE button (Aliases section) -> calls viewModel.addAliases(pairs)
- ADD MULTIPLE button (Tags section) -> calls viewModel.addTags(pairs)
- ADD MULTIPLE button (Triggers section) -> calls viewModel.addTriggers(pairs)
```

### Prompt 8.4 - Reusable Remove Multi Dialog (Compose)

```
Aliases, Tags, and Triggers share a reusable MultiSelectRemoveDialog composable
for selectively removing items from the current list.

Behavior:
- Accepts the current list of items as List<Pair<String, String>>
- Renders one Checkbox per item with label "key: value"
- User can check 0, 1, or more items
- "Remove (N)" button shows count of selected items, disabled when none selected
- On confirm, checked items' keys are collected as Collection<String> and passed to the callback

Used by:
- REMOVE SELECTED button (Tags section) -> calls viewModel.removeSelectedTags(keys)
- REMOVE SELECTED button (Triggers section) -> calls viewModel.removeSelectedTriggers(keys)
```

### Prompt 8.5 - Theme

```
Create OneSignal theme in ui/theme/Theme.kt:

Colors:
- OneSignalRed = #E54B4D (primary)
- OneSignalGreen = #34A853 (success)
- OneSignalGreenLight = #E6F4EA (success background)
- LightBackground = #F8F9FA
- CardBackground = White
- DividerColor = #E8EAED
- WarningBackground = #FFF8E1

OneSignalTheme composable:
- MaterialTheme with LightColorScheme
- Custom Typography with SemiBold weights
- Custom Shapes with rounded corners (8/12/16/24dp)
- Primary = OneSignalRed
- Surface variants for cards
```

### Prompt 8.6 - Log View (Appium-Ready)

```
Add collapsible log view at top of screen for debugging and Appium testing.

Files:
- util/LogManager.kt - Thread-safe pass-through logger
- ui/components/LogView.kt - Compose UI with test tags

LogManager Features:
- Pass-through to Android logcat AND UI display
- Thread-safe (posts to main thread for Compose state)
- Captures SDK logs via OneSignal.Debug.addLogListener
- API: LogManager.d/i/w/e(tag, message) mimics android.util.Log

LogView Features:
- Collapsible header (default expanded)
- 5-line height (~100dp)
- Color-coded by level (Debug=blue, Info=green, Warn=amber, Error=red)
- Clear button
- Auto-scroll to newest

Appium Test Tags:
| Tag | Description |
|-----|-------------|
| log_view_container | Main container |
| log_view_header | Clickable expand/collapse |
| log_view_count | Shows "(N)" log count |
| log_view_clear_button | Clear all logs |
| log_view_list | Scrollable LazyColumn |
| log_view_empty | "No logs yet" state |
| log_entry_N | Each log row (N=index) |
| log_entry_N_timestamp | Timestamp text |
| log_entry_N_level | D/I/W/E indicator |
| log_entry_N_message | Log message content |

SDK Log Integration (MainApplication):
OneSignal.Debug.addLogListener { event ->
    LogManager.log("SDK", event.entry, level)
}

Appium Example:
# Verify a log message exists
log_msg = driver.find_element(By.XPATH, "//*[@resource-id='log_entry_0_message']")
assert "Notification sent" in log_msg.text

# Scroll logs
log_list = driver.find_element(By.XPATH, "//*[@resource-id='log_view_list']")
driver.execute_script("mobile: scroll", {"element": log_list, "direction": "down"})
```

### Prompt 8.7 - Toast Messages

```
All user actions should display toast messages:

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
- MainViewModel has toastMessage: LiveData<String?>
- MainActivity observes and shows Android Toast
- LaunchedEffect triggers on toastMessage change
- All toast messages are also logged via LogManager.info()
```

---

## Key Files Structure

```
Examples/OneSignalDemoV2/
├── buildSrc/
│   └── src/main/kotlin/
│       ├── Versions.kt          # Version constants (includes Compose versions)
│       └── Dependencies.kt      # Dependency strings (includes Compose deps)
├── app/
│   ├── src/main/
│   │   ├── java/com/onesignal/sdktest/
│   │   │   ├── application/
│   │   │   │   └── MainApplication.kt   # SDK init, log listener, observers
│   │   │   ├── data/
│   │   │   │   ├── model/
│   │   │   │   │   ├── NotificationType.kt    # With bigPicture URL
│   │   │   │   │   └── InAppMessageType.kt    # With Material icons
│   │   │   │   ├── network/
│   │   │   │   │   └── OneSignalService.kt    # REST API client
│   │   │   │   └── repository/
│   │   │   │       └── OneSignalRepository.kt
│   │   │   ├── ui/
│   │   │   │   ├── components/                # Reusable Compose components
│   │   │   │   │   ├── SectionCard.kt         # Card with title and info icon
│   │   │   │   │   ├── ToggleRow.kt           # Label + Switch
│   │   │   │   │   ├── ActionButton.kt        # Primary/Destructive buttons
│   │   │   │   │   ├── ListComponents.kt      # PairList, SingleList, EmptyState
│   │   │   │   │   ├── LoadingOverlay.kt      # Full-screen loading spinner
│   │   │   │   │   ├── LogView.kt             # Collapsible log viewer (Appium-ready)
│   │   │   │   │   └── Dialogs.kt             # All dialog composables
│   │   │   │   ├── main/
│   │   │   │   │   ├── MainActivity.kt        # ComponentActivity with setContent
│   │   │   │   │   ├── MainScreen.kt          # Main Compose screen (includes LogView)
│   │   │   │   │   ├── Sections.kt            # Individual section composables
│   │   │   │   │   └── MainViewModel.kt       # With batch operations
│   │   │   │   ├── secondary/
│   │   │   │   │   └── SecondaryActivity.kt   # Simple Compose screen
│   │   │   │   └── theme/
│   │   │   │       └── Theme.kt               # OneSignal Material3 theme
│   │   │   └── util/
│   │   │       ├── SharedPreferenceUtil.kt
│   │   │       ├── LogManager.kt              # Thread-safe pass-through logger
│   │   │       └── TooltipHelper.kt           # Fetches tooltips from remote URL
│   │   └── res/
│   │       └── values/
│   │           ├── strings.xml
│   │           ├── colors.xml
│   │           └── styles.xml
│   └── src/huawei/
│       └── java/com/onesignal/sdktest/notification/
│           └── HmsMessageServiceAppLevel.kt
├── google-services.json
├── agconnect-services.json
└── build_app_prompt.md (this file)
```

Note:
- All UI is Jetpack Compose (no XML layouts)
- Tooltip content is fetched from remote URL (not bundled locally)
- LogView at top of screen displays SDK and app logs for debugging/Appium testing

---

## Configuration

### strings.xml Placeholders

```xml
<!-- Replace with your own OneSignal App ID -->
<string name="onesignal_app_id">YOUR_APP_ID_HERE</string>
```

Note: REST API key is NOT required for the fetchUser endpoint.

### Package Name

The package name MUST be `com.onesignal.sdktest` to work with the existing:
- `google-services.json` (Firebase configuration)
- `agconnect-services.json` (Huawei configuration)

If you change the package name, you must also update these files with your own Firebase/Huawei project configuration.

---

## Summary

This app demonstrates all OneSignal Android SDK features:
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
1. **Testable** - Empty dialogs for Appium automation
2. **Comprehensive** - All SDK features demonstrated
3. **Clean** - MVVM architecture with Jetpack Compose UI
4. **Cross-platform ready** - Tooltip content in JSON for sharing across wrappers
5. **Session-based triggers** - Triggers stored in memory only, cleared on restart
6. **Responsive UI** - Loading indicator with delay to ensure UI populates before dismissing
7. **Performant** - Tooltip JSON loaded on background thread
8. **Modern UI** - Material3 theming with reusable Compose components
9. **Batch Operations** - Add multiple items at once, select and remove multiple items
