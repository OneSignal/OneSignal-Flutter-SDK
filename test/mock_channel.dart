import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/*
  This class mocks an iOS or Android host device
  It has a OneSignalState object that reflects changes to
  state that the various requests make.
*/

class OneSignalMockChannelController {
  final MethodChannel _channel = const MethodChannel('OneSignal');
  final MethodChannel _debugChannel = const MethodChannel('OneSignal#debug');
  final MethodChannel _tagsChannel = const MethodChannel('OneSignal#tags');
  final MethodChannel _locationChannel =
      const MethodChannel('OneSignal#location');
  final MethodChannel _inAppMessagesChannel =
      const MethodChannel('OneSignal#inappmessages');
  final MethodChannel _liveActivitiesChannel =
      const MethodChannel('OneSignal#liveactivities');
  final MethodChannel _notificationsChannel =
      const MethodChannel('OneSignal#notifications');

  late OneSignalState state;

  OneSignalMockChannelController() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, _handleMethod);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_tagsChannel, _handleMethod);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_debugChannel, _handleMethod);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_locationChannel, _handleMethod);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_inAppMessagesChannel, _handleMethod);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_liveActivitiesChannel, _handleMethod);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_notificationsChannel, _handleMethod);
  }

  void resetState() {
    state = OneSignalState();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "OneSignal#setAppId":
        state.setAppId(call.arguments);
        break;
      case "OneSignal#setLogLevel":
        state.setLogLevel(call.arguments);
        break;
      case "OneSignal#setAlertLevel":
        state.setAlertLevel(call.arguments);
        break;
      case "OneSignal#consentGiven":
        state.consentGiven =
            (call.arguments as Map<dynamic, dynamic>)['given'] as bool?;
        break;
      case "OneSignal#promptPermission":
        state.calledPromptPermission = true;
        break;
      case "OneSignal#log":
        state.log(call.arguments);
        break;
      case "OneSignal#disablePush":
        state.disablePush = call.arguments as bool?;
        break;
      case "OneSignal#postNotification":
        state.postNotificationJson = call.arguments as Map<dynamic, dynamic>?;
        return {"success": true};
      case "OneSignal#setLocationShared":
        state.locationShared = call.arguments as bool?;
        break;
      case "OneSignal#setEmail":
        state.setEmail(call.arguments);
        break;
      case "OneSignal#sendTags":
        state.tags = call.arguments;
        return {"success": true};
      case "OneSignal#deleteTags":
        state.deleteTags = call.arguments;
        return {"success": true};
      case "OneSignal#setExternalUserId":
        state.externalId = (call.arguments
            as Map<dynamic, dynamic>)['externalUserId'] as String?;
        return {"success": true};
      case "OneSignal#removeExternalUserId":
        state.externalId = null;
        return {"success": true};
      case "OneSignal#setLanguage":
        state.language =
            (call.arguments as Map<dynamic, dynamic>)['language'] as String?;
        return {"success": true};
      case "OneSignal#requestPermission":
        state.locationPermissionRequested = true;
        break;
      case "OneSignal#setShared":
        state.locationShared = call.arguments as bool?;
        break;
      case "OneSignal#isShared":
        return state.locationShared ?? false;
      case "OneSignal#enterLiveActivity":
        state.liveActivityEntered = true;
        state.liveActivityId =
            (call.arguments as Map<dynamic, dynamic>)['activityId'] as String?;
        state.liveActivityToken =
            (call.arguments as Map<dynamic, dynamic>)['token'] as String?;
        break;
      case "OneSignal#exitLiveActivity":
        state.liveActivityExited = true;
        state.liveActivityId =
            (call.arguments as Map<dynamic, dynamic>)['activityId'] as String?;
        break;
      case "OneSignal#setupDefault":
        state.liveActivitySetupCalled = true;
        state.liveActivitySetupOptions = (call.arguments
            as Map<dynamic, dynamic>)['options'] as Map<dynamic, dynamic>?;
        break;
      case "OneSignal#startDefault":
        state.liveActivityStarted = true;
        state.liveActivityId =
            (call.arguments as Map<dynamic, dynamic>)['activityId'] as String?;
        state.liveActivityAttributes =
            (call.arguments as Map<dynamic, dynamic>)['attributes'];
        state.liveActivityContent =
            (call.arguments as Map<dynamic, dynamic>)['content'];
        break;
      case "OneSignal#setPushToStartToken":
        state.liveActivityPushToStartSet = true;
        state.liveActivityType = (call.arguments
            as Map<dynamic, dynamic>)['activityType'] as String?;
        state.liveActivityPushToken =
            (call.arguments as Map<dynamic, dynamic>)['token'] as String?;
        break;
      case "OneSignal#removePushToStartToken":
        state.liveActivityPushToStartRemoved = true;
        state.liveActivityType = (call.arguments
            as Map<dynamic, dynamic>)['activityType'] as String?;
        break;
      case "OneSignal#addTrigger":
        state.addTrigger(call.arguments as Map<dynamic, dynamic>);
        break;
      case "OneSignal#addTriggers":
        state.triggers = call.arguments as Map<dynamic, dynamic>?;
        return {"success": true};
      case "OneSignal#removeTrigger":
        state.removedTrigger = call.arguments as String?;
        break;
      case "OneSignal#removeTriggers":
        state.removedTriggers = call.arguments as List<dynamic>?;
        return {"success": true};
      case "OneSignal#clearTriggers":
        state.clearedTriggers = true;
        break;
      case "OneSignal#paused":
        state.inAppMessagesPaused = call.arguments as bool?;
        break;
      case "OneSignal#arePaused":
        return state.inAppMessagesPaused ?? false;
      case "OneSignal#lifecycleInit":
        state.lifecycleInitCalled = true;
        break;
      case "OneSignal#displayNotification":
        // This is called on OneSignal#notifications channel
        state.displayedNotificationId = (call.arguments
            as Map<dynamic, dynamic>)['notificationId'] as String?;
        break;
      case "OneSignal#preventDefault":
        // This is called on OneSignal#notifications channel
        state.preventedNotificationId = (call.arguments
            as Map<dynamic, dynamic>)['notificationId'] as String?;
        break;
    }
  }
}

