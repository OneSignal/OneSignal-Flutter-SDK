import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/permission.dart';
import 'package:onesignal_flutter/src/subscription.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/utils.dart';
import 'package:onesignal_flutter/src/notification.dart';
import 'package:onesignal_flutter/src/create_notification.dart';
import 'package:onesignal_flutter/src/in_app_message.dart';
import 'package:onesignal_flutter/src/outcome_event.dart';

export 'src/notification.dart';
export 'src/subscription.dart';
export 'src/permission.dart';
export 'src/defines.dart';
export 'src/create_notification.dart';
export 'src/in_app_message.dart';
export 'src/outcome_event.dart';

// Handlers for various events
typedef void ReceivedNotificationHandler(OSNotification notification);
typedef void OpenedNotificationHandler(OSNotificationOpenedResult openedResult);
typedef void SubscriptionChangedHandler(OSSubscriptionStateChanges changes);
typedef void EmailSubscriptionChangeHandler(
    OSEmailSubscriptionStateChanges changes);
typedef void SMSSubscriptionChangeHandler(
    OSSMSSubscriptionStateChanges changes);
typedef void PermissionChangeHandler(OSPermissionStateChanges changes);
typedef void InAppMessageClickedHandler(OSInAppMessageAction action);
typedef void NotificationWillShowInForegroundHandler(
    OSNotificationReceivedEvent event);

void _callbackDispatcher() {
  // Initialize state necessary for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  const MethodChannel _channel = MethodChannel('OneSignalBackground');

  // This is where we handle background events from the native portion of the plugin.
  _channel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'OneSignal#onBackgroundNotification') {
      final CallbackHandle notificationCallbackHandle =
          CallbackHandle.fromRawHandle(
              call.arguments['notificationCallbackHandle']);

      // PluginUtilities.getCallbackFromHandle performs a lookup based on the
      // callback handle and returns a tear-off of the original callback.
      final closure =
          PluginUtilities.getCallbackFromHandle(notificationCallbackHandle)!
              as Future<void> Function(OSNotificationReceivedEvent);

      try {
        Map<String, dynamic> messageMap =
            Map<String, dynamic>.from(call.arguments['message']);
        final notification = OSNotificationReceivedEvent(messageMap);
        await closure(notification);
      } catch (e) {
        // ignore: avoid_print
        print(
            'OneSignal: An error occurred in your background messaging handler:');
        // ignore: avoid_print
        print(e);
      }
    } else {
      throw UnimplementedError('${call.method} has not been implemented');
    }
  });

  // Once we've finished initializing, let the native portion of the plugin
  // know that it can start scheduling alarms.
  _channel.invokeMethod<void>('OneSignal#backgroundHandlerInitialized');
}

class OneSignal {
  /// A singleton representing the OneSignal SDK.
  /// Note that the iOS and Android native libraries are static,
  /// so if you create multiple instances of OneSignal, they will
  /// mostly share the same state.
  static OneSignal shared = new OneSignal();

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal');
  MethodChannel _tagsChannel = const MethodChannel('OneSignal#tags');
  MethodChannel _inAppMessagesChannel =
      const MethodChannel('OneSignal#inAppMessages');
  MethodChannel _outcomesChannel = const MethodChannel('OneSignal#outcomes');

  // event handlers
  OpenedNotificationHandler? _onOpenedNotification;
  SubscriptionChangedHandler? _onSubscriptionChangedHandler;
  EmailSubscriptionChangeHandler? _onEmailSubscriptionChangedHandler;
  SMSSubscriptionChangeHandler? _onSMSSubscriptionChangedHandler;
  PermissionChangeHandler? _onPermissionChangedHandler;
  InAppMessageClickedHandler? _onInAppMessageClickedHandler;
  NotificationWillShowInForegroundHandler?
      _onNotificationWillShowInForegroundHandler;

  // constructor method
  OneSignal() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  /// The initializer for OneSignal. Note that this initializer
  /// accepts an iOSSettings object, in Android you can pass null.
  Future<void> setAppId(String appId) async {
    _onesignalLog(OSLogLevel.verbose,
        "Initializing the OneSignal Flutter SDK ($sdkVersion)");

    await _channel.invokeMethod('OneSignal#setAppId', {'appId': appId});
  }

  /// Sets the log level for the SDK. The first parameter (logLevel) controls
  /// how verbose logs in the console/logcat are, while the visual log level
  /// controls if the SDK will show alerts for each logged message
  Future<void> setLogLevel(OSLogLevel logLevel, OSLogLevel visualLevel) async {
    await _channel.invokeMethod("OneSignal#setLogLevel",
        {'console': logLevel.index, 'visual': visualLevel.index});
  }

