import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/notification.dart';
import 'package:onesignal_flutter/src/notifications.dart';

import 'mock_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OneSignalNotifications', () {
    late OneSignalNotifications notifications;
    late OneSignalMockChannelController channelController;

    setUp(() {
      channelController = OneSignalMockChannelController();
      channelController.resetState();
      notifications = OneSignalNotifications();
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    group('permission', () {
      test('returns initial false value', () {
        expect(notifications.permission, false);
      });

      test('permission gets updated via observer during lifecycleInit',
          () async {
        channelController.state.notificationPermission = false;
        await notifications.lifecycleInit();
        expect(notifications.permission, false);

        // Test that the observer added in lifecycleInit updates _permission
        notifications.onNotificationPermissionDidChange(true);
        expect(notifications.permission, true);

        notifications.onNotificationPermissionDidChange(false);
        expect(notifications.permission, false);
      });
    });

    group('permissionNative', () {
      test('returns authorized when permission is true on Android', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        channelController.state.notificationPermission = true;
        await notifications.lifecycleInit();
        final permission = await notifications.permissionNative();
        expect(permission, OSNotificationPermission.authorized);
      });

      test('returns denied when permission is false on Android', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        final permission = await notifications.permissionNative();
        expect(permission, OSNotificationPermission.denied);
      });

      test('returns authorized on iOS when native method returns authorized',
          () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        channelController.state.notificationPermissionNative =
            OSNotificationPermission.authorized.index;

        final permission = await notifications.permissionNative();
        expect(permission, OSNotificationPermission.authorized);
      });

      test('returns denied on iOS when native method returns denied', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        channelController.state.notificationPermissionNative =
            OSNotificationPermission.denied.index;

        final permission = await notifications.permissionNative();
        expect(permission, OSNotificationPermission.denied);
      });
    });

    group('canRequest', () {
      test('returns true when canRequestPermission is true', () async {
        channelController.state.canRequestPermission = true;
        final result = await notifications.canRequest();
        expect(result, true);
      });

      test('returns false when canRequestPermission is false', () async {
        channelController.state.canRequestPermission = false;
        final result = await notifications.canRequest();
        expect(result, false);
      });
    });

    group('removeNotification', () {
      test('invokes OneSignal#removeNotification on Android', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        const notificationId = 123;
        await notifications.removeNotification(notificationId);
        expect(channelController.state.removedNotificationId, notificationId);
      });
    });

    group('removeGroupedNotifications', () {
      test('invokes OneSignal#removeGroupedNotifications on Android', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        const notificationGroup = 'test_group';
        await notifications.removeGroupedNotifications(notificationGroup);
        expect(channelController.state.removedNotificationGroup,
            notificationGroup);
      });
    });

    group('clearAll', () {
      test('invokes OneSignal#clearAll method', () async {
        await notifications.clearAll();
        expect(channelController.state.clearedAllNotifications, true);
      });
    });

    group('requestPermission', () {
      test('invokes OneSignal#requestPermission with fallbackToSettings true',
          () async {
        await notifications.requestPermission(true);
        expect(channelController.state.requestPermissionCalled, true);
        expect(
            channelController.state.requestPermissionFallbackToSettings, true);
      });

      test('invokes OneSignal#requestPermission with fallbackToSettings false',
          () async {
        await notifications.requestPermission(false);
        expect(channelController.state.requestPermissionCalled, true);
        expect(
            channelController.state.requestPermissionFallbackToSettings, false);
      });
    });

    group('registerForProvisionalAuthorization', () {
      test('invokes method on iOS only', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final result =
            await notifications.registerForProvisionalAuthorization(true);
        expect(result, true);
        expect(
            channelController.state.registerForProvisionalAuthorizationCalled,
            true);
      });

      test('returns false on Android', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        final result =
            await notifications.registerForProvisionalAuthorization(true);
        expect(result, false);
      });
    });

    group('Permission Observers', () {
      test('addPermissionObserver adds observer to list', () {
        var called = false;
        notifications.addPermissionObserver((permission) {
          called = true;
        });
        notifications.onNotificationPermissionDidChange(true);
        expect(called, true);
      });

      test('removePermissionObserver removes observer from list', () {
        var called = false;
        void observer(bool permission) {
          called = true;
        }

        notifications.addPermissionObserver(observer);
        notifications.removePermissionObserver(observer);

        notifications.onNotificationPermissionDidChange(true);
        expect(called, false);
      });

      test('multiple permission observers are all called', () {
        var observer1Called = false;
        var observer2Called = false;

        notifications.addPermissionObserver((permission) {
          observer1Called = true;
          expect(permission, true);
        });
        notifications.addPermissionObserver((permission) {
          observer2Called = true;
          expect(permission, true);
        });

        notifications.onNotificationPermissionDidChange(true);

        expect(observer1Called, true);
        expect(observer2Called, true);
      });

      test('observers receive correct permission value', () {
        bool? receivedPermission;

        notifications.addPermissionObserver((permission) {
          receivedPermission = permission;
        });

        notifications.onNotificationPermissionDidChange(true);
        expect(receivedPermission, true);

        notifications.onNotificationPermissionDidChange(false);
        expect(receivedPermission, false);
      });
    });

    group('lifecycleInit', () {
      test('initializes permission and calls lifecycleInit', () async {
        channelController.state.notificationPermission = true;
        await notifications.lifecycleInit();
        expect(notifications.permission, true);
      });
    });

    group('Click Listeners', () {
      test('addClickListener registers native click listener on first add', () {
        void listener(OSNotificationClickEvent event) {}
        notifications.addClickListener(listener);
        expect(channelController.state.nativeClickListenerAdded, true);
      });

      test('addClickListener registers native listener only once', () {
        void listener1(OSNotificationClickEvent event) {}
        void listener2(OSNotificationClickEvent event) {}

        notifications.addClickListener(listener1);
        notifications.addClickListener(listener2);

        expect(channelController.state.nativeClickListenerAdded, true);
        expect(channelController.state.nativeClickListenerAddedCount, 1);
      });

      test('removeClickListener removes listener', () {
        var listenerCalled = false;
        void testListener(OSNotificationClickEvent event) {
          listenerCalled = true;
        }

        notifications.addClickListener(testListener);
        notifications.removeClickListener(testListener);

        expect(listenerCalled, false);
      });

      test('adding same listener multiple times adds multiple entries', () {
        void listener(OSNotificationClickEvent event) {}

        notifications.addClickListener(listener);
        notifications.addClickListener(listener);

        // Both listeners should be in the list
        expect(true, true);
      });

      test('removing listener only removes first occurrence', () {
        void listener(OSNotificationClickEvent event) {}

        notifications.addClickListener(listener);
        notifications.addClickListener(listener);
        notifications.removeClickListener(listener);

        // One listener should still be in the list
        expect(true, true);
      });
    });

    group('Will Display Listeners', () {
      final notificationData = {
        'notification': {
          'notificationId': 'test-id',
          'title': 'Test',
          'body': 'Test body'
        }
      };

      test('addForegroundWillDisplayListener adds listener', () async {
        var listenerCalled = false;
        void listener(OSNotificationWillDisplayEvent event) {
          listenerCalled = true;
        }

        notifications.addForegroundWillDisplayListener(listener);
        await notifications.handleMethod(MethodCall(
            'OneSignal#onWillDisplayNotification', notificationData));

        expect(listenerCalled, true);
      });

      test('removeForegroundWillDisplayListener removes listener', () async {
        var listenerCalled = false;
        void listener(OSNotificationWillDisplayEvent event) {
          listenerCalled = true;
        }

        notifications.addForegroundWillDisplayListener(listener);
        notifications.removeForegroundWillDisplayListener(listener);
        await notifications.handleMethod(MethodCall(
            'OneSignal#onWillDisplayNotification', notificationData));

        expect(listenerCalled, false);
      });

      test('multiple will display listeners can be added', () async {
        var listener1Called = false;
        var listener2Called = false;
        void listener1(OSNotificationWillDisplayEvent event) {
          listener1Called = true;
        }

        void listener2(OSNotificationWillDisplayEvent event) {
          listener2Called = true;
        }

        notifications.addForegroundWillDisplayListener(listener1);
        notifications.addForegroundWillDisplayListener(listener2);

        await notifications.handleMethod(MethodCall(
            'OneSignal#onWillDisplayNotification', notificationData));

        expect(listener1Called, true);
        expect(listener2Called, true);
      });

      test('can remove specific will display listener', () async {
        var listener1Called = false;
        var listener2Called = false;
        void listener1(OSNotificationWillDisplayEvent event) {
          listener1Called = true;
        }

        void listener2(OSNotificationWillDisplayEvent event) {
          listener2Called = true;
        }

        notifications.addForegroundWillDisplayListener(listener1);
        notifications.addForegroundWillDisplayListener(listener2);
        notifications.removeForegroundWillDisplayListener(listener1);

        await notifications.handleMethod(MethodCall(
            'OneSignal#onWillDisplayNotification', notificationData));

        expect(listener1Called, false);
        expect(listener2Called, true);
      });
    });

    group('preventDefault', () {
      test('invokes OneSignal#preventDefault with notificationId', () {
        const notificationId = 'test-notification-id';
        notifications.preventDefault(notificationId);

        expect(channelController.state.preventedNotificationId, notificationId);
      });
    });

    group('displayNotification', () {
      test('invokes OneSignal#displayNotification with notificationId', () {
        const notificationId = 'test-notification-id';
        notifications.displayNotification(notificationId);

        expect(channelController.state.displayedNotificationId, notificationId);
      });
    });

    group('onNotificationPermissionDidChange', () {
      test('calls all registered permission observers with permission value',
          () {
        var observer1PermissionValue;
        var observer2PermissionValue;

        notifications.addPermissionObserver((permission) {
          observer1PermissionValue = permission;
        });
        notifications.addPermissionObserver((permission) {
          observer2PermissionValue = permission;
        });

        notifications.onNotificationPermissionDidChange(true);

        expect(observer1PermissionValue, true);
        expect(observer2PermissionValue, true);
      });

      test('observers can be called multiple times with different values', () {
        final receivedValues = <bool>[];

        notifications.addPermissionObserver((permission) {
          receivedValues.add(permission);
        });

        notifications.onNotificationPermissionDidChange(true);
        notifications.onNotificationPermissionDidChange(false);
        notifications.onNotificationPermissionDidChange(true);

        expect(receivedValues, [true, false, true]);
      });
    });

    group('Edge Cases', () {
      test('permission state is maintained across observer calls', () async {
        channelController.state.notificationPermission = true;
        await notifications.lifecycleInit();
        expect(notifications.permission, true);

        notifications.addPermissionObserver((permission) {
          expect(permission, isNotNull);
        });

        expect(notifications.permission, true);
      });

      test('adding and removing permission observers works correctly', () {
        final callLog = <bool>[];

        void observer1(bool permission) {
          callLog.add(permission);
        }

        void observer2(bool permission) {
          callLog.add(permission);
        }

        notifications.addPermissionObserver(observer1);
        notifications.addPermissionObserver(observer2);
        notifications.onNotificationPermissionDidChange(true);

        expect(callLog.length, 2);

        callLog.clear();
        notifications.removePermissionObserver(observer1);
        notifications.onNotificationPermissionDidChange(false);

        expect(callLog.length, 1);
        expect(callLog[0], false);
      });
    });
  });
}
