import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'package:onesignal/src/defines.dart';
import 'package:onesignal/src/notification.dart';

enum OSLogLevel { none, fatal, error, warn, info, debug, verbose }

typedef Future<dynamic> ReceivedNotificationHandler(OSNotification notification);
typedef Future<dynamic> OpenedNotificationHandler(OSNotificationOpenedResult openedResult);

class OneSignal {
  static OneSignal shared = new OneSignal();

  static const MethodChannel _channel =
      const MethodChannel('onesignal');

  OneSignal() {
    print('Setting method call handler');
    OneSignal._channel.setMethodCallHandler(_handleMethod);
  }

  ReceivedNotificationHandler _onReceivedNotification;
  OpenedNotificationHandler _onOpenedNotification;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> init(String appId, Map<String, dynamic> iOSSettings) async {
    await _channel.invokeMethod('OneSignal#init', <String, dynamic> { 
      'appId' : appId,
      'settings' : iOSSettings
    });
  }

  Future<void> setLogLevel(OSLogLevel logLevel, OSLogLevel visualLevel) async {
    await _channel.invokeMethod("OneSignal#setLogLevel", <String, int> { 
      'console' : logLevel.index,
      'visual' : visualLevel.index
    });
  }

  void setNotificationReceivedHandler(ReceivedNotificationHandler handler) {
    _onReceivedNotification = handler;
  }

  void setNotificationOpenedHandler(OpenedNotificationHandler handler) {
    _onOpenedNotification = handler;
  }

  Future<Null> _handleMethod(MethodCall call) async {
    print('Handling method call: ' + call.method);
    switch (call.method) {
      case 'onesignal#handleReceivedNotification':
        print('Received');
        return this._onReceivedNotification(OSNotification.fromJson(call.arguments.cast<String, dynamic>()));
      case 'onesignal#handleOpenedNotification':
        print('Opened');
        return this._onOpenedNotification(OSNotificationOpenedResult.fromJson(call.arguments.cast<String, dynamic>()));
    }
  }
}
