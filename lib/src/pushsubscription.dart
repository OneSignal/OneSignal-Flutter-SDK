import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/subscription.dart';

class OneSignalPushSubscription {

  MethodChannel _channel = const MethodChannel('OneSignal#pushsubscription');

  List<OneSignalPushSubscriptionObserver> _observers = <OneSignalPushSubscriptionObserver>[];
  // constructor method
  OneSignalPushSubscription() {
    this._channel.setMethodCallHandler(_handleMethod);
    this._initPushSubscriptionState();
  }

  void _initPushSubscriptionState() {
    _channel.invokeMethod("OneSignal#addObserver"); 
  }

  // TODO: convert these syncronous by capturing an initial state and the following the stateChanges

  /// The readonly push subscription ID.
  Future<String> id() async {
    return await _channel.invokeMethod("OneSignal#pushSubscriptionToken");
  }

  /// The readonly push token.
  Future<String> token() async {
    return await _channel.invokeMethod("OneSignal#pushSubscriptionToken");
  }

  /// Gets a boolean value indicating whether the current user is opted in to push notifications. 
  /// This returns true when the app has notifications permission and optedOut is called. 
  /// Note: Does not take into account the existence of the subscription ID and push token. 
  /// This boolean may return true but push notifications may still not be received by the user.
  Future<bool> optedIn() async {
    return await _channel.invokeMethod("OneSignal#pushSubscriptionOptedIn");
  }
  // TODO: END

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
  
  // Private function that gets called by ObjC/Java
  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'OneSignal#pushSubscriptionChanged') {
      this._onSubscriptionChangedHandler(OSPushSubscriptionStateChanges(call.arguments.cast<String, dynamic>()));
    } 
    return null;
  }

  Future<void> _onSubscriptionChangedHandler(OSPushSubscriptionStateChanges stateChanges) async {
    print("update in flutter");
    for (var observer in _observers) {
       print("observer fired");
      observer.onOSPushSubscriptionChangedWithStateChanges(stateChanges);
    }
  }
}

class OneSignalPushSubscriptionObserver {
  void onOSPushSubscriptionChangedWithStateChanges(OSPushSubscriptionStateChanges stateChanges) {
    print("update");
  }
}