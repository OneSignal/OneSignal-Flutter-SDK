import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/inappmessage.dart';

typedef void InAppMessageClickedHandler(OSInAppMessageAction action);
typedef void OnWillDisplayInAppMessageHandler(OSInAppMessage message);
typedef void OnDidDisplayInAppMessageHandler(OSInAppMessage message);
typedef void OnWillDismissInAppMessageHandler(OSInAppMessage message);
typedef void OnDidDismissInAppMessageHandler(OSInAppMessage message);

class OneSignalInAppMessages {
  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#inappmessages');

  // constructor method
  OneSignalInAppMessages() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  InAppMessageClickedHandler? _onInAppMessageClickedHandler;
  OnWillDisplayInAppMessageHandler? _onWillDisplayInAppMessageHandler;
  OnDidDisplayInAppMessageHandler? _onDidDisplayInAppMessageHandler;
  OnWillDismissInAppMessageHandler? _onWillDismissInAppMessageHandler;
  OnDidDismissInAppMessageHandler? _onDidDismissInAppMessageHandler;

  /// Adds a single key, value trigger, which will trigger an in app message
  /// if one exists matching the specific trigger added
  Future<void> addTrigger(String key, Object value) async {
    return await _channel.invokeMethod("OneSignal#addTrigger", {key: value});
  }

  /// Adds one or more key, value triggers, which will trigger in app messages
  /// (one at a time) if any exist matching the specific triggers added
  Future<void> addTriggers(Map<String, Object> triggers) async {
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
  Future<Object?> clearTriggers() async {
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

  Future<bool> lifecycleInit() async {
    return await _channel.invokeMethod("OneSignal#lifecycleInit");
  }

  // Private function that gets called by ObjC/Java
  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'OneSignal#handleClickedInAppMessage' &&
        this._onInAppMessageClickedHandler != null) {
      this._onInAppMessageClickedHandler!(
          OSInAppMessageAction(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#onWillDisplayInAppMessage' &&
        this._onWillDisplayInAppMessageHandler != null) {
      this._onWillDisplayInAppMessageHandler!(
          OSInAppMessage(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#onDidDisplayInAppMessage' &&
        this._onDidDisplayInAppMessageHandler != null) {
      this._onDidDisplayInAppMessageHandler!(
          OSInAppMessage(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#onWillDismissInAppMessage' &&
        this._onWillDismissInAppMessageHandler != null) {
      this._onWillDismissInAppMessageHandler!(
          OSInAppMessage(call.arguments.cast<String, dynamic>()));
    } else if (call.method == 'OneSignal#onDidDismissInAppMessage' &&
        this._onDidDismissInAppMessageHandler != null) {
      this._onDidDismissInAppMessageHandler!(
          OSInAppMessage(call.arguments.cast<String, dynamic>()));
    }
    return null;
  }

  /// The in app message clicked handler is called whenever the user clicks a
  /// OneSignal IAM button or image with an action event attacthed to it
  void setInAppMessageClickedHandler(InAppMessageClickedHandler handler) {
    _onInAppMessageClickedHandler = handler;
    _channel.invokeMethod("OneSignal#initInAppMessageClickedHandlerParams");
  }

  /// The in app message will display handler is called whenever the in app message
  /// is about to be displayed
  void setOnWillDisplayInAppMessageHandler(
      OnWillDisplayInAppMessageHandler handler) {
    _onWillDisplayInAppMessageHandler = handler;
  }

  /// The in app message did display handler is called whenever the in app message
  /// is displayed
  void setOnDidDisplayInAppMessageHandler(
      OnDidDisplayInAppMessageHandler handler) {
    _onDidDisplayInAppMessageHandler = handler;
  }

  /// The in app message will dismiss handler is called whenever the in app message
  /// is about to be dismissed
  void setOnWillDismissInAppMessageHandler(
      OnWillDismissInAppMessageHandler handler) {
    _onWillDismissInAppMessageHandler = handler;
  }

  /// The in app message did dismiss handler is called whenever the in app message
  /// is dismissed
  void setOnDidDismissInAppMessageHandler(
      OnDidDismissInAppMessageHandler handler) {
    _onDidDismissInAppMessageHandler = handler;
  }
}