  /// The notification opened handler is called whenever the user opens a
  /// OneSignal push notification, or taps an action button on a notification.
  void setNotificationOpenedHandler(OpenedNotificationHandler handler) {
    _onOpenedNotification = handler;
    _channel.invokeMethod("OneSignal#initNotificationOpenedHandlerParams");
  }

  /// The subscription handler will be called whenever the user's OneSignal
  /// subscription changes, such as when they are first assigned a
  /// OneSignal user ID.
  void setSubscriptionObserver(SubscriptionChangedHandler handler) {
    _onSubscriptionChangedHandler = handler;
  }

  /// The permission handler will be called whenever the user's Permission
  /// state changes, which is applicable to iOS (Android does not prompt the
  /// user for permission to receive push notifications).
  void setPermissionObserver(PermissionChangeHandler handler) {
    _onPermissionChangedHandler = handler;
  }

  /// The email subscription handler will be called whenever the user's email
  /// subscription changes (OneSignal can also send emails in addition to push
  /// notifications). For example, if you call setEmail() or logoutEmail().
  void setEmailSubscriptionObserver(EmailSubscriptionChangeHandler handler) {
    _onEmailSubscriptionChangedHandler = handler;
  }

  /// The SMS subscription handler will be called whenever the user's SMS
  /// subscription changes (OneSignal can also send SMSs in addition to push
  /// notifications). For example, if you call setSMSNumber() or logoutSMSNumber().
  void setSMSSubscriptionObserver(SMSSubscriptionChangeHandler handler) {
    _onSMSSubscriptionChangedHandler = handler;
  }

  /// The in app message clicked handler is called whenever the user clicks a
  /// OneSignal IAM button or image with an action event attacthed to it
  void setInAppMessageClickedHandler(InAppMessageClickedHandler handler) {
    _onInAppMessageClickedHandler = handler;
    _channel.invokeMethod("OneSignal#initInAppMessageClickedHandlerParams");
  }

  /// The notification foreground handler is called whenever a notification arrives
  /// and the application is in foreground
  void setNotificationWillShowInForegroundHandler(
      NotificationWillShowInForegroundHandler handler) {
    _onNotificationWillShowInForegroundHandler = handler;
    _channel.invokeMethod(
        "OneSignal#initNotificationWillShowInForegroundHandlerParams");
  }

  void setNotificationWillShowHandler(
      NotificationWillShowInForegroundHandler handler) {
    if (Platform.isIOS) {
      setNotificationWillShowInForegroundHandler(handler);
      return;
    }
    final CallbackHandle bgHandle =
        PluginUtilities.getCallbackHandle(_callbackDispatcher)!;
    final CallbackHandle notificationHandler =
        PluginUtilities.getCallbackHandle(handler)!;
    _channel
        .invokeMapMethod("OneSignal#initNotificationWillShowHandlerParams", {
      'notificationCallbackHandle': notificationHandler.toRawHandle(),
      'pluginCallbackHandle': bgHandle.toRawHandle(),
    });
  }

  /// The notification foreground handler is called whenever a notification arrives
  /// and the application is in foreground
  void completeNotification(String notificationId, bool shouldDisplay) {
    _channel.invokeMethod("OneSignal#completeNotification",
        {'notificationId': notificationId, 'shouldDisplay': shouldDisplay});
  }

  /// Allows you to completely disable the SDK until your app calls the
  /// OneSignal.consentGranted(true) function. This is useful if you want
  /// to show a Terms and Conditions or privacy popup for GDPR.
  Future<void> setRequiresUserPrivacyConsent(bool required) async {
    await _channel.invokeMethod(
        "OneSignal#setRequiresUserPrivacyConsent", {'required': required});
  }

  /// If your application is set to require the user's consent before
  /// using push notifications, your app should call this method when
  /// the user gives their consent. This will cause the OneSignal SDK
  /// to initialize.
  Future<void> consentGranted(bool granted) async {
    await _channel
        .invokeMethod("OneSignal#consentGranted", {'granted': granted});
  }

  /// A boolean value indicating if the user provided privacy consent
  Future<bool> userProvidedPrivacyConsent() async {
    var val =
        await _channel.invokeMethod("OneSignal#userProvidedPrivacyConsent");

    return val as bool;
  }

