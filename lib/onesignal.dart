import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'package:onesignal/src/defines.dart';
import 'package:onesignal/src/notification.dart';
import 'package:onesignal/src/subscription.dart';


// Handlers for various events
typedef Future<dynamic> ReceivedNotificationHandler(OSNotification notification);
typedef Future<dynamic> OpenedNotificationHandler(OSNotificationOpenedResult openedResult);
typedef Future<dynamic> SubscriptionChangedHandler(OSSubscriptionStateChanges changes);

// Bridged Callbacks 
typedef Future<dynamic> UserGrantedPermission(bool granted);

class OneSignal {

  /// A singleton representing the OneSignal SDK.
  /// Note that the iOS and Android native libraries are static,
  /// so if you create multiple instances of OneSignal, they will
  /// mostly share the same state.
  static OneSignal shared = new OneSignal();

  static const MethodChannel _channel = const MethodChannel('OneSignal');
  static const MethodChannel _tagsChannel = const MethodChannel('OneSignal#tags');

  
  OneSignal() {
    OneSignal._channel.setMethodCallHandler(_handleMethod);
  }
  
  ReceivedNotificationHandler _onReceivedNotification;
  OpenedNotificationHandler _onOpenedNotification;
  SubscriptionChangedHandler _onSubscriptionChangedHandler;

  /// The initializer for OneSignal. Note that this initializer
  /// accepts an iOSSettings object, in Android you can pass null.
  Future<void> init(String appId, {Map<OSiOSSettings, dynamic> iOSSettings}) async {
    _onesignalLog(OSLogLevel.verbose, "Initializing the OneSignal Flutter SDK ($sdkVersion)");

    var finalSettings = _processSettings(iOSSettings);

    await _channel.invokeMethod('OneSignal#init', <String, dynamic> { 
      'appId' : appId,
      'settings' : finalSettings
    });
  }

  /// Sets the log level for the SDK. The first parameter (logLevel) controls
  /// how verbose logs in the console/logcat are, while the visual log level
  /// controls if the SDK will show alerts for each logged message
  Future<void> setLogLevel(OSLogLevel logLevel, OSLogLevel visualLevel) async {
    await _channel.invokeMethod("OneSignal#setLogLevel", <String, int> { 
      'console' : logLevel.index,
      'visual' : visualLevel.index
    });
  }

  /// The notification received handler will be called whenever a notification
  /// is received by the SDK (only applies to OneSignal push notifications)
  void setNotificationReceivedHandler(ReceivedNotificationHandler handler) {
    _onReceivedNotification = handler;
  }

  /// The notification opened handler is called whenever the user opens a 
  /// OneSignal push notification, or taps an action button on a notification.
  void setNotificationOpenedHandler(OpenedNotificationHandler handler) {
    _onOpenedNotification = handler;
  }

  /// The subscription handler will be called whenever the user's OneSignal
  /// subscription changes, such as when they are first assigned a 
  /// OneSignal user ID.
  void setSubscriptionObserver(SubscriptionChangedHandler handler) {
    _onSubscriptionChangedHandler = handler;
  }
  
  /// Allows you to completely disable the SDK until your app calls the 
  /// OneSignal.consentGranted(true) function. This is useful if you want
  /// to show a Terms and Conditions or privacy popup for GDPR.
  Future<void> setRequiresUserPrivacyConsent(bool required) async {
    await _channel.invokeMethod("OneSignal#setRequiresUserPrivacyConsent", <String, dynamic> {
      'required' : required
    });
  }

  /// If your application is set to require the user's consent before 
  /// using push notifications, your app should call this method when
  /// the user gives their consent. This will cause the OneSignal SDK 
  /// to initialize.
  Future<void> consentGranted(bool granted) async {
    await _channel.invokeMethod("OneSignal#consentGranted", <String, dynamic> {
      'granted' : granted
    });
  }

  /// A boolean value indicating if the OneSignal SDK is waiting for the 
  /// user's consent before it can initialize (if you set the app to
  /// require the user's consent)
  Future<bool> requiresUserPrivacyConsent() async {
    var val = await _channel.invokeMethod("OneSignal#requiresUserPrivacyConsent");
    
    return val as bool;
  }

  /// in iOS, will prompt the user for permission to send push notifications.
  Future<bool> promptUserForPushNotificationPermission({bool fallbackToSettings = false}) async {
    bool result = await _channel.invokeMethod("OneSignal#promptPermission", <String, dynamic> {
      'fallback' : fallbackToSettings
    });

    return result;
  }

