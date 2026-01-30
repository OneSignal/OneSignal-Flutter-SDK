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
  final MethodChannel _pushSubscriptionChannel =
      const MethodChannel('OneSignal#pushsubscription');
  final MethodChannel _sessionChannel =
      const MethodChannel('OneSignal#session');
  final MethodChannel _userChannel = const MethodChannel('OneSignal#user');

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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pushSubscriptionChannel, _handleMethod);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_sessionChannel, _handleMethod);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_userChannel, _handleMethod);
  }

  void resetState() {
    state = OneSignalState();
  }

  // Helper method to simulate push subscription changes from native
  void simulatePushSubscriptionChange(Map<String, dynamic> changeData) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      _pushSubscriptionChannel.name,
      _pushSubscriptionChannel.codec.encodeMethodCall(
        MethodCall('OneSignal#onPushSubscriptionChange', changeData),
      ),
      (ByteData? data) {},
    );
  }

  // Helper method to simulate user state changes from native
  void simulateUserStateChange(Map<String, dynamic> changeData) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      _userChannel.name,
      _userChannel.codec.encodeMethodCall(
        MethodCall('OneSignal#onUserStateChange', changeData),
      ),
      (ByteData? data) {},
    );
  }

  // Generic helper method to simulate method calls from native on any channel
  void simulateMethodCall(
      String channelName, String methodName, dynamic arguments) {
    final MethodChannel channel;

    switch (channelName) {
      case 'OneSignal':
        channel = _channel;
        break;
      case 'OneSignal#debug':
        channel = _debugChannel;
        break;
      case 'OneSignal#tags':
        channel = _tagsChannel;
        break;
      case 'OneSignal#location':
        channel = _locationChannel;
        break;
      case 'OneSignal#inappmessages':
        channel = _inAppMessagesChannel;
        break;
      case 'OneSignal#liveactivities':
        channel = _liveActivitiesChannel;
        break;
      case 'OneSignal#notifications':
        channel = _notificationsChannel;
        break;
      case 'OneSignal#pushsubscription':
        channel = _pushSubscriptionChannel;
        break;
      case 'OneSignal#session':
        channel = _sessionChannel;
        break;
      case 'OneSignal#user':
        channel = _userChannel;
        break;
      default:
        throw ArgumentError('Unknown channel: $channelName');
    }

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(
        MethodCall(methodName, arguments),
      ),
      (ByteData? data) {},
    );
  }

  // Convenience wrapper for in-app message events
  void simulateInAppMessageEvent(String eventName, Map<String, dynamic> data) {
    simulateMethodCall('OneSignal#inappmessages', eventName, data);
  }

  // Convenience wrapper for notification events
  void simulateNotificationEvent(String eventName, Map<String, dynamic> data) {
    simulateMethodCall('OneSignal#notifications', eventName, data);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "OneSignal#initialize":
        state.setAppId(call.arguments);
        break;
      case "OneSignal#login":
        state.externalId =
            (call.arguments as Map<dynamic, dynamic>)['externalId'] as String?;
        break;
      case "OneSignal#loginWithJWT":
        state.externalId =
            (call.arguments as Map<dynamic, dynamic>)['externalId'] as String?;
        break;
      case "OneSignal#logout":
        state.externalId = null;
        break;
      case "OneSignal#consentGiven":
        state.consentGiven =
            (call.arguments as Map<dynamic, dynamic>)['granted'] as bool?;
        break;
      case "OneSignal#consentRequired":
        state.requiresPrivacyConsent =
            (call.arguments as Map<dynamic, dynamic>)['required'] as bool?;
        break;
      case "OneSignal#setAppId":
        state.setAppId(call.arguments);
        break;
      case "OneSignal#setLogLevel":
        state.setLogLevel(call.arguments);
        break;
      case "OneSignal#setAlertLevel":
        state.setAlertLevel(call.arguments);
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
      case "OneSignal#requestPermission":
        // Location requestPermission (no arguments)
        if (call.arguments == null) {
          state.locationPermissionRequested = true;
          break;
        }
        // Notifications requestPermission (with fallbackToSettings argument)
        // Falls through to the notifications handler below
        state.requestPermissionCalled = true;
        state.requestPermissionFallbackToSettings = (call.arguments
            as Map<dynamic, dynamic>)['fallbackToSettings'] as bool?;
        return true;
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
      case "OneSignal#removeNotification":
        state.removedNotificationId =
            (call.arguments as Map<dynamic, dynamic>)['notificationId'] as int?;
        break;
      case "OneSignal#removeGroupedNotifications":
        state.removedNotificationGroup = (call.arguments
            as Map<dynamic, dynamic>)['notificationGroup'] as String?;
        break;
      case "OneSignal#clearAll":
        state.clearedAllNotifications = true;
        break;
      case "OneSignal#permission":
        return state.notificationPermission ?? false;
      case "OneSignal#permissionNative":
        return state.notificationPermissionNative ?? 1; // 1 = denied
      case "OneSignal#canRequest":
        return state.canRequestPermission ?? false;
      case "OneSignal#registerForProvisionalAuthorization":
        state.registerForProvisionalAuthorizationCalled = true;
        return true;
      case "OneSignal#addNativeClickListener":
        state.nativeClickListenerAdded = true;
        state.nativeClickListenerAddedCount++;
        break;
      case "OneSignal#proceedWithWillDisplay":
        state.proceedWithWillDisplayCalled = true;
        break;
      case "OneSignal#pushSubscriptionToken":
        return state.pushSubscriptionToken;
      case "OneSignal#pushSubscriptionId":
        return state.pushSubscriptionId;
      case "OneSignal#pushSubscriptionOptedIn":
        return state.pushSubscriptionOptedIn;
      case "OneSignal#optIn":
        state.pushSubscriptionOptInCalled = true;
        state.pushSubscriptionOptInCallCount++;
        break;
      case "OneSignal#optOut":
        state.pushSubscriptionOptOutCalled = true;
        state.pushSubscriptionOptOutCallCount++;
        break;
      case "OneSignal#addOutcome":
        state.addedOutcome = call.arguments as String;
        state.addOutcomeCallCount++;
        break;
      case "OneSignal#addUniqueOutcome":
        state.addedUniqueOutcome = call.arguments as String;
        state.addUniqueOutcomeCallCount++;
        break;
      case "OneSignal#addOutcomeWithValue":
        final args = call.arguments as Map<dynamic, dynamic>;
        state.addedOutcomeWithValueName = args['outcome_name'] as String;
        state.addedOutcomeWithValueValue = args['outcome_value'] as double;
        state.addOutcomeWithValueCallCount++;
        break;
      case "OneSignal#setLanguage":
        state.language =
            (call.arguments as Map<dynamic, dynamic>)['language'] as String?;
        break;
      case "OneSignal#addAliases":
        state.aliases = call.arguments as Map<dynamic, dynamic>?;
        break;
      case "OneSignal#removeAliases":
        state.removedAliases = call.arguments as List<dynamic>?;
        break;
      case "OneSignal#addTags":
        state.tags = call.arguments as Map<dynamic, dynamic>?;
        break;
      case "OneSignal#removeTags":
        state.deleteTags = call.arguments as List<dynamic>?;
        break;
      case "OneSignal#getTags":
        return state.tags ?? {};
      case "OneSignal#addEmail":
        state.addedEmail = call.arguments as String?;
        break;
      case "OneSignal#removeEmail":
        state.removedEmail = call.arguments as String?;
        break;
      case "OneSignal#addSms":
        state.addedSms = call.arguments as String?;
        break;
      case "OneSignal#removeSms":
        state.removedSms = call.arguments as String?;
        break;
      case "OneSignal#getExternalId":
        return state.externalId;
      case "OneSignal#getOnesignalId":
        return state.onesignalId;
      case "OneSignal#lifecycleInit":
        // Could be from user, inappmessages, or pushsubscription
        // We'll track both
        state.lifecycleInitCalled = true;
        state.userLifecycleInitCalled = true;
        break;
      case "OneSignal#trackEvent":
        final args = call.arguments as Map<dynamic, dynamic>;
        state.trackedEventName = args['name'] as String?;
        state.trackedEventProperties =
            args['properties'] as Map<dynamic, dynamic>?;
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
  int? removedNotificationId;
  String? removedNotificationGroup;
  bool? clearedAllNotifications;
  bool? notificationPermission;
  int?
      notificationPermissionNative; // 0 = notDetermined, 1 = denied, 2 = authorized, etc.
  bool? canRequestPermission;
  bool? requestPermissionCalled;
  bool? requestPermissionFallbackToSettings;
  bool? registerForProvisionalAuthorizationCalled;
  bool? nativeClickListenerAdded;
  int nativeClickListenerAddedCount = 0;
  bool? proceedWithWillDisplayCalled;

  // push subscription
  String? pushSubscriptionId;
  String? pushSubscriptionToken;
  bool? pushSubscriptionOptedIn;
  bool pushSubscriptionOptInCalled = false;
  bool pushSubscriptionOptOutCalled = false;
  int pushSubscriptionOptInCallCount = 0;
  int pushSubscriptionOptOutCallCount = 0;

  // session outcomes
  String? addedOutcome;
  int addOutcomeCallCount = 0;
  String? addedUniqueOutcome;
  int addUniqueOutcomeCallCount = 0;
  String? addedOutcomeWithValueName;
  double? addedOutcomeWithValueValue;
  int addOutcomeWithValueCallCount = 0;

  // user
  String? onesignalId;
  Map<dynamic, dynamic>? aliases;
  List<dynamic>? removedAliases;
  String? addedEmail;
  String? removedEmail;
  String? addedSms;
  String? removedSms;
  bool? userLifecycleInitCalled;

  // events
  String? trackedEventName;
  Map<dynamic, dynamic>? trackedEventProperties;

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
