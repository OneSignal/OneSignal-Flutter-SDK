import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/notification.dart';

typedef void OnNotificationPermissionChangeObserver(bool permission);

typedef void OnNotificationWillDisplayListener(
    OSNotificationWillDisplayEvent event);

typedef void OnNotificationClickListener(OSNotificationClickEvent event);

class OneSignalNotifications {
  // event listeners
  List<OnNotificationClickListener> _clickListeners =
      <OnNotificationClickListener>[];
  // Clicks that arrived before the app's first click listener was registered
  // (e.g. a cold-start / cached-engine attach drains the native queue before
  // addClickListener runs). Buffered here instead of dropped, then flushed once
  // a listener registers. Only filled during this initial window: after the
  // first registration clicks are delivered or dropped, never buffered again.
  List<OSNotificationClickEvent> _pendingClickEvents =
      <OSNotificationClickEvent>[];
  // Upper bound on buffered pre-registration clicks so the buffer can't grow
  // unbounded if a listener is never registered. Oldest events drop past this.
  static const int _maxPendingClickEvents = 50;
  // Guards against scheduling more than one buffer-drain microtask.
  bool _pendingClickDrainScheduled = false;
  List<OnNotificationWillDisplayListener> _willDisplayListeners =
      <OnNotificationWillDisplayListener>[];

  // private channels used to bridge to ObjC/Java
  MethodChannel _channel = const MethodChannel('OneSignal#notifications');

  List<OnNotificationPermissionChangeObserver> _observers =
      <OnNotificationPermissionChangeObserver>[];
  // constructor method
  OneSignalNotifications() {
    this._channel.setMethodCallHandler(_handleMethod);
  }

  bool _permission = false;

  bool _clickHandlerRegistered = false;

  /// Whether this app has push notification permission.
  bool get permission {
    return _permission;
  }