  /// in iOS, takes the user to the iOS Settings page for this app.
  Future<void> presentApplicationSettings() async {
    await _channel.invokeMethod("OneSignal#presentSettings");
  }

  /// The current setting that controls how notifications are displayed.
  Future<OSNotificationDisplayType> inFocusDisplayType() async {
    int type = await _channel.invokeMethod("OneSignal#inFocusDisplayType");
    return OSNotificationDisplayType.values[type];
  }

  /// Sends a single key/value pair to tags to OneSignal. 
  /// Please do not send hashmaps/arrays as values as this will fail.
  Future<Map<dynamic, dynamic>> sendTag(dynamic key, dynamic value) async {
    return await this.sendTags(<String, dynamic> { key : value });
  }
  
  /// Updates the user's OneSignal tags. This method is additive
  Future<Map<dynamic, dynamic>> sendTags(Map<dynamic, dynamic> tags) async {
    return await _tagsChannel.invokeMethod("OneSignal#sendTags", tags);
  }

  /// An asynchronous method that makes an HTTP request to OneSignal's
  /// API to retrieve the current user's tags.
  Future<Map<dynamic, dynamic>> getTags() async {
    return await _tagsChannel.invokeMethod("OneSignal#getTags");
  }

  Future<Null> _handleMethod(MethodCall call) async {
    print('Handling method call: ' + call.method);
    switch (call.method) {
      case 'OneSignal#handleReceivedNotification':
        final List<dynamic> args = call.arguments;
        final Map<dynamic, dynamic> map = args.first;
        OSNotification notification = OSNotification.fromJson(map);
        return this._onReceivedNotification(notification);
      case 'OneSignal#handleOpenedNotification':
        var args = call.arguments as List<dynamic>;
        return this._onOpenedNotification(OSNotificationOpenedResult.fromJson(args.first as Map<dynamic, dynamic>));
      case 'OneSignal#subscriptionChanged': 
        var args = call.arguments as List<dynamic>;
        return this._onSubscriptionChangedHandler(OSSubscriptionStateChanges(args.first as Map<dynamic, dynamic>));
    }
  }

  //PRIVATE METHODS
  Future<void> _onesignalLog(OSLogLevel level, String message) async {
    await _channel.invokeMethod("OneSignal#log", <String, dynamic> { 
      'logLevel' : level.index,
      'message' : message
    });
  }

  // in some places, we want to send an enum value to
  // ObjC. Before we can do this, we must convert it 
  // to a string/int/etc. 
  // However, in some places such as iOS init settings,
  // there could be multiple different types of enum,
  // so we've combined it into this one function.
  dynamic _convertEnumCaseToValue(dynamic key) {
    switch (key) {
      case OSiOSSettings.autoPrompt:
        return "kOSSettingsKeyAutoPrompt";
      case OSiOSSettings.inAppAlerts:
        return "kOSSettingsKeyInAppAlerts";
      case OSiOSSettings.inAppLaunchUrl: 
        return "kOSSettingsKeyInAppLaunchURL";
      case OSiOSSettings.inFocusDisplayOption:
        return "kOSSettingsKeyInFocusDisplayOption";
      case OSiOSSettings.promptBeforeOpeningPushUrl:
        return "kOSSSettingsKeyPromptBeforeOpeningPushURL";
    }

    switch (key) {
      case OSNotificationDisplayType.none: 
        return 0;
      case OSNotificationDisplayType.alert: 
        return 1;
      case OSNotificationDisplayType.notification:
        return 2;
    }

    return key;
  }

  Map<String, dynamic> _processSettings(Map<OSiOSSettings, dynamic> settings) {
    var finalSettings = Map<String, dynamic>();

    for (OSiOSSettings key in settings.keys) {
      var settingsKey = _convertEnumCaseToValue(key);
      var settingsValue = _convertEnumCaseToValue(settings[key]);

      if (settingsKey == null) 
        continue;

      //we check if the value is also an enum case
      //ie. if they pass OSNotificationDisplayType,
      //we want to convert it to an integer before
      //passing the parameter to the ObjC bridge.
      finalSettings[settingsKey] = settingsValue ?? settings[key];
    }
    
    return finalSettings;
  }
}
