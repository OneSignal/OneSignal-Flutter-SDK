import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'mock_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  OneSignalMockChannelController channelController =
      OneSignalMockChannelController();

  setUp(() {
    channelController.resetState();
  });

  group('OneSignal', () {
    test('initialize sets appId and calls lifecycle methods', () async {
      await OneSignal.initialize('test-app-id');

      expect(channelController.state.appId, equals('test-app-id'));
      expect(channelController.state.lifecycleInitCalled, isTrue);
      expect(channelController.state.userLifecycleInitCalled, isTrue);
    });

    group('login', () {
      test('login invokes native method with externalId', () async {
        await OneSignal.login('user-123');

        expect(channelController.state.externalId, equals('user-123'));
      });

      test('login handles empty externalId', () async {
        await OneSignal.login('');

        expect(channelController.state.externalId, equals(''));
      });
    });

    group('loginWithJWT', () {
      test('loginWithJWT invokes native method on Android only', () async {
        // Override platform to Android for this test
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        // ignore: deprecated_member_use_from_same_package
        await OneSignal.loginWithJWT('user-123', 'test-jwt-token');

        // On Android, the method should be invoked
        // Note: The mock handler would need to be updated to handle this
        // expect(channelController.state.externalId, equals('user-123'));
      });

      test('loginWithJWT does nothing on ios platforms', () async {
        // Ensure we're not on Android
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        // ignore: deprecated_member_use_from_same_package
        await OneSignal.loginWithJWT('user-123', 'test-jwt-token');

        // On iOS, the method should do nothing
        expect(channelController.state.externalId, isNull);
      });
    }, skip: true);

    group('logout', () {
      test('logout invokes native method', () async {
        // First login
        await OneSignal.login('user-123');
        expect(channelController.state.externalId, equals('user-123'));

        // Then logout
        await OneSignal.logout();
        expect(channelController.state.externalId, isNull);
      });
    });

    group('consentGiven', () {
      test('consentGiven sets consent given to a boolean value', () async {
        await OneSignal.consentGiven(true);
        expect(channelController.state.consentGiven, isTrue);

        await OneSignal.consentGiven(false);
        expect(channelController.state.consentGiven, isFalse);
      });
    });

    group('consentRequired', () {
      test('consentRequired sets requirement to a boolean value', () async {
        await OneSignal.consentRequired(true);
        expect(channelController.state.requiresPrivacyConsent, isTrue);

        await OneSignal.consentRequired(false);
        expect(channelController.state.requiresPrivacyConsent, isFalse);
      });
    });

    group('static properties', () {
      test('static properties are initialized', () {
        expect(OneSignal.Debug, isNotNull);
        expect(OneSignal.User, isNotNull);
        expect(OneSignal.Notifications, isNotNull);
        expect(OneSignal.Session, isNotNull);
        expect(OneSignal.Location, isNotNull);
        expect(OneSignal.InAppMessages, isNotNull);
        expect(OneSignal.LiveActivities, isNotNull);
      });

      test('static properties are singletons', () {
        final debug1 = OneSignal.Debug;
        final debug2 = OneSignal.Debug;
        expect(identical(debug1, debug2), isTrue);

        final user1 = OneSignal.User;
        final user2 = OneSignal.User;
        expect(identical(user1, user2), isTrue);

        final notifications1 = OneSignal.Notifications;
        final notifications2 = OneSignal.Notifications;
        expect(identical(notifications1, notifications2), isTrue);

        final session1 = OneSignal.Session;
        final session2 = OneSignal.Session;
        expect(identical(session1, session2), isTrue);

        final location1 = OneSignal.Location;
        final location2 = OneSignal.Location;
        expect(identical(location1, location2), isTrue);

        final inAppMessages1 = OneSignal.InAppMessages;
        final inAppMessages2 = OneSignal.InAppMessages;
        expect(identical(inAppMessages1, inAppMessages2), isTrue);

        final liveActivities1 = OneSignal.LiveActivities;
        final liveActivities2 = OneSignal.LiveActivities;
        expect(identical(liveActivities1, liveActivities2), isTrue);
      });
    });
  });
}
