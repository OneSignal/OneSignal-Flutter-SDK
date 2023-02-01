import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';

class OneSignalDebug {

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#debug');

  // constructor method
  OneSignalDebug() {
    this._channel.setMethodCallHandler(_handleMethod);
  }
   // Private function that gets called by ObjC/Java
  Future<Null> _handleMethod(MethodCall call) async {
    return null;
  }

  /// Sets the log level for the SDK. 
  ///
  /// The parameter [logLevel] controls
  /// how verbose logs in the console/logcat are
  void setLogLevel(OSLogLevel logLevel) {
    _channel.invokeMethod("OneSignal#setLogLevel",
        {'console': logLevel.index});
  }

  /// Sets the log level for the SDK. 
  ///
  /// The parameter [visualLevel] controls
  /// if the SDK will show alerts for each logged message
  void setVisualLevel( OSLogLevel visualLevel) {
    _channel.invokeMethod("OneSignal#setVisualLevel",
        {'visual': visualLevel.index});
  }
}
