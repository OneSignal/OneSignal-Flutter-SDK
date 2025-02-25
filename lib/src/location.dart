import 'dart:async';
import 'package:flutter/services.dart';

class OneSignalLocation {
  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#location');

  /// Allows you to prompt the user for permission to use location services
  Future<void> requestPermission() async {
    return await _channel.invokeMethod("OneSignal#requestPermission");
  }

  /// Set whether location is currently shared with OneSignal.
  Future<void> setShared(bool shared) async {
    return await _channel.invokeMethod("OneSignal#setShared", shared);
  }

  /// Allows you to determine if the user's location data is shared with OneSignal.
  /// This allows you to do things like geofenced notifications, etc.
  Future<bool> isShared() async {
    return await _channel.invokeMethod("OneSignal#isShared");
  }
}
