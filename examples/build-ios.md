# iOS Setup: Push Notifications + Live Activities

Configure the demo Flutter iOS project (`com.onesignal.example`) for OneSignal push notifications and live activities. All paths below are relative to the `ios/` directory.

---

## 1. Podfile

Open `ios/Podfile` and make the following changes.

**Uncomment the platform line** (or add it if missing):

```ruby
platform :ios, '13.0'
```

**Add two new targets** after the `Runner` target block and before `post_install`:

```ruby
target 'OneSignalNotificationServiceExtension' do
  use_frameworks!
  pod 'OneSignalXCFramework', '>= 5.0.0', '< 6.0'
end

target 'OneSignalWidgetExtension' do
  use_frameworks!
  pod 'OneSignalXCFramework', '>= 5.0.0', '< 6.0'
end
```

---

## 2. Runner: entitlements + Info.plist

### Runner.entitlements

Create `Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>development</string>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.onesignal.example.onesignal</string>
	</array>
</dict>
</plist>
```

This enables push notifications (`aps-environment`) and an App Group shared with the extensions.

### Info.plist

In `Runner/Info.plist`, add the following inside the top-level `<dict>`:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

`NSSupportsLiveActivities` is required in the **main app target** for ActivityKit to start Live Activities. `UIBackgroundModes` with `remote-notification` enables background push processing.

---

## 3. Notification Service Extension

Allows OneSignal to process notifications before display (rich media, badges, etc). Create the `OneSignalNotificationServiceExtension/` folder with three files.

### NotificationService.swift

```swift
import UserNotifications
import OneSignalExtension

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            OneSignalExtension.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}
```

### Info.plist

All standard `CFBundle*` keys are required for the simulator to install the extension.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>OneSignalNotificationServiceExtension</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>$(MARKETING_VERSION)</string>
	<key>CFBundleVersion</key>
	<string>$(CURRENT_PROJECT_VERSION)</string>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.usernotifications.service</string>
		<key>NSExtensionPrincipalClass</key>
		<string>$(PRODUCT_MODULE_NAME).NotificationService</string>
	</dict>
</dict>
</plist>
```

### OneSignalNotificationServiceExtension.entitlements

The App Group must match the one in `Runner.entitlements`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.onesignal.example.onesignal</string>
	</array>
</dict>
</plist>
```

---

## 4. Widget Extension (Live Activities)

Create the `OneSignalWidget/` folder with the following files.

Note: the on-disk folder is `OneSignalWidget` but the Xcode target name is `OneSignalWidgetExtension` (matching the Podfile target).

### Info.plist

Same standard `CFBundle*` keys as the NSE, plus `NSSupportsLiveActivities`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>OneSignalWidgetExtension</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>$(MARKETING_VERSION)</string>
	<key>CFBundleVersion</key>
	<string>$(CURRENT_PROJECT_VERSION)</string>
	<key>NSSupportsLiveActivities</key>
	<true/>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.widgetkit-extension</string>
	</dict>
</dict>
</plist>
```

### OneSignalWidgetLiveActivity.swift

Uses `DefaultLiveActivityAttributes` from the OneSignal SDK, which allows the SDK to handle the entire Live Activity lifecycle. Attributes and content state are passed as dynamic dictionaries from the Flutter side via `startDefault()`. The widget renders an order delivery UI with status-based theming and a progress bar.

```swift
import ActivityKit
import WidgetKit
import SwiftUI
import OneSignalLiveActivities

@available(iOS 16.2, *)
struct OneSignalWidgetLiveActivity: Widget {

    private func statusIcon(for status: String) -> String {
        switch status {
        case "on_the_way": return "box.truck.fill"
        case "delivered":  return "checkmark.circle.fill"
        default:           return "bag.fill"
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "on_the_way": return .blue
        case "delivered":  return .green
        default:           return .orange
        }
    }

