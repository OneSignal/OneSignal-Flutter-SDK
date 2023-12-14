import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/notification.dart';

typedef void OnNotificationPermissionChangeObserver(bool permission);

typedef void OnNotificationWillDisplayListener(
    OSNotificationWillDisplayEvent event);

typedef void OnNotificationClickListener(OSNotificationClickEvent event);

class OneSignalNotifications {
  // event listeners
  List<OnNotificationClickListener> _clickListeners =
      <OnNotificationClickListener>[];
  List<OnNotificationWillDisplayListener> _willDisplayListeners =
      <OnNotificationWillDisplayListener>[];

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#notifications');

  List<OnNotificationPermissionChangeObserver> _observers =
      <OnNotificationPermissionChangeObserver>[];
  // constructor method
  OneSignalNotifications() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  bool _permission = false;

  bool _clickHandlerRegistered = false;

  /// Whether this app has push notification permission.
  bool get permission {
    return _permission;
  }

  /// iOS only
  /// enum OSNotificationPermission {
  /// notDetermined,
  /// denied,
  /// authorized,
  /// provisional, // only available in iOS 12
  /// ephemeral, // only available in iOS 14
  Future<OSNotificationPermission> permissionNative() async {
    if (Platform.isIOS) {
      return OSNotificationPermission
          .values[await _channel.invokeMethod("OneSignal#permissionNative")];
    } else {
      return _permission
          ? OSNotificationPermission.authorized
          : OSNotificationPermission.denied;
    }
  }

  /// Whether attempting to request notification permission will show a prompt.
  /// Returns true if the device has not been prompted for push notification permission already.
  Future<bool> canRequest() async {
    return await _channel.invokeMethod("OneSignal#canRequest");
  }

  /// Removes a single notification.
  Future<void> removeNotification(int notificationId) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod(
          "OneSignal#removeNotification", {'notificationId': notificationId});
    }
  }

  /// Removes a grouped notification.
  Future<void> removeGroupedNotifications(String notificationGroup) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod("OneSignal#removeGroupedNotifications",
          {'notificationGroup': notificationGroup});
    }
  }

  /// Removes all OneSignal notifications.
  Future<void> clearAll() async {
    return await _channel.invokeMethod("OneSignal#clearAll");
  }

  /// Prompt the user for permission to receive push notifications. This will display the native
  /// system prompt to request push notification permission.
  Future<bool> requestPermission(bool fallbackToSettings) async {
    return await _channel.invokeMethod("OneSignal#requestPermission",
        {'fallbackToSettings': fallbackToSettings});
  }

  /// Instead of having to prompt the user for permission to send them push notifications,
  /// your app can request provisional authorization.
  Future<bool> registerForProvisionalAuthorization(
      bool fallbackToSettings) async {
    if (Platform.isIOS) {
      return await _channel
          .invokeMethod("OneSignal#registerForProvisionalAuthorization");
    } else {
      return false;
    }
  }

  /// The OSNotificationPermissionObserver.onNotificationPermissionDidChange method will be fired on the passed-in object
  /// when a notification permission setting changes. This happens when the user enables or disables
  /// notifications for your app from the system settings outside of your app.
  void addPermissionObserver(OnNotificationPermissionChangeObserver observer) {
    _observers.add(observer);
  }

  // Remove a push subscription observer that has been previously added.
  void removePermissionObserver(
      OnNotificationPermissionChangeObserver observer) {
    _observers.remove(observer);
  }

  Future<void> lifecycleInit() async {
    _permission = await _channel.invokeMethod("OneSignal#permission");
    addPermissionObserver((permission) {
      _permission = permission;
    });
    return await _channel.invokeMethod("OneSignal#lifecycleInit");
  }

  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'OneSignal#onClickNotification') {
      for (var listener in _clickListeners) {
        listener(
            OSNotificationClickEvent(call.arguments.cast<String, dynamic>()));
      }
    } else if (call.method == 'OneSignal#onWillDisplayNotification') {
      for (var listener in _willDisplayListeners) {
        listener(OSNotificationWillDisplayEvent(
            call.arguments.cast<String, dynamic>()));
      }
      var event = OSNotificationWillDisplayEvent(
          call.arguments.cast<String, dynamic>());
      _channel.invokeMethod("OneSignal#proceedWithWillDisplay",
          {'notificationId': event.notification.notificationId});
    } else if (call.method == 'OneSignal#onNotificationPermissionDidChange') {
      this.onNotificationPermissionDidChange(call.arguments["permission"]);
    }
    return null;
  }

  void onNotificationPermissionDidChange(bool permission) {
    for (var observer in _observers) {
      observer(permission);
    }
  }

  void addForegroundWillDisplayListener(
      OnNotificationWillDisplayListener listener) {
    _willDisplayListeners.add(listener);
  }

  void removeForegroundWillDisplayListener(
      OnNotificationWillDisplayListener listener) {
    _willDisplayListeners.remove(listener);
  }

  /// The notification willDisplay listener is called whenever a notification arrives
  /// and the application is in foreground
  void preventDefault(String notificationId) {
    _channel.invokeMethod(
        "OneSignal#preventDefault", {'notificationId': notificationId});
  }

  void displayNotification(String notificationId) {
    _channel.invokeMethod(
        "OneSignal#displayNotification", {'notificationId': notificationId});
  }

  /// The notification click listener is called whenever the user opens a
  /// OneSignal push notification, or taps an action button on a notification.
  void addClickListener(OnNotificationClickListener listener) {
    if (!_clickHandlerRegistered) {
      _clickHandlerRegistered = true;
      _channel.invokeMethod("OneSignal#addNativeClickListener");
    }
    _clickListeners.add(listener);
  }

  void removeClickListener(OnNotificationClickListener listener) {
    _clickListeners.remove(listener);
  }
}
