import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

/*
  This class mocks an iOS or Android host device
  It has a OneSignalState object that reflects changes to
  state that the various requests make.
*/

class OneSignalMockChannelController {
  MethodChannel _channel = const MethodChannel('OneSignal');
  MethodChannel _debugChannel = const MethodChannel('OneSignal#debug');
  MethodChannel _tagsChannel = const MethodChannel('OneSignal#tags');

  late OneSignalState state;

  OneSignalMockChannelController() {
    this._channel.setMockMethodCallHandler(_handleMethod);
    this._tagsChannel.setMockMethodCallHandler(_handleMethod);
    this._debugChannel.setMockMethodCallHandler(_handleMethod);
  }

  void resetState() {
    state = OneSignalState();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    print("Mock method called: ${call.method}");
    switch (call.method) {
      case "OneSignal#setAppId":
        this.state.setAppId(call.arguments);
        break;
      case "OneSignal#setLogLevel":
        this.state.setLogLevel(call.arguments);
        break;
      case "OneSignal#consentGiven":
        this.state.consentGiven =
            (call.arguments as Map<dynamic, dynamic>)['given'] as bool?;
        break;
      case "OneSignal#promptPermission":
        this.state.calledPromptPermission = true;
        break;
      case "OneSignal#log":
        this.state.log(call.arguments);
        break;
      case "OneSignal#disablePush":
        this.state.disablePush = call.arguments as bool?;
        break;
      case "OneSignal#postNotification":
        this.state.postNotificationJson =
            call.arguments as Map<dynamic, dynamic>?;
        return {"success": true};
      case "OneSignal#setLocationShared":
        this.state.locationShared = call.arguments as bool?;
        break;
      case "OneSignal#setEmail":
        this.state.setEmail(call.arguments);
        break;
      case "OneSignal#sendTags":
        this.state.tags = call.arguments;
        return {"success": true};
      case "OneSignal#deleteTags":
        this.state.deleteTags = call.arguments;
        return {"success": true};
      case "OneSignal#setExternalUserId":
        this.state.externalId = (call.arguments
            as Map<dynamic, dynamic>)['externalUserId'] as String?;
        return {"success": true};
      case "OneSignal#removeExternalUserId":
        this.state.externalId = null;
        return {"success": true};
      case "OneSignal#setLanguage":
        this.state.language =
            (call.arguments as Map<dynamic, dynamic>)['language'] as String?;
        return {"success": true};
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
  bool? disablePush;
  String? externalId;
  String? language;

  // tags
  Map<dynamic, dynamic>? tags;
  List<dynamic>? deleteTags;

  // notifications
  Map<dynamic, dynamic>? postNotificationJson;

  /*
    All of the following functions parse the MethodCall
    parameters, and sets properties on the object itself
  */

  void setAppId(Map<dynamic, dynamic> params) {
    this.appId = params['appId'];
  }

  void setLogLevel(Map<dynamic, dynamic> params) {
    int? level = params['logLevel'] as int?;
    int? visual = params['visual'] as int?;

    if (level != null) this.logLevel = OSLogLevel.values[level];
    if (visual != null) this.visualLevel = OSLogLevel.values[visual];
  }

  void consentRequired(Map<dynamic, dynamic> params) {
    this.requiresPrivacyConsent = params['required'] as bool?;
  }

  void log(Map<dynamic, dynamic> params) {
    var level = params['logLevel'] as int?;

    if (level != null) this.latestLogLevel = OSLogLevel.values[level];
    this.latestLogStatement = params['message'];
  }

  void setEmail(Map<dynamic, dynamic> params) {
    this.email = params['email'] as String?;
    this.emailAuthHashToken = params['emailAuthHashToken'] as String?;
  }
}
