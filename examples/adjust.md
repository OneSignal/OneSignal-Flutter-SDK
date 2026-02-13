## Visual Comparison & Adjustment

### Overview

```
Two Android emulators should be running side by side:
  1. Reference emulator — has the existing native OneSignal demo app installed
  2. Flutter emulator — running the new Flutter demo app from examples/demo/

The goal is to visually compare the Flutter app against the reference app
section by section, then fix any inconsistencies in layout, spacing, colors,
section order, typography, dialog flows, or overall look and feel.
```

### Identify the emulators

```
Run `adb devices` to list connected emulators. You should see two entries.
Identify which is the reference app and which is the Flutter demo.

A common setup:
  emulator-5554 -> reference (native Android demo)
  emulator-5556 -> Flutter demo

Your emulator names may differ. Use whatever names appear in `adb devices`.
Assign them to variables for the steps below:

  REF=emulator-5554
  FLUTTER=emulator-5556

(Adjust these to match your actual device names.)
```

### Launch both apps

```
Launch the reference app on the reference emulator:
  adb -s $REF shell am start -n com.onesignal.sdktest/.ui.main.MainActivity

The Flutter app should already be running on the other emulator. If not:
  cd examples/demo && flutter run -d $FLUTTER

Before capturing screenshots, dismiss any in-app messages showing on
either emulator. Tap the X or click-through button on each IAM until
both apps show their main UI with no overlays.

Then pause in-app messages on both emulators so new IAMs don't
interrupt the comparison. Scroll to the "In-App Messaging" section
on each emulator and toggle "Pause In-App Messages" on.
```

### Capture and compare screenshots

```
Create output directories:
  mkdir -p /tmp/onesignal_reference /tmp/onesignal_flutter

Capture screenshots from both emulators at the same scroll position.
Repeat this pattern while scrolling through each section of the app:

1. Capture the current viewport from both:
     adb -s $REF shell screencap -p /sdcard/ref_01.png && adb -s $REF pull /sdcard/ref_01.png /tmp/onesignal_reference/ref_01.png
     adb -s $FLUTTER shell screencap -p /sdcard/flutter_01.png && adb -s $FLUTTER pull /sdcard/flutter_01.png /tmp/onesignal_flutter/flutter_01.png

2. Scroll both down by roughly one viewport:
     adb -s $REF shell input swipe 500 1500 500 500
     adb -s $FLUTTER shell input swipe 500 1500 500 500

3. Capture the next pair (ref_02/flutter_02, ref_03/flutter_03, etc.)

4. Repeat until you have covered all sections from top to bottom.

Compare each pair of screenshots side by side. Look for differences in:
  - Section order and grouping
  - Card spacing and padding
  - Button styles, sizes, and colors
  - Typography (font size, weight, color)
  - Toggle/switch alignment
  - List item layout (key-value pairs, delete icons)
  - Empty state text
  - Dialog layout and field arrangement
  - Logs section styling (background colors, text colors, header style)
    must match the reference app screenshots

To inspect specific UI elements or flows on either emulator:

Dump the UI hierarchy:
  adb -s $REF shell uiautomator dump /sdcard/ui.xml && adb -s $REF pull /sdcard/ui.xml /tmp/onesignal_reference/ui.xml
  adb -s $FLUTTER shell uiautomator dump /sdcard/ui.xml && adb -s $FLUTTER pull /sdcard/ui.xml /tmp/onesignal_flutter/ui.xml

Tap an element by coordinates:
  adb -s $FLUTTER shell input tap <centerX> <centerY>

Type into a focused field:
  adb -s $FLUTTER shell input text "test"

Example: compare the "Add Tag" dialog flow on both emulators,
then verify the tag list looks the same after adding a tag.

Also compare key dialogs on both emulators:
  - Add Alias (single pair input)
  - Add Multiple Aliases/Tags (dynamic rows with add/remove)
  - Remove Selected Tags (checkbox multi-select)
  - Login User
  - Send Outcome (radio options)
  - Track Event (with JSON properties field)
  - Custom Notification (title + body)
Open each dialog on both emulators, screenshot, and compare field layout,
button placement, spacing, and validation behavior.
```

### Fix inconsistencies

```
After comparing, update the Flutter demo source code in examples/demo/lib/
to fix any visual differences. Common things to adjust:

  - Padding/margin values in section widgets
  - Font sizes or weights in theme.dart or individual sections
  - Button colors or styles in action_button.dart
  - Card elevation or border radius in theme.dart
  - Section ordering in home_screen.dart
  - Dialog field layout in dialogs.dart

After each fix, hot reload (press 'r' in the Flutter terminal) and
re-capture the Flutter screenshot to verify the change matches the reference.
```
