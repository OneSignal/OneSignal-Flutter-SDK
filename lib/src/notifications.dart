
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/notification.dart';



typedef void OpenedNotificationHandler(OSNotificationOpenedResult openedResult);


class OneSignalNotifications {

  // event handlers
  OpenedNotificationHandler? _onOpenedNotification;

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#notifications');

  // constructor method
  OneSignalNotifications() {
    this._channel.setMethodCallHandler(_handleMethod);
  }


  Future<bool> permission() async {
    return await _channel
        .invokeMethod("OneSignal#permission");
  }

  Future<bool> canRequest() async {
    return await _channel
        .invokeMethod("OneSignal#canRequest");
  }

  Future<void> clearAll() async {
    return await _channel
        .invokeMethod("OneSignal#clearAll");
  }

  Future<bool> requestPermission(bool fallbackToSettings) async {
     return await _channel.invokeMethod("OneSignal#requestPermission", {'fallbackToSettings' : fallbackToSettings});
  }

  Future<bool> registerForProvisionalAuthorization(bool fallbackToSettings) async {
     return await _channel.invokeMethod("OneSignal#registerForProvisionalAuthorization");
  }

  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'OneSignal#handleOpenedNotification' &&
        this._onOpenedNotification != null) {
      this._onOpenedNotification!(
          OSNotificationOpenedResult(call.arguments.cast<String, dynamic>()));
    } else 
        return null;
  }
   


  /// The notification opened handler is called whenever the user opens a
  /// OneSignal push notification, or taps an action button on a notification.
  void setNotificationOpenedHandler(OpenedNotificationHandler handler) {
    _onOpenedNotification = handler;
    _channel.invokeMethod("OneSignal#initNotificationOpenedHandlerParams");
  }



}