class OneSignalState {
  //initialization
  String? appId;

  //email
  String? email;
  String? emailAuthHashToken;

  // logging
  String? latestLogStatement;
  OSLogLevel? latestLogLevel;

  // miscellaneous params
  bool? requiresPrivacyConsent = false;
  late OSLogLevel logLevel;
  late OSLogLevel visualLevel;
  bool? consentGiven = false;
  bool? calledPromptPermission;
  bool? locationShared;
  bool? locationPermissionRequested;
  OSNotificationDisplayType? inFocusDisplayType;
  bool? disablePush;
  String? externalId;
  String? language;

  // live activities
  bool? liveActivityEntered;
  bool? liveActivityExited;
  bool? liveActivityStarted;
  bool? liveActivitySetupCalled;
  bool? liveActivityPushToStartSet;
  bool? liveActivityPushToStartRemoved;
  String? liveActivityId;
  String? liveActivityToken;
  String? liveActivityType;
  String? liveActivityPushToken;
  dynamic liveActivityAttributes;
  dynamic liveActivityContent;
  Map<dynamic, dynamic>? liveActivitySetupOptions;

  // in app messages
  bool? inAppMessagesPaused;
  bool? lifecycleInitCalled;
  Map<dynamic, dynamic>? triggers;
  String? removedTrigger;
  List<dynamic>? removedTriggers;
  bool? clearedTriggers;

  // tags
  Map<dynamic, dynamic>? tags;
  List<dynamic>? deleteTags;

  // notifications
  Map<dynamic, dynamic>? postNotificationJson;
  String? displayedNotificationId;
  String? preventedNotificationId;

  /*
    All of the following functions parse the MethodCall
    parameters, and sets properties on the object itself
  */

  void setAppId(Map<dynamic, dynamic> params) {
    appId = params['appId'];
  }

  void setLogLevel(Map<dynamic, dynamic> params) {
    int? level = params['logLevel'] as int?;
    int? visual = params['visual'] as int?;

    if (level != null) logLevel = OSLogLevel.values[level];
    if (visual != null) visualLevel = OSLogLevel.values[visual];
  }

  void setAlertLevel(Map<dynamic, dynamic> params) {
    int? visual = params['visualLevel'] as int?;

    if (visual != null) visualLevel = OSLogLevel.values[visual];
  }

  void consentRequired(Map<dynamic, dynamic> params) {
    requiresPrivacyConsent = params['required'] as bool?;
  }

  void log(Map<dynamic, dynamic> params) {
    var level = params['logLevel'] as int?;

    if (level != null) latestLogLevel = OSLogLevel.values[level];
    latestLogStatement = params['message'];
  }

  void setDisplayType(Map<dynamic, dynamic> params) {
    var type = params['displayType'] as int?;
    if (type != null)
      inFocusDisplayType = OSNotificationDisplayType.values[type];
  }

  void setEmail(Map<dynamic, dynamic> params) {
    email = params['email'] as String?;
    emailAuthHashToken = params['emailAuthHashToken'] as String?;
  }

  void addTrigger(Map<dynamic, dynamic> params) {
    triggers = params;
  }
}
