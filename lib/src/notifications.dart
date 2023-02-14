
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';

class OneSignalNotifications {

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#notifications');

  Future<bool> setPrivacyConsent(bool fallbackToSettings) async {
    return await _channel
        .invokeMethod("OneSignal#requestPermission", {'fallbackToSettings': fallbackToSettings});
  }

}
