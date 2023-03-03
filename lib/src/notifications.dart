import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/notification.dart';
import 'package:onesignal_flutter/src/permission.dart';

typedef void OpenedNotificationHandler(OSNotificationOpenedResult openedResult);
typedef void NotificationWillShowInForegroundHandler(
    OSNotificationReceivedEvent event);

class OneSignalNotifications {
  // event handlers
  OpenedNotificationHandler? _onOpenedNotification;
  NotificationWillShowInForegroundHandler?
      _onNotificationWillShowInForegroundHandler;

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#notifications');

  List<OneSignalPermissionObserver> _observers =
      <OneSignalPermissionObserver>[];
  // constructor method
  OneSignalNotifications() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  bool _permission = false;

  /// Whether this app has push notification permission.
  bool get permission {
    return _permission;
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

  /// The OSPermissionObserver.onOSPermissionChanged method will be fired on the passed-in object
  /// when a notification permission setting changes. This happens when the user enables or disables
  /// notifications for your app from the system settings outside of your app.
  void addPermssionObserver(OneSignalPermissionObserver observer) {
    _observers.add(observer);
  }

  // Remove a push subscription observer that has been previously added.
  void removePermissionObserver(OneSignalPermissionObserver observer) {
    _observers.remove(observer);
  }

  Future<void> lifecycleInit() async {
    _channel.invokeMethod(
        "OneSignal#initNotificationWillShowInForegroundHandlerParams");
    _permission = await _channel.invokeMethod("OneSignal#permission");
    await _channel
        .invokeMethod("OneSignal#initNotificationOpenedHandlerParams");
    return await _channel.invokeMethod("OneSignal#lifecycleInit");
  }

  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'OneSignal#handleOpenedNotification' &&
        this._onOpenedNotification != null) {
      this._onOpenedNotification!(
          OSNotificationOpenedResult(call.arguments.cast<String, dynamic>()));
    } else if (call.method ==
            'OneSignal#handleNotificationWillShowInForeground' &&
        this._onNotificationWillShowInForegroundHandler != null) {
      this._onNotificationWillShowInForegroundHandler!(
          OSNotificationReceivedEvent(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#OSPermissionChanged') {
      this.onOSPermissionChangedHandler(
          OSPermissionState(call.arguments.cast<String, dynamic>()));
    }
    return null;
  }

  Future<void> onOSPermissionChangedHandler(OSPermissionState state) async {
    _permission = state.permission;
    for (var observer in _observers) {
      observer.onOSPermissionChanged(_permission);
    }
  }

  /// The notification foreground handler is called whenever a notification arrives
  /// and the application is in foreground
  void setNotificationWillShowInForegroundHandler(
      NotificationWillShowInForegroundHandler handler) {
    _onNotificationWillShowInForegroundHandler = handler;
  }

  /// The notification foreground handler is called whenever a notification arrives
  /// and the application is in foreground
  void completeNotification(String notificationId, bool shouldDisplay) {
    _channel.invokeMethod("OneSignal#completeNotification",
        {'notificationId': notificationId, 'shouldDisplay': shouldDisplay});
  }

  /// The notification opened handler is called whenever the user opens a
  /// OneSignal push notification, or taps an action button on a notification.
  void setNotificationOpenedHandler(OpenedNotificationHandler handler) {
    _onOpenedNotification = handler;
  }
}

class OneSignalPermissionObserver {
  void onOSPermissionChanged(bool state) {}
}