  /// iOS only
  /// enum OSNotificationPermission {
  /// notDetermined,
  /// denied,
  /// authorized,
  /// provisional, // only available in iOS 12
  /// ephemeral, // only available in iOS 14
  Future<OSNotificationPermission> permissionNative() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return OSNotificationPermission
          .values[await _channel.invokeMethod("OneSignal#permissionNative")];
    } else {
      return _permission
          ? OSNotificationPermission.authorized
          : OSNotificationPermission.denied;
    }
  }

  /// Whether attempting to request notification permission will show a prompt.
  /// Returns true if the device has not been prompted for push notification permission already.
  Future<bool> canRequest() async {
    return await _channel.invokeMethod("OneSignal#canRequest");
  }

  /// Removes a single notification.
  Future<void> removeNotification(int notificationId) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _channel.invokeMethod(
          "OneSignal#removeNotification", {'notificationId': notificationId});
    }
  }

  /// Removes a grouped notification.
  Future<void> removeGroupedNotifications(String notificationGroup) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _channel.invokeMethod("OneSignal#removeGroupedNotifications",
          {'notificationGroup': notificationGroup});
    }
  }

  /// Removes all OneSignal notifications.
  Future<void> clearAll() async {
    return await _channel.invokeMethod("OneSignal#clearAll");
  }

  /// Prompt the user for permission to receive push notifications. This will display the native
  /// system prompt to request push notification permission.
  Future<bool> requestPermission(bool fallbackToSettings) async {
    return await _channel.invokeMethod("OneSignal#requestPermission",
        {'fallbackToSettings': fallbackToSettings});
  }

  /// Instead of having to prompt the user for permission to send them push notifications,
  /// your app can request provisional authorization.
  Future<bool> registerForProvisionalAuthorization(
      bool fallbackToSettings) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _channel
          .invokeMethod("OneSignal#registerForProvisionalAuthorization");
    } else {
      return false;
    }
  }

  /// The OSNotificationPermissionObserver.onNotificationPermissionDidChange method will be fired on the passed-in object
  /// when a notification permission setting changes. This happens when the user enables or disables
  /// notifications for your app from the system settings outside of your app.
  void addPermissionObserver(OnNotificationPermissionChangeObserver observer) {
    _observers.add(observer);
  }

  // Remove a push subscription observer that has been previously added.
  void removePermissionObserver(
      OnNotificationPermissionChangeObserver observer) {
    _observers.remove(observer);
  }

  Future<void> lifecycleInit() async {
    _permission = await _channel.invokeMethod("OneSignal#permission");
    addPermissionObserver((permission) {
      _permission = permission;
    });
    return await _channel.invokeMethod("OneSignal#lifecycleInit");
  }

  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'OneSignal#onClickNotification') {
      var event =
          OSNotificationClickEvent(call.arguments.cast<String, dynamic>());
      if (_clickListeners.isNotEmpty) {
        for (var listener in _clickListeners) {
          listener(event);
        }
      } else if (!_clickHandlerRegistered) {
        // Buffer only before the app's first listener registration. Once a
        // listener has been registered (and possibly removed) drop instead, so
        // removing a listener doesn't silently accumulate clicks forever.
        if (_pendingClickEvents.length >= _maxPendingClickEvents) {
          _pendingClickEvents.removeAt(0);
        }
        _pendingClickEvents.add(event);
      }
    } else if (call.method == 'OneSignal#onWillDisplayNotification') {
      for (var listener in _willDisplayListeners) {
        listener(OSNotificationWillDisplayEvent(
            call.arguments.cast<String, dynamic>()));
      }
      var event = OSNotificationWillDisplayEvent(
          call.arguments.cast<String, dynamic>());
      _channel.invokeMethod("OneSignal#proceedWithWillDisplay",
          {'notificationId': event.notification.notificationId});
    } else if (call.method == 'OneSignal#onNotificationPermissionDidChange') {
      this.onNotificationPermissionDidChange(call.arguments["permission"]);
    }
    return null;
  }

  void onNotificationPermissionDidChange(bool permission) {
    for (var observer in _observers) {
      observer(permission);
    }
  }

  void addForegroundWillDisplayListener(
      OnNotificationWillDisplayListener listener) {
    _willDisplayListeners.add(listener);
  }

  void removeForegroundWillDisplayListener(
      OnNotificationWillDisplayListener listener) {
    _willDisplayListeners.remove(listener);
  }

  /// The notification willDisplay listener is called whenever a notification arrives
  /// and the application is in foreground
  void preventDefault(String notificationId) {
    _channel.invokeMethod(
        "OneSignal#preventDefault", {'notificationId': notificationId});
  }

  void displayNotification(String notificationId) {
    _channel.invokeMethod(
        "OneSignal#displayNotification", {'notificationId': notificationId});
  }

  /// The notification click listener is called whenever the user opens a
  /// OneSignal push notification, or taps an action button on a notification.
  void addClickListener(OnNotificationClickListener listener) {
    if (!_clickHandlerRegistered) {
      _clickHandlerRegistered = true;
      _channel.invokeMethod("OneSignal#addNativeClickListener");
    }
    _clickListeners.add(listener);
    // Deliver any clicks that arrived before a listener existed. The drain is
    // deferred to a microtask so that listeners registered synchronously at
    // startup (e.g. analytics then navigation) are all enrolled before it runs,
    // then the buffered clicks fan out to every listener, matching the live
    // delivery in _handleMethod. The buffer is drained once and never refilled.
    if (_pendingClickEvents.isNotEmpty && !_pendingClickDrainScheduled) {
      _pendingClickDrainScheduled = true;
      scheduleMicrotask(() {
        _pendingClickDrainScheduled = false;
        if (_pendingClickEvents.isEmpty) {
          return;
        }
        var pending = _pendingClickEvents;
        _pendingClickEvents = <OSNotificationClickEvent>[];
        for (var event in pending) {
          // Snapshot so a listener that adds/removes a listener during its
          // callback (e.g. a self-removing one-shot deep-link handler) doesn't
          // trigger a ConcurrentModificationError mid-drain.
          for (var clickListener in List.of(_clickListeners)) {
            try {
              clickListener(event);
            } catch (error, stackTrace) {
              Zone.current.handleUncaughtError(error, stackTrace);
            }
          }
        }
      });
    }
  }

  void removeClickListener(OnNotificationClickListener listener) {
    _clickListeners.remove(listener);
  }
}
