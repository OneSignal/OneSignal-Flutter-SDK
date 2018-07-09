import 'dart:async';

import 'package:flutter/services.dart';

enum OneSignalLogLevel { none, fatal, error, warn, info, debug, verbose }

class OneSignal {
  static const MethodChannel _channel =
      const MethodChannel('onesignal');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> init(String appId) async {
    await _channel.invokeMethod('OneSignal#init', <String, String> { 
      'appId' : appId 
    });
  }

  static Future<void> setLogLevel(OneSignalLogLevel logLevel, OneSignalLogLevel visualLevel) async {
    await _channel.invokeMethod("OneSignal#setLogLevel", <String, int> { 
      'console' : logLevel.index,
      'visual' : visualLevel.index
    });
  }
}
