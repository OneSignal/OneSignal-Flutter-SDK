import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class OneSignalLiveActivities {
  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#liveactivities');

  /**
   * Indicate this device has exited a live activity, identified within OneSignal by the `activityId`.
   *
   * Only applies to iOS
   *
   * @param activityId: The activity identifier the live activity on this device will receive updates for.
   * @param token: The activity's update token to receive the updates.
   **/
  Future<void> enterLiveActivity(String activityId, String token) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod("OneSignal#enterLiveActivity",
          {'activityId': activityId, 'token': token});
    }
  }

  /**
   * Indicate this device has exited a live activity, identified within OneSignal by the `activityId`.
   *
   * Only applies to iOS
   *
   * @param activityId: The activity identifier the live activity on this device will no longer receive updates for.
   **/
  Future<void> exitLiveActivity(String activityId) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          "OneSignal#exitLiveActivity", {'activityId': activityId});
    }
  }

  /**
   * Enable the OneSignalSDK to setup the default`DefaultLiveActivityAttributes` structure,
   * which conforms to the `OneSignalLiveActivityAttributes`. When using this function, the
   * widget attributes are owned by the OneSignal SDK, which will allow the SDK to handle the
   * entire lifecycle of the live activity.  All that is needed from an app-perspective is to
   * create a Live Activity widget in a widget extension, with a `ActivityConfiguration` for
   * `DefaultLiveActivityAttributes`. This is most useful for users that (1) only have one Live
   * Activity widget and (2) are using a cross-platform framework and do not want to create the
   * cross-platform <-> iOS native bindings to manage ActivityKit.
   *
   * Only applies to iOS
   * 
   * @param options: An optional structure to provide for more granular setup options.
   */
  Future<void> setupDefault({LiveActivitySetupOptions? options=null}) async {
    if (Platform.isIOS) {
      dynamic optionsMap = null;
      
      if(options != null) {
        optionsMap = {
          'enablePushToStart': options.enablePushToStart,
          'enablePushToUpdate': options.enablePushToUpdate,
        };
      } 

      return await _channel.invokeMethod(
          "OneSignal#setupDefault", {'options': optionsMap });
    }
  }

  /**
   * Start a new LiveActivity that is modelled by the default`DefaultLiveActivityAttributes`
   * structure. The `DefaultLiveActivityAttributes` is initialized with the dynamic `attributes`
   * and `content` passed in.
   * 
   * Only applies to iOS
   * 
   * @param activityId: The activity identifier the live activity on this device will be started
   * and eligible to receive updates for.
   * @param attributes: A dynamic type containing the static attributes passed into `DefaultLiveActivityAttributes`.
   * @param content: A dynamic type containing the content attributes passed into `DefaultLiveActivityAttributes`.
   */
  Future<void> startDefault(String activityId, dynamic attributes, dynamic content) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          "OneSignal#startDefault", { 'activityId': activityId, 'attributes': attributes, 'content': content });
    }
  }

  /**
   * Indicate this device is capable of receiving pushToStart live activities for the
   * `activityType`. The `activityType` **must** be the name of the struct conforming
   * to `ActivityAttributes` that will be used to start the live activity.
   *
   * Only applies to iOS
   *
   * @param activityType: The name of the specific `ActivityAttributes` structure tied
   * to the live activity.
   * @param token: The activity type's pushToStart token.
   */
  Future<void> setPushToStartToken(String activityType, String token) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod("OneSignal#setPushToStartToken",
          {'activityType': activityType, 'token': token});
    }
  }

  /**
   * Indicate this device is no longer capable of receiving pushToStart live activities
   * for the `activityType`. The `activityType` **must** be the name of the struct conforming
   * to `ActivityAttributes` that will be used to start the live activity.
   *
   * Only applies to iOS
   *
   * @param activityType: The name of the specific `ActivityAttributes` structure tied
   * to the live activity.
   */
  Future<void> removePushToStartToken(String activityType) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          "OneSignal#removePushToStartToken", {'activityType': activityType});
    }
  }
}

/**
 * The setup options for `OneSignal.LiveActivities.setupDefault`.
 */
class LiveActivitySetupOptions {
  bool _enablePushToStart = true;
  bool _enablePushToUpdate = true;

  LiveActivitySetupOptions({bool enablePushToStart = true, bool enablePushToUpdate = true}) {
    this._enablePushToStart = enablePushToStart;
    this._enablePushToUpdate = enablePushToUpdate;
  }

  /**
   * When true, OneSignal will listen for pushToStart tokens.
   */
  bool get enablePushToStart {
    return this._enablePushToStart;
  }

  /**
   * When true, OneSignal will listen for pushToUpdate  tokens for each started live activity.
   */
  bool get enablePushToUpdate {
    return this._enablePushToUpdate;
  }
}