import 'dart:async';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';

class OneSignalDebug {
  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#debug');

  /// Sets the log level for the SDK.
  ///
  /// The parameter [logLevel] controls
  /// how verbose logs in the console/logcat are
  Future<void> setLogLevel(OSLogLevel logLevel) async {
    return await _channel
        .invokeMethod("OneSignal#setLogLevel", {'logLevel': logLevel.index});
  }

  /// Sets the log level for the SDK.
  ///
  /// The parameter [visualLevel] controls
  /// if the SDK will show alerts for each logged message
  Future<void> setAlertLevel(OSLogLevel visualLevel) async {
    return await _channel.invokeMethod(
        "OneSignal#setAlertLevel", {'visualLevel': visualLevel.index});
  }
}
