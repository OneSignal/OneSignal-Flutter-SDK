String sdkVersion = "3.2.0";

/// Determines how notifications should be displayed
enum OSNotificationDisplayType { none, alert, notification }

/// Indicates whether a user tapped a notification (`opened`)
/// or took a specific action by tapping a button (`actionTaken`)
enum OSNotificationActionType { opened, actionTaken }

enum OSNotificationPermission {
  notDetermined,
  denied,
  authorized,
  provisional, // only available in iOS 12
  ephemeral, // only available in iOS 14
}

/// An enum that declares different types of log levels you can
/// use with the OneSignal SDK, going from the least verbose (none)
/// to verbose (print all comments).
enum OSLogLevel { none, fatal, error, warn, info, debug, verbose }

/// Various iOS Settings that can be passed during initialization
enum OSiOSSettings {
  autoPrompt,
  inAppAlerts,
  inAppLaunchUrl,
  promptBeforeOpeningPushUrl,
  inFocusDisplayOption
}

enum OSSession {
    DIRECT,
    INDIRECT,
    UNATTRIBUTED,
    DISABLED
}

/// Applies to iOS notifications only
/// Determines if the badgeCount is used to increment
/// the existing badge count, or sets the badge count directly
enum OSCreateNotificationBadgeType { increase, setTo }

/// control how the notification is delayed
///   timezone: Deliver at a specific time of day in each user's timezone
///   last-active: Deliver at the same time the user last used your app
enum OSCreateNotificationDelayOption { timezone, lastActive }
