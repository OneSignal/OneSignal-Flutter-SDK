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
