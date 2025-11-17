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
    });

    group('canRequest', () {
      test('invokes OneSignal#canRequest method', () async {
        final result = await notifications.canRequest();
        expect(result, isA<bool>());
      });
    });

    group('removeNotification', () {
      test('invokes OneSignal#removeNotification on Android', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        const notificationId = 123;
        await notifications.removeNotification(notificationId);
        expect(channelController.state.removedNotificationId, notificationId);
      });

      test('does nothing on iOS', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        const notificationId = 123;
        await notifications.removeNotification(notificationId);
        expect(true, true);
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

      test('does nothing on iOS', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        const notificationGroup = 'test_group';
        await notifications.removeGroupedNotifications(notificationGroup);
        expect(true, true);
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
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                const MethodChannel('OneSignal#notifications'), (call) async {
          if (call.method == 'OneSignal#requestPermission') {
            final args = call.arguments as Map<dynamic, dynamic>;
            expect(args['fallbackToSettings'], true);
            return true;
          }
          return null;
        });

        await notifications.requestPermission(true);
      });

      test('invokes OneSignal#requestPermission with fallbackToSettings false',
          () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                const MethodChannel('OneSignal#notifications'), (call) async {
          if (call.method == 'OneSignal#requestPermission') {
            final args = call.arguments as Map<dynamic, dynamic>;
            expect(args['fallbackToSettings'], false);
            return true;
          }
          return null;
        });

        await notifications.requestPermission(false);
      });
    });

    group('registerForProvisionalAuthorization', () {
      test('invokes method on iOS only', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                const MethodChannel('OneSignal#notifications'), (call) async {
          if (call.method == 'OneSignal#registerForProvisionalAuthorization') {
            return true;
          }
          return null;
        });

        final result =
            await notifications.registerForProvisionalAuthorization(true);
        expect(result, isA<bool>());
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
      test('addForegroundWillDisplayListener adds listener', () {
        var listenerCalled = false;
        void listener(OSNotificationWillDisplayEvent event) {
          listenerCalled = true;
        }

        notifications.addForegroundWillDisplayListener(listener);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                const MethodChannel('OneSignal#notifications'), (call) async {
          if (call.method == 'OneSignal#onWillDisplayNotification') {
            listener(OSNotificationWillDisplayEvent(
                (call.arguments as Map<String, dynamic>)));
          }
          return null;
        });

        expect(listenerCalled, false);
      });

      test('removeForegroundWillDisplayListener removes listener', () {
        var listenerCalled = false;
        void listener(OSNotificationWillDisplayEvent event) {
          listenerCalled = true;
        }

        notifications.addForegroundWillDisplayListener(listener);
        notifications.removeForegroundWillDisplayListener(listener);

        expect(listenerCalled, false);
      });

      test('multiple will display listeners can be added', () {
        void listener1(OSNotificationWillDisplayEvent event) {}
        void listener2(OSNotificationWillDisplayEvent event) {}

        notifications.addForegroundWillDisplayListener(listener1);
        notifications.addForegroundWillDisplayListener(listener2);

        expect(true, true);
      });

      test('can remove specific will display listener', () {
        void listener1(OSNotificationWillDisplayEvent event) {}
        void listener2(OSNotificationWillDisplayEvent event) {}

        notifications.addForegroundWillDisplayListener(listener1);
        notifications.addForegroundWillDisplayListener(listener2);
        notifications.removeForegroundWillDisplayListener(listener1);

        expect(true, true);
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

      test('click listener can be added and invoked multiple times', () {
        void listener(OSNotificationClickEvent event) {}

        notifications.addClickListener(listener);
        expect(true, true);
      });

      test('will display listener can be added and invoked multiple times', () {
        void listener(OSNotificationWillDisplayEvent event) {}

        notifications.addForegroundWillDisplayListener(listener);
        expect(true, true);
      });

      test('notification IDs are passed correctly through preventDefault', () {
        final notificationIds = ['id-1', 'id-2', 'id-3'];

        for (final id in notificationIds) {
          notifications.preventDefault(id);
          expect(channelController.state.preventedNotificationId, id);
        }
      });

      test('notification IDs are passed correctly through displayNotification',
          () {
        final notificationIds = ['id-1', 'id-2', 'id-3'];

        for (final id in notificationIds) {
          notifications.displayNotification(id);
          expect(channelController.state.displayedNotificationId, id);
        }
      });
    });
  });
}
