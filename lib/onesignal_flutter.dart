import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/permission.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/utils.dart';

export 'src/permission.dart';
export 'src/defines.dart';


// Handlers for various events
typedef void PermissionChangeHandler(OSPermissionStateChanges changes);


class OneSignal {
  /// A singleton representing the OneSignal SDK.
  /// Note that the iOS and Android native libraries are static,
  /// so if you create multiple instances of OneSignal, they will
  /// mostly share the same state.
  static OneSignal shared = new OneSignal();
  

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal');
  // MethodChannel _tagsChannel = const MethodChannel('OneSignal#tags');

  // event handlers
  PermissionChangeHandler? _onPermissionChangedHandler;

  // constructor method
  OneSignal() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  /// The initializer for OneSignal. Note that this initializer
  /// accepts an iOSSettings object, in Android you can pass null.
  Future<void> setAppId(String appId) async {
    // _onesignalLog(OSLogLevel.verbose,
    //     "Initializing the OneSignal Flutter SDK ($sdkVersion)");

    await _channel.invokeMethod(
        'OneSignal#initialize', {'appId': appId});
  }

   // Private function that gets called by ObjC/Java
  Future<Null> _handleMethod(MethodCall call) async {
    return null;
  }
}
