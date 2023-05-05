import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/debug.dart';
import 'package:onesignal_flutter/src/user.dart';
import 'package:onesignal_flutter/src/notifications.dart';
import 'package:onesignal_flutter/src/session.dart';
import 'package:onesignal_flutter/src/location.dart';
import 'package:onesignal_flutter/src/inappmessages.dart';
import 'package:onesignal_flutter/src/liveactivities.dart';

export 'src/defines.dart';
export 'src/pushsubscription.dart';
export 'src/subscription.dart';
export 'src/notification.dart';
export 'src/notifications.dart';
export 'src/inappmessage.dart';
export 'src/inappmessages.dart';
export 'src/liveactivities.dart';

class OneSignal {
  /// A singleton representing the OneSignal SDK.
  /// Note that the iOS and Android native libraries are static,
  /// so if you create multiple instances of OneSignal, they will
  /// mostly share the same state.
  static OneSignal shared = new OneSignal();
  static OneSignalDebug Debug = new OneSignalDebug();
  static OneSignalUser User = new OneSignalUser();
  static OneSignalNotifications Notifications = new OneSignalNotifications();
  static OneSignalSession Session = new OneSignalSession();
  static OneSignalLocation Location = new OneSignalLocation();
  static OneSignalInAppMessages InAppMessages = new OneSignalInAppMessages();
  static OneSignalLiveActivities LiveActivities = new OneSignalLiveActivities();

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal');

  /// The initializer for OneSignal.
  ///
  /// The initializer accepts an [appId] which the developer can get
  /// from the OneSignal consoleas well as a dictonary of [launchOptions]
  void initialize(String appId) {
    _channel.invokeMethod('OneSignal#initialize', {'appId': appId});
    InAppMessages.lifecycleInit();
    User.pushSubscription.lifecycleInit();
    Notifications.lifecycleInit();
  }

  /// Login to OneSignal under the user identified by the [externalId] provided.
  ///
  /// The act of logging a user into the OneSignal SDK will switch the
  /// user context to that specific user.
  Future<void> login(String externalId) async {
    return await _channel
        .invokeMethod('OneSignal#login', {'externalId': externalId});
  }

  /// Login to OneSignal under the user identified by the [externalId] provided.
  ///
  /// The act of logging a user into the OneSignal SDK will switch the
  /// user context to that specific user.
  Future<void> loginWithJWT(String externalId, String jwt) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod(
          'OneSignal#loginWithJWT', {'externalId': externalId, 'jwt': jwt});
    }
  }

  /// Logout the user previously logged in via [login]. The user property now
  ///
  /// references a new device-scoped user. A device-scoped user has no user identity
  /// that can later be retrieved, except through this device as long as the app
  /// remains installed and the app data is not cleared.
  Future<void> logout() async {
    return await _channel.invokeMethod('OneSignal#logout');
  }

  /// Sets the whether or not privacy consent has been [granted]
  ///
  /// This field is only relevant when the application has
  /// opted into data privacy protections. See [consentRequired].
  Future<void> consentGiven(bool granted) async {
    return await _channel
        .invokeMethod("OneSignal#consentGiven", {'granted': granted});
  }

  /// Allows you to completely disable the SDK until your app calls the
  /// OneSignal.consentGiven(true) function. This is useful if you want
  /// to show a Terms and Conditions or privacy popup for GDPR.
  Future<void> consentRequired(bool require) async {
    return await _channel
        .invokeMethod("OneSignal#consentRequired", {'required': require});
  }

  /// This method can be used to set if launch URLs should be opened in safari or
  /// within the application. Set to true to launch all notifications with a URL
  /// in the app instead of the default web browser. Make sure to call setLaunchURLsInApp
  /// before the initialize call.
  Future<void> setLaunchURLsInApp(bool launchUrlsInApp) async {
    if (Platform.isIOS) {
      return await _channel.invokeMethod(
          'OneSignal#setLaunchURLsInApp', {'launchUrlsInApp': launchUrlsInApp});
    }
  }
}
