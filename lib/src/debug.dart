import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';

class OneSignalDebug {

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#debug');

  /// Sets the log level for the SDK. 
  ///
  /// The parameter [logLevel] controls
  /// how verbose logs in the console/logcat are
  void setLogLevel(OSLogLevel logLevel) {
    _channel.invokeMethod("OneSignal#setLogLevel",
        {'logLevel': logLevel.index});
  }

  /// Sets the log level for the SDK. 
  ///
  /// The parameter [visualLevel] controls
  /// if the SDK will show alerts for each logged message
  void setVisualLevel( OSLogLevel visualLevel) {
    _channel.invokeMethod("OneSignal#setVisualLevel",
        {'visualLevel': visualLevel.index});
  }
}
