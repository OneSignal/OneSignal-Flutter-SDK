import 'dart:async';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/inappmessage.dart';

typedef void InAppMessageClickedHandler(OSInAppMessageAction action);

class OneSignalInAppMessageLifecycleListener {
  void onWillDisplayInAppMessage(OSInAppMessageWillDisplayEvent event) {}
  void onDidDisplayInAppMessage(OSInAppMessageDidDisplayEvent event) {}
  void onWillDismissInAppMessage(OSInAppMessageWillDismissEvent event) {}
  void onDidDismissInAppMessage(OSInAppMessageDidDismissEvent event) {}
}

class OneSignalInAppMessages {
  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#inappmessages');

  // constructor method
  OneSignalInAppMessages() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  InAppMessageClickedHandler? _onInAppMessageClickedHandler;
  List<OneSignalInAppMessageLifecycleListener> _lifecycleListeners =
      <OneSignalInAppMessageLifecycleListener>[];

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
    if (call.method == 'OneSignal#handleClickedInAppMessage' &&
        this._onInAppMessageClickedHandler != null) {
      this._onInAppMessageClickedHandler!(
          OSInAppMessageAction(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#onWillDisplayInAppMessage') {
      for (var listener in _lifecycleListeners) {
        listener.onWillDisplayInAppMessage(OSInAppMessageWillDisplayEvent(
            call.arguments.cast<String, dynamic>()));
      }
    } else if (call.method == 'OneSignal#onDidDisplayInAppMessage') {
      for (var listener in _lifecycleListeners) {
        listener.onDidDisplayInAppMessage(OSInAppMessageDidDisplayEvent(
            call.arguments.cast<String, dynamic>()));
      }
    } else if (call.method == 'OneSignal#onWillDismissInAppMessage') {
      for (var listener in _lifecycleListeners) {
        listener.onWillDismissInAppMessage(OSInAppMessageWillDismissEvent(
            call.arguments.cast<String, dynamic>()));
      }
    } else if (call.method == 'OneSignal#onDidDismissInAppMessage') {
      for (var listener in _lifecycleListeners) {
        listener.onDidDismissInAppMessage(OSInAppMessageDidDismissEvent(
            call.arguments.cast<String, dynamic>()));
      }
    }
    return null;
  }

  /// The in app message clicked handler is called whenever the user clicks a
  /// OneSignal IAM button or image with an action event attacthed to it
  void setInAppMessageClickedHandler(InAppMessageClickedHandler handler) {
    _onInAppMessageClickedHandler = handler;
    _channel.invokeMethod("OneSignal#initInAppMessageClickedHandlerParams");
  }

  void addInAppMessageLifecycleListener(
      OneSignalInAppMessageLifecycleListener listener) {
    _lifecycleListeners.add(listener);
  }

  void removeInAppMessageLifecycleListener(
      OneSignalInAppMessageLifecycleListener listener) {
    _lifecycleListeners.remove(listener);
  }
}
