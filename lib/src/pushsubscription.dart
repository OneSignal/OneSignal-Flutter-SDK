import 'dart:async';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/subscription.dart';

class OneSignalPushSubscription {
  MethodChannel _channel = const MethodChannel('OneSignal#pushsubscription');

  String? _id;
  String? _token;
  bool? _optedIn;

  List<OneSignalPushSubscriptionObserver> _observers =
      <OneSignalPushSubscriptionObserver>[];
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

  /// Gets a boolean value indicating whether the current user is opted in to push notifications.
  /// This returns true when the app has notifications permission and optedOut is called.
  /// Note: Does not take into account the existence of the subscription ID and push token.
  /// This boolean may return true but push notifications may still not be received by the user.
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
  void addObserver(OneSignalPushSubscriptionObserver observer) {
    _observers.add(observer);
  }

  // Remove a push subscription observer that has been previously added.
  void removeObserver(OneSignalPushSubscriptionObserver observer) {
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
    if (call.method == 'OneSignal#pushSubscriptionChanged') {
      this._onSubscriptionChangedHandler(
          OSPushSubscriptionState(call.arguments.cast<String, dynamic>()));
    }
    return null;
  }

  void _onSubscriptionChangedHandler(
      OSPushSubscriptionState stateChanges) async {
    print(stateChanges.jsonRepresentation());
    this._id = stateChanges.id;
    this._token = stateChanges.token;
    this._optedIn = stateChanges.optedIn;

    for (var observer in _observers) {
      observer.onOSPushSubscriptionChangedWithState(stateChanges);
    }
  }
}

class OneSignalPushSubscriptionObserver {
  void onOSPushSubscriptionChangedWithState(
      OSPushSubscriptionState stateChanges) {}
}