  /// A boolean value indicating if the OneSignal SDK is waiting for the
  /// user's consent before it can initialize (if you set the app to
  /// require the user's consent)
  Future<bool> requiresUserPrivacyConsent() async {
    var val =
        await _channel.invokeMethod("OneSignal#requiresUserPrivacyConsent");

    return val as bool;
  }

  /// in iOS, will prompt the user for permission to send push notifications.
  //  in Android, it will always return false, since notification permission is by default given
  Future<bool> promptUserForPushNotificationPermission(
      {bool fallbackToSettings = false}) async {
    dynamic result = await _channel.invokeMethod(
        "OneSignal#promptPermission", {'fallback': fallbackToSettings});

    return result as bool? ?? false;
  }

  /// Sends a single key/value pair to tags to OneSignal.
  /// Please do not send hashmaps/arrays as values as this will fail.
  /// This method can often take more than five seconds to complete,
  /// so please do NOT block any user-interactive content while
  /// waiting for this request to complete.
  Future<Map<String, dynamic>> sendTag(String key, dynamic value) async {
    Map<dynamic, dynamic> response = await this.sendTags({key: value});
    return response.cast<String, dynamic>();
  }

  /// Updates the user's OneSignal tags. This method is additive
  /// This method can often take more than five seconds to complete,
  /// so please do NOT block any user-interactive content while
  /// waiting for this request to complete.
  Future<Map<String, dynamic>> sendTags(Map<String, dynamic> tags) async {
    Map<dynamic, dynamic> response =
        await (_tagsChannel.invokeMethod("OneSignal#sendTags", tags));
    return response.cast<String, dynamic>();
  }

  /// An asynchronous method that makes an HTTP request to OneSignal's
  /// API to retrieve the current user's tags.
  /// This request can take a while to complete: please do NOT block
  /// any user-interactive content while waiting for this request
  /// to finish.
  Future<Map<String, dynamic>> getTags() async {
    Map<dynamic, dynamic> tags =
        await (_tagsChannel.invokeMethod("OneSignal#getTags"));
    return tags.cast<String, dynamic>();
  }

  /// Allows you to delete a single key/value pair from the user's tags
  /// by specifying the key. This method can often take more than five
  /// seconds to complete, so please do NOT block any user-interactive
  /// content while waiting for this request to complete.
  Future<Map<String, dynamic>> deleteTag(String key) async {
    Map<dynamic, dynamic> response = await this.deleteTags([key]);
    return response.cast<String, dynamic>();
  }

  /// Allows you to delete an array of tags by specifying an
  /// array of keys.
  Future<Map<String, dynamic>> deleteTags(List<String> keys) async {
    Map<dynamic, dynamic> response =
        await (_tagsChannel.invokeMethod("OneSignal#deleteTags", keys));
    return response.cast<String, dynamic>();
  }

  /// Returns an `OSDeviceState` object, which contains the current device state
  Future<OSDeviceState?> getDeviceState() async {
    var json = await _channel.invokeMethod("OneSignal#getDeviceState");

    if ((json.cast<String, dynamic>()).isEmpty) return null;

    return OSDeviceState(json.cast<String, dynamic>());
  }

  /// Allows you to manually disable or enable push notifications for this user.
  /// Note: This method does not change the user's system (iOS) push notification
  /// permission status. If the user disabled (or never allowed) your application
  /// to send push notifications, calling disablePush(false) will not change that.
  Future<void> disablePush(bool disable) async {
    return await _channel.invokeMethod("OneSignal#disablePush", disable);
  }

