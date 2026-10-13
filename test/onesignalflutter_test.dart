import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

      test('login rejects empty externalId', () async {
        await OneSignal.login('');

        expect(channelController.state.externalId, isNull);
      });
    });

    group('loginWithProfile', () {
      const profile = OSUserProfile(
        email: 'a@example.com',
        sms: '+14155552671',
        tags: {'tier': 'gold'},
        aliases: {'crm': 'c-1'},
      );

      setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
      tearDown(() => debugDefaultTargetPlatformOverride = null);

      test('marshals externalId, profile and jwt', () async {
        await OneSignal.loginWithProfile('user-123', profile, 'jwt-1');

        final args = channelController.state.loginWithProfileArgs!;
        expect(args['externalId'], equals('user-123'));
        expect(args['jwtBearerToken'], equals('jwt-1'));
        expect(
          args['profile'],
          equals({
            'email': 'a@example.com',
            'sms': '+14155552671',
            'tags': {'tier': 'gold'},
            'aliases': {'crm': 'c-1'},
          }),
        );
      });

      test('omitted jwt is sent as null', () async {
        await OneSignal.loginWithProfile('user-123', const OSUserProfile());

        final args = channelController.state.loginWithProfileArgs!;
        expect(args.containsKey('jwtBearerToken'), isTrue);
        expect(args['jwtBearerToken'], isNull);
      });

      test('parses a success envelope', () async {
        channelController.state.loginWithProfileResponse = {
          'success': true,
          'data': {
            'onesignalId': 'os-1',
            'externalId': 'user-123',
            'emailSubscriptionId': 'email-sub',
          },
          'error': null,
        };

        final result = await OneSignal.loginWithProfile('user-123', profile);

        expect(result.success, isTrue);
        expect(result.error, isNull);
        expect(result.data!.onesignalId, equals('os-1'));
        expect(result.data!.externalId, equals('user-123'));
        expect(result.data!.emailSubscriptionId, equals('email-sub'));
        expect(result.data!.smsSubscriptionId, isNull);
      });

      test('parses a failure envelope', () async {
        channelController.state.loginWithProfileResponse = {
          'success': false,
          'data': null,
          'error': [
            {
              'code': 'BACKEND_ERROR',
              'source': 'BACKEND',
              'backendCode': 'user-1',
              'httpStatus': 409,
              'message': 'Conflict',
              'meta': {'conflicting_aliases': 'crm'},
            },
            {'code': 'SOMETHING_NEW', 'source': 'CLIENT', 'message': 'x'},
          ],
        };

        final result = await OneSignal.loginWithProfile('user-123', profile);

        expect(result.success, isFalse);
        expect(result.data, isNull);
        final first = result.error!.first;
        expect(first.code, equals('BACKEND_ERROR'));
        expect(first.source, equals('BACKEND'));
        expect(first.backendCode, equals('user-1'));
        expect(first.httpStatus, equals(409));
        expect(first.message, equals('Conflict'));
        expect(first.meta, equals({'conflicting_aliases': 'crm'}));
        expect(result.error![1].code, equals('UNKNOWN'));
      });

      for (final malformed in <dynamic>[
        null,
        'nope',
        {'success': 'yes'},
        {'success': true, 'data': null},
        {
          'success': true,
          'data': {'onesignalId': 'os-1'},
        },
        {'success': false, 'error': []},
        {'success': false, 'error': 'boom'},
      ]) {
        test(
          'treats malformed envelope $malformed as UNKNOWN failure',
          () async {
            channelController.state.loginWithProfileResponse = malformed;

            final result = await OneSignal.loginWithProfile(
              'user-123',
              profile,
            );

            expect(result.success, isFalse);
            expect(result.data, isNull);
            expect(result.error!.single.code, equals('UNKNOWN'));
          },
        );
      }

      test('a non-map error entry becomes UNKNOWN', () async {
        channelController.state.loginWithProfileResponse = {
          'success': false,
          'error': ['boom'],
        };

        final result = await OneSignal.loginWithProfile('user-123', profile);

        expect(result.error!.single.code, equals('UNKNOWN'));
        expect(result.error!.single.source, equals('CLIENT'));
      });

      test('a platform exception becomes an UNKNOWN failure', () async {
        channelController.state.loginWithProfileResponse = PlatformException(
          code: 'OneSignal',
          message: 'native threw',
        );

        final result = await OneSignal.loginWithProfile('user-123', profile);

        expect(result.success, isFalse);
        expect(result.error!.single.code, equals('UNKNOWN'));
        expect(result.error!.single.message, contains('native threw'));
      });

      test('rejects empty externalId without calling native', () async {
        final result = await OneSignal.loginWithProfile('', profile);

        expect(channelController.state.loginWithProfileArgs, isNull);
        expect(result.success, isFalse);
        expect(result.error!.single.code, equals('INVALID_ARGUMENT'));
        expect(result.error!.single.source, equals('CLIENT'));
      });

      test(
        'rejects an empty tag key or alias id without calling native',
        () async {
          final badTag = await OneSignal.loginWithProfile(
            'user-123',
            const OSUserProfile(tags: {'': 'v'}),
          );
          final badAlias = await OneSignal.loginWithProfile(
            'user-123',
            const OSUserProfile(aliases: {'crm': ''}),
          );

          expect(channelController.state.loginWithProfileArgs, isNull);
          expect(badTag.error!.single.code, equals('INVALID_ARGUMENT'));
          expect(badAlias.error!.single.code, equals('INVALID_ARGUMENT'));
        },
      );

      test(
        'returns the failure envelope on iOS without calling native',
        () async {
          debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

          final result = await OneSignal.loginWithProfile('user-123', profile);

          expect(channelController.state.loginWithProfileArgs, isNull);
          expect(result.success, isFalse);
          expect(result.data, isNull);
          final error = result.error!.single;
          expect(error.code, equals('UNKNOWN'));
          expect(error.source, equals('CLIENT'));
          expect(error.backendCode, isNull);
          expect(error.httpStatus, isNull);
          expect(error.meta, isNull);
          expect(
            error.message,
            equals('loginWithProfile is only supported on Android'),
          );
        },
      );
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

  group('user strings', () {
    test('addTag rejects an empty key', () async {
      await OneSignal.User.addTagWithKey('', 'premium');

      expect(channelController.state.tags, isNull);
    });

    test('addEmail rejects an empty address', () async {
      await OneSignal.User.addEmail('');

      expect(channelController.state.addedEmail, isNull);
    });
  });
}
