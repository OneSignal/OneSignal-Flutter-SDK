


enum OSNotificationDisplayType { none, alert, notification }

enum OSNotificationActionType { opened, actionTaken }

// NOTE: provisional permission is only available in iOS 12
enum OSNotificationPermission { notDetermined, denied, authorized, provisional }

/// An enum that declares different types of log levels you can 
/// use with the OneSignal SDK, going from the least verbose (none)
/// to verbose (print all comments).
enum OSLogLevel { none, fatal, error, warn, info, debug, verbose }

enum OSiOSSettings { autoPrompt, inAppAlerts, inAppLaunchUrl, promptBeforeOpeningPushUrl, inFocusDisplayOption }

String sdkVersion = "0.1.0";