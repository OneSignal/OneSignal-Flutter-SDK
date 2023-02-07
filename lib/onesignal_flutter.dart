import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/permission.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/utils.dart';
import 'package:onesignal_flutter/src/onesignaldebug.dart';

export 'src/permission.dart';
export 'src/defines.dart';
export 'src/onesignaldebug.dart';


// Handlers for various events
typedef void PermissionChangeHandler(OSPermissionStateChanges changes);


class OneSignal {
  /// A singleton representing the OneSignal SDK.
  /// Note that the iOS and Android native libraries are static,
  /// so if you create multiple instances of OneSignal, they will
  /// mostly share the same state.
  static OneSignal shared = new OneSignal();
  static OneSignalDebug Debug = new OneSignalDebug();
  

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal');
 
  /// The initializer for OneSignal. 
  ///
  /// The initializer accepts an [appId] which the developer can get 
  /// from the OneSignal consoleas well as a dictonary of [launchOptions]
  void initialize(String appId) {
    _channel.invokeMethod(
        'OneSignal#initialize', {'appId': appId});
  }

  /// Login to OneSignal under the user identified by the [externalId] provided. 
  /// 
  /// The act of logging a user into the OneSignal SDK will switch the 
  /// [user] context to that specific user.
  void login(String externalId) {
    _channel.invokeMethod(
        'OneSignal#login', {'externalId': externalId});
  }

  /// Logout the user previously logged in via [login]. The [user] property now 
  ///
  /// references a new device-scoped user. A device-scoped user has no user identity 
  /// that can later be retrieved, except through this device as long as the app 
  /// remains installed and the app data is not cleared.
  void logout() {
    _channel.invokeMethod(
        'OneSignal#logout');
  }

  /// Indicates whether privacy consent has been granted. 
  ///
  /// This field is only relevant when the application has 
  /// opted into data privacy protections. See [requiresPrivacyConsent].
  Future<bool> getPrivacyConsent() async {
    var val =
        await _channel.invokeMethod("OneSignal#getPrivacyConsent");

    return val as bool;
  }

  /// Sets the whether or not privacy consent has been [granted]
  ///
  /// This field is only relevant when the application has 
  /// opted into data privacy protections. See [requiresPrivacyConsent].
  Future<void> setPrivacyConsent(bool granted) async {
    await _channel
        .invokeMethod("OneSignal#setPrivacyConsent", {'granted': granted});
  }

  /// A boolean value indicating if the OneSignal SDK is waiting for the
  /// user's consent before it can initialize (if you set the app to
  /// require the user's consent)
  Future<bool> requiresPrivacyConsent() async {
    var val =
        await _channel.invokeMethod("OneSignal#requiresPrivacyConsent");

    return val as bool;
  }

  /// Allows you to completely disable the SDK until your app calls the
  /// OneSignal.setPrivacyConsent(true) function. This is useful if you want
  /// to show a Terms and Conditions or privacy popup for GDPR.
  Future<void> setRequiresPrivacyConsent(bool require) async {
    await _channel.invokeMethod(
        "OneSignal#setRequiresPrivacyConsent", {'required': require});
  }

  /// This method can be used to set if launch URLs should be opened in safari or
  /// within the application. Set to true to launch all notifications with a URL 
  /// in the app instead of the default web browser. Make sure to call setLaunchURLsInApp 
  /// before the initialize call.
  void setLaunchURLsInApp(bool launchUrlsInApp) {
    _channel.invokeMethod(
        'OneSignal#setLaunchURLsInApp', {'launchUrlsInApp': launchUrlsInApp});
  }

  /// Only applies to iOS
  /// Associates a temporary push token with an Activity ID on the OneSignal server.
  Future<void> enterLiveActivity(String activityId, String token) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod("OneSignal#enterLiveActivity", {'activityId': activityId, 'token': token});
    } 
  }

  /// Only applies to iOS
  /// Deletes activityId associated temporary push token on the OneSignal server.
  Future<void> exitLiveActivity(String activityId) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod("OneSignal#exitLiveActivity",
        {'activityId': activityId});
    }
  }

}
