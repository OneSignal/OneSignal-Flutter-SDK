import 'dart:async';
import 'package:flutter/services.dart';

class OneSignalSession {
  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#session');

  /// Send a normal outcome event for the current session and notifications with the attribution window
  /// Counted each time sent successfully, failed ones will be cached and reattempted in future
  Future<void> addOutcome(String name) async {
    return await _channel.invokeMethod("OneSignal#addOutcome", name);
  }

  /// Send a unique outcome event for the current session and notifications with the attribution window
  /// Counted once per notification when sent successfully, failed ones will be cached and reattempted in future
  Future<void> addUniqueOutcome(String name) async {
    return await _channel.invokeMethod("OneSignal#addUniqueOutcome", name);
  }

  /// Send an outcome event with a value for the current session and notifications with the attribution window
  /// Counted each time sent successfully, failed ones will be cached and reattempted in future
  Future<void> addOutcomeWithValue(String name, double value) async {
    return await _channel.invokeMethod("OneSignal#addOutcomeWithValue",
        {"outcome_name": name, "outcome_value": value});
  }
}
