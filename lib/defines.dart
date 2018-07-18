import 'dart:convert';

String sdkVersion = "0.1.0";

/// Determines how notifications should be displayed
enum OSNotificationDisplayType { 
  none, 
  alert, 
  notification 
}

/// Indicates whether a user tapped a notification (`opened`)
/// or took a specific action by tapping a button (`actionTaken`)
enum OSNotificationActionType { 
  opened, 
  actionTaken 
}

//// NOTE: provisional permission is only available in iOS 12
enum OSNotificationPermission { 
  notDetermined, 
  denied, 
  authorized, 
  provisional 
}

/// An enum that declares different types of log levels you can 
/// use with the OneSignal SDK, going from the least verbose (none)
/// to verbose (print all comments).
enum OSLogLevel { 
  none, 
  fatal, 
  error, 
  warn, 
  info, 
  debug, 
  verbose 
}

/// Various iOS Settings that can be passed during initialization
enum OSiOSSettings { 
  autoPrompt, 
  inAppAlerts, 
  inAppLaunchUrl, 
  promptBeforeOpeningPushUrl, 
  inFocusDisplayOption 
}

/// An abstract class to provide JSON decoding
abstract class JSONStringRepresentable {
  String jsonRepresentation();

  String convertToJsonString(Map<String, dynamic> object) => JsonEncoder.withIndent('  ').convert(object);
}