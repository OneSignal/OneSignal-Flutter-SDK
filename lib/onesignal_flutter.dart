import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/permission.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/utils.dart';
import 'package:onesignal_flutter/src/onesignaldebug.dart';

export 'src/permission.dart';
export 'src/defines.dart';
export 'src/onesignaldebug.dart';


// Handlers for various events
typedef void PermissionChangeHandler(OSPermissionStateChanges changes);


class OneSignal {
  /// A singleton representing the OneSignal SDK.
  /// Note that the iOS and Android native libraries are static,
  /// so if you create multiple instances of OneSignal, they will
  /// mostly share the same state.
  static OneSignal shared = new OneSignal();
  static OneSignalDebug Debug = new OneSignalDebug();
  

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal');
 
  /// The initializer for OneSignal. 
  ///
  /// The initializer accepts an [appId] which the developer can get 
  /// from the OneSignal consoleas well as a dictonary of [launchOptions]
  void initialize(String appId) {
    _channel.invokeMethod(
        'OneSignal#initialize', {'appId': appId});
  }
  // constructor method
  OneSignal() {
    this._channel.setMethodCallHandler(_handleMethod);
  }
   // Private function that gets called by ObjC/Java
  Future<Null> _handleMethod(MethodCall call) async {
    return null;
  }
}
