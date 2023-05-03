import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class OneSignalLiveActivities {
  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#liveactivities');

  /// Only applies to iOS
  /// Associates a temporary push token with an Activity ID on the OneSignal server.
  Future<void> enterLiveActivity(String activityId, String token) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod("OneSignal#enterLiveActivity",
          {'activityId': activityId, 'token': token});
    }
  }

  /// Only applies to iOS
  /// Deletes activityId associated temporary push token on the OneSignal server.
  Future<void> exitLiveActivity(String activityId) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          "OneSignal#exitLiveActivity", {'activityId': activityId});
    }
  }
}