    private func statusLabel(for status: String) -> String {
        switch status {
        case "on_the_way": return "On the Way"
        case "delivered":  return "Delivered"
        default:           return "Preparing"
        }
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DefaultLiveActivityAttributes.self) { context in
            let orderNumber = context.attributes.data["orderNumber"]?.asString() ?? "Order"
            let status = context.state.data["status"]?.asString() ?? "preparing"
            let message = context.state.data["message"]?.asString() ?? "Your order is being prepared"
            let eta = context.state.data["estimatedTime"]?.asString() ?? ""

            VStack(spacing: 10) {
                HStack {
                    Text(orderNumber)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    if !eta.isEmpty {
                        Text(eta)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                HStack(spacing: 12) {
                    Image(systemName: statusIcon(for: status))
                        .font(.title2)
                        .foregroundColor(statusColor(for: status))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(statusLabel(for: status))
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                    Spacer()
                }

                DeliveryProgressBar(status: status)
            }
            .padding()
            .activityBackgroundTint(Color(red: 0.11, green: 0.13, blue: 0.19))
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            let status = context.state.data["status"]?.asString() ?? "preparing"
            let message = context.state.data["message"]?.asString() ?? "Preparing"
            let eta = context.state.data["estimatedTime"]?.asString() ?? ""

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: statusIcon(for: status))
                        .font(.title2)
                        .foregroundColor(statusColor(for: status))
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(statusLabel(for: status))
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if !eta.isEmpty {
                        Text(eta)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Image(systemName: statusIcon(for: status))
                    .foregroundColor(statusColor(for: status))
            } compactTrailing: {
                Text(statusLabel(for: status))
                    .font(.caption)
            } minimal: {
                Image(systemName: statusIcon(for: status))
                    .foregroundColor(statusColor(for: status))
            }
        }
    }
}

@available(iOS 16.2, *)
struct DeliveryProgressBar: View {
    let status: String

    private var progress: CGFloat {
        switch status {
        case "on_the_way": return 0.6
        case "delivered":  return 1.0
        default:           return 0.25
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 3)
                    .fill(progress >= 1.0 ? Color.green : Color.blue)
                    .frame(width: geo.size.width * progress, height: 6)
            }
        }
        .frame(height: 6)
    }
}
```

### OneSignalWidgetBundle.swift

```swift
import WidgetKit
import SwiftUI

@main
struct OneSignalWidgetBundle: WidgetBundle {
    var body: some Widget {
        OneSignalWidgetLiveActivity()
    }
}
```

---

## 5. project.pbxproj

The `project.pbxproj` needs native target entries for both extensions. These are complex (UUIDs, build phases, configuration lists) and are best done by opening the `.xcodeproj` in Xcode. The key requirements:

**Runner target changes:**
- Add `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements` to all Runner build configurations (Debug/Release/Profile)
- Add an `Embed Foundation Extensions` copy-files phase (`dstSubfolderSpec = 13`) embedding both `.appex` products. This phase must appear **before** the `Thin Binary` script phase to avoid a build cycle.
- Add target dependencies from Runner to both extension targets

**OneSignalNotificationServiceExtension target** (`com.apple.product-type.app-extension`):
- Sources, Frameworks, Resources build phases
- `PRODUCT_BUNDLE_IDENTIFIER = com.onesignal.example.NSE` (must be prefixed with parent app's bundle ID)
- `CODE_SIGN_ENTITLEMENTS = OneSignalNotificationServiceExtension/OneSignalNotificationServiceExtension.entitlements`
- `INFOPLIST_FILE = OneSignalNotificationServiceExtension/Info.plist`
- `SKIP_INSTALL = YES`, `SWIFT_VERSION = 5.0`, `IPHONEOS_DEPLOYMENT_TARGET = 13.0`

**OneSignalWidgetExtension target** (`com.apple.product-type.app-extension`):
- Sources, Frameworks (linking WidgetKit.framework and SwiftUI.framework), Resources build phases
- `PRODUCT_BUNDLE_IDENTIFIER = com.onesignal.example.LA`
- `INFOPLIST_FILE = OneSignalWidget/Info.plist` (note: folder is `OneSignalWidget`, not `OneSignalWidgetExtension`)
- `SKIP_INSTALL = YES`, `SWIFT_VERSION = 5.0`, `IPHONEOS_DEPLOYMENT_TARGET = 16.2` (Live Activities require iOS 16.2+)

---

## 6. Install dependencies

Run `flutter pub get` first (the Podfile reads `Generated.xcconfig` which this creates), then `pod install`:

```sh
flutter pub get
cd ios && pod install
```

This generates the Pods workspace, xcconfig files, and CocoaPods build phases (`[CP] Check Pods Manifest.lock`, `[CP] Embed Pods Frameworks`). Open the `.xcworkspace` file (not `.xcodeproj`) going forward.

Note: avoid setting `CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER` in extension build configurations since CocoaPods provides it via xcconfig.
