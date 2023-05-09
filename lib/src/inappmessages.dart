import 'dart:async';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:onesignal_flutter/src/inappmessage.dart';

typedef void OnClickInAppMessageListener(OSInAppMessageClickEvent event);

typedef void OnWillDisplayInAppMessageListener(
    OSInAppMessageWillDisplayEvent event);
typedef void OnDidDisplayInAppMessageListener(
    OSInAppMessageDidDisplayEvent event);
typedef void OnWillDismissInAppMessageListener(
    OSInAppMessageWillDismissEvent event);
typedef void OnDidDismissInAppMessageListener(
    OSInAppMessageDidDismissEvent event);

class OneSignalInAppMessages {
  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#inappmessages');

  // constructor method
  OneSignalInAppMessages() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  List<OnClickInAppMessageListener> _clickListeners =
      <OnClickInAppMessageListener>[];
  List<OnWillDisplayInAppMessageListener> _willDisplayListeners =
      <OnWillDisplayInAppMessageListener>[];
  List<OnDidDisplayInAppMessageListener> _didDisplayListeners =
      <OnDidDisplayInAppMessageListener>[];
  List<OnWillDismissInAppMessageListener> _willDismissListeners =
      <OnWillDismissInAppMessageListener>[];
  List<OnDidDismissInAppMessageListener> _didDismissListeners =
      <OnDidDismissInAppMessageListener>[];

  /// Adds a single key, value trigger, which will trigger an in app message
  /// if one exists matching the specific trigger added
  Future<void> addTrigger(String key, String value) async {
    return await _channel.invokeMethod("OneSignal#addTrigger", {key: value});
  }

  /// Adds one or more key, value triggers, which will trigger in app messages
  /// (one at a time) if any exist matching the specific triggers added
  Future<void> addTriggers(Map<String, String> triggers) async {
    return await _channel.invokeMethod("OneSignal#addTriggers", triggers);
  }

  /// Remove a single key, value trigger to prevent an in app message from
  /// showing with that trigger
  Future<void> removeTrigger(String key) async {
    return await _channel.invokeMethod("OneSignal#removeTrigger", key);
  }

  /// Remove one or more key, value triggers to prevent any in app messages
  /// from showing with those triggers
  Future<void> removeTriggers(List<String> keys) async {
    return await _channel.invokeMethod("OneSignal#removeTriggers", keys);
  }

  /// Get the trigger value associated with the key provided
  Future<void> clearTriggers() async {
    return await _channel.invokeMethod("OneSignal#clearTriggers");
  }

  /// Toggles the showing of all in app messages
  Future<void> paused(bool pause) async {
    return await _channel.invokeMethod("OneSignal#paused", pause);
  }

  /// Gets whether of not in app messages are paused
  Future<bool> arePaused() async {
    return await _channel.invokeMethod("OneSignal#arePaused");
  }

  Future<void> lifecycleInit() async {
    return await _channel.invokeMethod("OneSignal#lifecycleInit");
  }

  // Private function that gets called by ObjC/Java
  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'OneSignal#onClickInAppMessage') {
      for (var listener in _clickListeners) {
        listener(
            OSInAppMessageClickEvent(call.arguments.cast<String, dynamic>()));
      }
    } else if (call.method == 'OneSignal#onWillDisplayInAppMessage') {
      for (var listener in _willDisplayListeners) {
        listener(OSInAppMessageWillDisplayEvent(
            call.arguments.cast<String, dynamic>()));
      }
    } else if (call.method == 'OneSignal#onDidDisplayInAppMessage') {
      for (var listener in _didDisplayListeners) {
        listener(OSInAppMessageDidDisplayEvent(
            call.arguments.cast<String, dynamic>()));
      }
    } else if (call.method == 'OneSignal#onWillDismissInAppMessage') {
      for (var listener in _willDismissListeners) {
        listener(OSInAppMessageWillDismissEvent(
            call.arguments.cast<String, dynamic>()));
      }
    } else if (call.method == 'OneSignal#onDidDismissInAppMessage') {
      for (var listener in _didDismissListeners) {
        listener(OSInAppMessageDidDismissEvent(
            call.arguments.cast<String, dynamic>()));
      }
    }
    return null;
  }

  /// The in app message clicked handler is called whenever the user clicks a
  /// OneSignal IAM button or image with an action event attacthed to it
  void addClickListener(OnClickInAppMessageListener listener) {
    _clickListeners.add(listener);
  }

  void removeClickListener(OnClickInAppMessageListener listener) {
    _clickListeners.remove(listener);
  }

  void addWillDisplayListener(OnWillDisplayInAppMessageListener listener) {
    _willDisplayListeners.add(listener);
  }

  void removeWillDisplayListener(OnWillDisplayInAppMessageListener listener) {
    _willDisplayListeners.remove(listener);
  }

  void addDidDisplayListener(OnDidDisplayInAppMessageListener listener) {
    _didDisplayListeners.add(listener);
  }

  void removeDidDisplayListener(OnDidDisplayInAppMessageListener listener) {
    _didDisplayListeners.remove(listener);
  }

  void addWillDismissListener(OnWillDismissInAppMessageListener listener) {
    _willDismissListeners.add(listener);
  }

  void removeWillDismissListener(OnWillDismissInAppMessageListener listener) {
    _willDismissListeners.remove(listener);
  }

  void addDidDismissListener(OnDidDismissInAppMessageListener listener) {
    _didDismissListeners.add(listener);
  }

  void removeDidDismissListener(OnDidDismissInAppMessageListener listener) {
    _didDismissListeners.remove(listener);
  }
}