  /// Allows you to post a notification to the current user (or a different user
  /// if you specify their OneSignal user ID).
  Future<Map<String, dynamic>> postNotificationWithJson(
      Map<String, dynamic> json) async {
    Map<dynamic, dynamic> response =
        await (_channel.invokeMethod("OneSignal#postNotification", json));
    return response.cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> postNotification(
      OSCreateNotification notification) async {
    Map<dynamic, dynamic> response = await (_channel.invokeMethod(
        "OneSignal#postNotification", notification.mapRepresentation()));
    return response.cast<String, dynamic>();
  }

  /// Allows you to manually remove all OneSignal notifications from the Notification Shade
  Future<void> clearOneSignalNotifications() async {
    return await _channel.invokeMethod("OneSignal#clearOneSignalNotifications");
  }

  /// Allows you to manually cancel a single OneSignal notification based on its Android notification integer ID
  void removeNotification(int notificationId) {
    _channel.invokeMethod(
        "OneSignal#removeNotification", {'notificationId': notificationId});
  }

  /// Allows you to prompt the user for permission to use location services
  Future<void> promptLocationPermission() async {
    return await _channel.invokeMethod("OneSignal#promptLocation");
  }

  /// Allows you to determine if the user's location data is shared with OneSignal.
  /// This allows you to do things like geofenced notifications, etc.
  Future<void> setLocationShared(bool shared) async {
    return await _channel.invokeMethod("OneSignal#setLocationShared", shared);
  }

  /// Sets the user's email so you can send them emails through the OneSignal dashboard
  /// and API. The `emailAuthHashToken` is optional (but highly recommended) as part of
  /// Identity Verification. The email auth hash is a hash of your app's API key and the
  /// user ID. We recommend you generate this token from your backend server, do NOT
  /// store your API key in your app as this is highly insecure.
  Future<void> setEmail(
      {required String email, String? emailAuthHashToken}) async {
    return await _channel.invokeMethod("OneSignal#setEmail",
        {'email': email, 'emailAuthHashToken': emailAuthHashToken});
  }

  /// Dissociates the user's email from OneSignal, akin to turning off push notifications
  /// for email.
  Future<void> logoutEmail() async {
    return await _channel.invokeMethod("OneSignal#logoutEmail");
  }

  /// Sets the user's SMS number so you can send them SMSs through the OneSignal dashboard
  /// and API. The `smsAuthHashToken` is optional (but highly recommended) as part of
  /// Identity Verification. The SMS auth hash is a hash of your app's API key and the
  /// user ID. We recommend you generate this token from your backend server, do NOT
  /// store your API key in your app as this is highly insecure.
  Future<Map<String, dynamic>> setSMSNumber(
      {required String smsNumber, String? smsAuthHashToken}) async {
    Map<dynamic, dynamic> results = await _channel.invokeMethod(
        "OneSignal#setSMSNumber",
        {'smsNumber': smsNumber, 'smsAuthHashToken': smsAuthHashToken});
    return results.cast<String, dynamic>();
  }

  /// Dissociates the user's SMS number from OneSignal, akin to turning off push notifications
  /// for SMS number.
  Future<Map<String, dynamic>> logoutSMSNumber() async {
    Map<dynamic, dynamic> results =
        await _channel.invokeMethod("OneSignal#logoutSMSNumber");
    return results.cast<String, dynamic>();
  }

  /// OneSignal allows you to set a custom ID for your users. This makes it so that
  /// if your app has its own user ID's, you can use your own custom user ID's with
  /// our API instead of having to save their OneSignal user ID's.
  Future<Map<String, dynamic>> setExternalUserId(String externalId,
      [String? authHashToken]) async {
    Map<dynamic, dynamic> results = await (_channel.invokeMethod(
        "OneSignal#setExternalUserId",
        {'externalUserId': externalId, 'authHashToken': authHashToken}));
    return results.cast<String, dynamic>();
  }

  /// Removes the external user ID that was set for the current user.
  Future<Map<String, dynamic>> removeExternalUserId() async {
    Map<dynamic, dynamic> results =
        await (_channel.invokeMethod("OneSignal#removeExternalUserId"));
    return results.cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> setLanguage(String language) async {
    Map<dynamic, dynamic> results = await (_channel
        .invokeMethod("OneSignal#setLanguage", {'language': language}));
    return results.cast<String, dynamic>();
  }

  /// Adds a single key, value trigger, which will trigger an in app message
  /// if one exists matching the specific trigger added
  Future<void> addTrigger(String key, Object value) async {
    return await _inAppMessagesChannel
        .invokeMethod("OneSignal#addTrigger", {key: value});
  }

  /// Adds one or more key, value triggers, which will trigger in app messages
  /// (one at a time) if any exist matching the specific triggers added
  Future<void> addTriggers(Map<String, Object> triggers) async {
    return await _inAppMessagesChannel.invokeMethod(
        "OneSignal#addTriggers", triggers);
  }

  /// Remove a single key, value trigger to prevent an in app message from
  /// showing with that trigger
  Future<void> removeTriggerForKey(String key) async {
    return await _inAppMessagesChannel.invokeMethod(
        "OneSignal#removeTriggerForKey", key);
  }

  /// Remove one or more key, value triggers to prevent any in app messages
  /// from showing with those triggers
  Future<void> removeTriggersForKeys(List<String> keys) async {
    return await _inAppMessagesChannel.invokeMethod(
        "OneSignal#removeTriggersForKeys", keys);
  }

  /// Get the trigger value associated with the key provided
  Future<Object?> getTriggerValueForKey(String key) async {
    return await _inAppMessagesChannel.invokeMethod(
        "OneSignal#getTriggerValueForKey", key);
  }

  /// Toggles the showing of all in app messages
  Future<void> pauseInAppMessages(bool pause) async {
    return await _inAppMessagesChannel.invokeMethod(
        "OneSignal#pauseInAppMessages", pause);
  }

  /// Send a normal outcome event for the current session and notifications with the attribution window
  /// Counted each time sent successfully, failed ones will be cached and reattempted in future
  Future<OSOutcomeEvent> sendOutcome(String name) async {
    var json =
        await _outcomesChannel.invokeMethod("OneSignal#sendOutcome", name);

    if (json == null) return new OSOutcomeEvent();

    return new OSOutcomeEvent.fromMap(json.cast<String, dynamic>());
  }

  /// Send a unique outcome event for the current session and notifications with the attribution window
  /// Counted once per notification when sent successfully, failed ones will be cached and reattempted in future
  Future<OSOutcomeEvent> sendUniqueOutcome(String name) async {
    var json = await _outcomesChannel.invokeMethod(
        "OneSignal#sendUniqueOutcome", name);

    if (json == null) return new OSOutcomeEvent();

    return new OSOutcomeEvent.fromMap(json.cast<String, dynamic>());
  }

  /// Send an outcome event with a value for the current session and notifications with the attribution window
  /// Counted each time sent successfully, failed ones will be cached and reattempted in future
  Future<OSOutcomeEvent> sendOutcomeWithValue(String name, double value) async {
    var json = await _outcomesChannel.invokeMethod(
        "OneSignal#sendOutcomeWithValue",
        {"outcome_name": name, "outcome_value": value});

    if (json == null) return new OSOutcomeEvent();

    return new OSOutcomeEvent.fromMap(json.cast<String, dynamic>());
  }

  // Private function that gets called by ObjC/Java
  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'OneSignal#handleOpenedNotification' &&
        this._onOpenedNotification != null) {
      this._onOpenedNotification!(
          OSNotificationOpenedResult(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#subscriptionChanged' &&
        this._onSubscriptionChangedHandler != null) {
      this._onSubscriptionChangedHandler!(
          OSSubscriptionStateChanges(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#permissionChanged' &&
        this._onPermissionChangedHandler != null) {
      this._onPermissionChangedHandler!(
          OSPermissionStateChanges(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#emailSubscriptionChanged' &&
        this._onEmailSubscriptionChangedHandler != null) {
      this._onEmailSubscriptionChangedHandler!(OSEmailSubscriptionStateChanges(
          call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#smsSubscriptionChanged' &&
        this._onSMSSubscriptionChangedHandler != null) {
      this._onSMSSubscriptionChangedHandler!(OSSMSSubscriptionStateChanges(
          call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#handleClickedInAppMessage' &&
        this._onInAppMessageClickedHandler != null) {
      this._onInAppMessageClickedHandler!(
          OSInAppMessageAction(call.arguments.cast<String, dynamic>()));
    } else if (call.method ==
            'OneSignal#handleNotificationWillShowInForeground' &&
        this._onNotificationWillShowInForegroundHandler != null) {
      this._onNotificationWillShowInForegroundHandler!(
          OSNotificationReceivedEvent(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#handleNotificationWillShow' &&
        this._onNotificationWillShowInForegroundHandler != null) {
      this._onNotificationWillShowInForegroundHandler!(
          OSNotificationReceivedEvent(call.arguments.cast<String, dynamic>()));
    }
    return null;
  }

  //PRIVATE METHODS
  Future<void> _onesignalLog(OSLogLevel level, String message) async {
    await _channel.invokeMethod("OneSignal#log",
        <String, dynamic>{'logLevel': level.index, 'message': message});
  }

  Map<String, dynamic> _processSettings(Map<OSiOSSettings, dynamic> settings) {
    var finalSettings = Map<String, dynamic>();

    if (settings == null) return finalSettings;

    for (OSiOSSettings key in settings.keys) {
      var settingsKey = convertEnumCaseToValue(key);
      var settingsValue = convertEnumCaseToValue(settings[key]);

      if (settingsKey == null) continue;

      //we check if the value is also an enum case
      //ie. if they pass OSNotificationDisplayType,
      //we want to convert it to an integer before
      //passing the parameter to the ObjC bridge.
      finalSettings[settingsKey] = settingsValue ?? settings[key];
    }

    return finalSettings;
  }
}
