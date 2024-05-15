import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class OneSignalLiveActivities {
  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#liveactivities');

  /// Indicate this device has exited a live activity, identified within OneSignal by the [activityId]. The
  /// [token] is the ActivityKit's update token that will be used to update the live activity.
  ///
  /// Only applies to iOS.
  Future<void> enterLiveActivity(String activityId, String token) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod("OneSignal#enterLiveActivity",
          {'activityId': activityId, 'token': token});
    }
  }

  /// Indicate this device has exited a live activity, identified within OneSignal by the [activityId].
  ///
  /// Only applies to iOS.
  Future<void> exitLiveActivity(String activityId) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          "OneSignal#exitLiveActivity", {'activityId': activityId});
    }
  }

  /// Enable the OneSignalSDK to setup the default`DefaultLiveActivityAttributes` structure,
  /// which conforms to the `OneSignalLiveActivityAttributes`. When using this function, the
  /// widget attributes are owned by the OneSignal SDK, which will allow the SDK to handle the
  /// entire lifecycle of the live activity.  All that is needed from an app-perspective is to
  /// create a Live Activity widget in a widget extension, with a `ActivityConfiguration` for
  /// `DefaultLiveActivityAttributes`. This is most useful for users that (1) only have one Live
  /// Activity widget and (2) are using a cross-platform framework and do not want to create the
  /// cross-platform <-> iOS native bindings to manage ActivityKit. An optional [options]
  /// parameter can be provided for more granular setup options.
  ///
  /// Only applies to iOS.
  Future<void> setupDefault({LiveActivitySetupOptions? options}) async {
    if (Platform.isIOS) {
      dynamic optionsMap;

      if (options != null) {
        optionsMap = {
          'enablePushToStart': options.enablePushToStart,
          'enablePushToUpdate': options.enablePushToUpdate,
        };
      }

      return await _channel
          .invokeMethod("OneSignal#setupDefault", {'options': optionsMap});
    }
  }

  /// Start a new LiveActivity that is modelled by the default`DefaultLiveActivityAttributes`
  /// structure. The `DefaultLiveActivityAttributes` is initialized with the dynamic [attributes]
  /// and [content] passed in.  The live activity started can be updated with the [activityId]
  /// provided.
  ///
  /// Only applies to iOS.
  Future<void> startDefault(
      String activityId, dynamic attributes, dynamic content) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod("OneSignal#startDefault", {
        'activityId': activityId,
        'attributes': attributes,
        'content': content
      });
    }
  }

  /// Indicate this device is capable of receiving pushToStart live activities for the
  /// [activityType]. The [activityType] **must** be the name of the struct conforming
  /// to `ActivityAttributes` that will be used to start the live activity. The [token]
  /// is ActivityKit's pushToStart token that will be used to start the live activity.
  ///
  /// Only applies to iOS.
  Future<void> setPushToStartToken(String activityType, String token) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod("OneSignal#setPushToStartToken",
          {'activityType': activityType, 'token': token});
    }
  }

  /// Indicate this device is no longer capable of receiving pushToStart live activities
  /// for the [activityType]. The [activityType] **must** be the name of the struct conforming
  /// to `ActivityAttributes` that will be used to start the live activity.
  ///
  /// Only applies to iOS.
  Future<void> removePushToStartToken(String activityType) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          "OneSignal#removePushToStartToken", {'activityType': activityType});
    }
  }
}

/// The setup options for [OneSignal.LiveActivities.setupDefault].
class LiveActivitySetupOptions {
  bool _enablePushToStart = true;
  bool _enablePushToUpdate = true;

  LiveActivitySetupOptions(
      {bool enablePushToStart = true, bool enablePushToUpdate = true}) {
    this._enablePushToStart = enablePushToStart;
    this._enablePushToUpdate = enablePushToUpdate;
  }

  /// When true, OneSignal will listen for pushToStart tokens.
  bool get enablePushToStart {
    return this._enablePushToStart;
  }

  /// When true, OneSignal will listen for pushToUpdate tokens for each started live activity.
  bool get enablePushToUpdate {
    return this._enablePushToUpdate;
  }
}
