import 'dart:async';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/subscription.dart';

typedef void OnPushSubscriptionChangeObserver(
    OSPushSubscriptionChangedState stateChanges);

class OneSignalPushSubscription {
  MethodChannel _channel = const MethodChannel('OneSignal#pushsubscription');

  String? _id;
  String? _token;
  bool? _optedIn;

  List<OnPushSubscriptionChangeObserver> _observers =
      <OnPushSubscriptionChangeObserver>[];
  // constructor method
  OneSignalPushSubscription() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  String? get id {
    return this._id;
  }

  /// The readonly push token.
  String? get token {
    return this._token;
  }

  /// Gets a boolean value indicating whether the current user is opted in to receive push notifications.
  /// If the device does not have push permission, optedIn is false.
  /// If the device has push permission, but no push token or subscription ID yet, optedIn is true.
  /// If the device has push permission and optOut() was not called, optedIn is true.
  /// If the device has push permission and optOut() was called, optedIn is false.
  bool? get optedIn {
    return _optedIn;
  }

  /// Call this method to receive push notifications on the device or to resume receiving of
  /// push notifications after calling optOut. If needed, this method will prompt the user for
  /// push notifications permission.
  Future<void> optIn() async {
    await _channel.invokeMethod("OneSignal#optIn");
  }

  /// If at any point you want the user to stop receiving push notifications on the current
  /// device (regardless of system-level permission status), you can call this method to opt out.
  Future<void> optOut() async {
    await _channel.invokeMethod("OneSignal#optOut");
  }

  /// The OSPushSubscriptionObserver.onOSPushSubscriptionChanged method will be fired on the passed-in
  // object when the push subscription changes. This method returns the current OSPushSubscriptionState
  // at the time of adding this observer.
  void addObserver(OnPushSubscriptionChangeObserver observer) {
    _observers.add(observer);
  }

  // Remove a push subscription observer that has been previously added.
  void removeObserver(OnPushSubscriptionChangeObserver observer) {
    _observers.remove(observer);
  }

  Future<void> lifecycleInit() async {
    _token = await _channel.invokeMethod("OneSignal#pushSubscriptionToken");
    _id = await _channel.invokeMethod("OneSignal#pushSubscriptionId");
    _optedIn = await _channel.invokeMethod("OneSignal#pushSubscriptionOptedIn");
    return await _channel.invokeMethod("OneSignal#lifecycleInit");
  }

  // Private function that gets called by ObjC/Java
  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'OneSignal#onPushSubscriptionChange') {
      this._onPushSubscriptionChange(OSPushSubscriptionChangedState(
          call.arguments.cast<String, dynamic>()));
    }
    return null;
  }

  void _onPushSubscriptionChange(
      OSPushSubscriptionChangedState stateChanges) async {
    this._id = stateChanges.current.id;
    this._token = stateChanges.current.token;
    this._optedIn = stateChanges.current.optedIn;

    for (var observer in _observers) {
      observer(stateChanges);
    }
  }
}
