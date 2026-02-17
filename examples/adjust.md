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

Layout note: Both apps have a sticky LOGS section pinned at the top.
On both emulators the scrollable content area starts at roughly y=800.
When calculating swipe distances or tap targets, account for this offset.
The screen resolution is 1344x2992 on both emulators, giving a visible
scrollable viewport of about 2200px below the LOGS section.

Use uiautomator to find exact element positions before scrolling or tapping:
  adb -s $REF shell uiautomator dump /sdcard/ui.xml && adb -s $REF pull /sdcard/ui.xml /tmp/onesignal_reference/ui.xml
  adb -s $FLUTTER shell uiautomator dump /sdcard/ui.xml && adb -s $FLUTTER pull /sdcard/ui.xml /tmp/onesignal_flutter/ui.xml

Parse bounds to locate section headers and buttons:
  python3 -c "
  import xml.etree.ElementTree as ET
  tree = ET.parse('/tmp/onesignal_flutter/ui.xml')
  for node in tree.iter():
      d = node.get('content-desc','')
      b = node.get('bounds','')
      if d.strip():
          print(d.split(chr(10))[0][:50], b)
  "

To scroll a specific section header into view, dump the UI hierarchy,
find the nearest visible element, and compute the swipe delta needed
to bring the target section just below the LOGS area (y~800). For example,
if the TAGS header is currently at y=2400 and you want it at y=850:
  delta = 2400 - 850 = 1550
  adb -s $FLUTTER shell input swipe 672 2000 672 450
  (swipe from y=2000 up by ~1550px to y=450)

After scrolling, re-dump the UI hierarchy to confirm the section is now
visible and get updated coordinates before tapping any buttons.

Capture matching screenshots at each scroll position:
  adb -s $REF shell screencap -p /sdcard/ref_01.png && adb -s $REF pull /sdcard/ref_01.png /tmp/onesignal_reference/ref_01.png
  adb -s $FLUTTER shell screencap -p /sdcard/flutter_01.png && adb -s $FLUTTER pull /sdcard/flutter_01.png /tmp/onesignal_flutter/flutter_01.png

Scroll section by section, aligning both emulators so the same section
header sits just below the LOGS area on each, then capture and compare.
Repeat until you have covered all sections from top to bottom.

Compare each pair of screenshots side by side. Look for differences in:
  - Section order and grouping
  - Card spacing and padding
  - Button styles, sizes, and colors
  - Typography (font size, weight, color)
  - Toggle/switch alignment
  - List item layout (key-value pairs, delete icons)
  - Empty state text
  - Dialog layout and field arrangement (ignore dialog width — all Flutter
    dialogs use full-width insetPadding by design)
  - Logs section styling (background colors, text colors, header style)
    must match the reference app screenshots

Tap an element by computing the center of its bounds:
  adb -s $FLUTTER shell input tap <centerX> <centerY>

Type into a focused field:
  adb -s $FLUTTER shell input text "test"

Compare key dialogs on both emulators by tapping the corresponding
button on each, then capturing and comparing the dialog screenshots:
  - Add Alias (single pair input)
  - Add Multiple Aliases/Tags (dynamic rows with add/remove)
  - Remove Selected Tags (checkbox multi-select)
  - Login User
  - Send Outcome (radio options)
  - Track Event (with JSON properties field)
  - Custom Notification (title + body)
For each dialog, compare field layout, button placement, spacing,
and validation behavior. Dismiss the dialog on both before moving on.
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

After each fix, hot reload by pressing 'r' in the user's active Flutter
terminal (check open terminals for a running flutter process) and
re-capture the Flutter screenshot to verify the change matches the reference.
```
