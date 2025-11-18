import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/user.dart';

import 'mock_channel.dart';

final userState = {
  'onesignalId': 'test-onesignal-id',
  'externalId': 'test-external-id',
};

final email = 'test@example.com';
final sms = '+1234567890';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OneSignalMockChannelController controller;
  late OneSignalUser user;

  setUp(() {
    controller = OneSignalMockChannelController();
    controller.resetState();
    user = OneSignalUser();
  });

  group('OSUserState', () {
    group('constructor', () {
      test('initializes with all fields when provided', () {
        final state = OSUserState(userState);

        expect(state.onesignalId, 'test-onesignal-id');
        expect(state.externalId, 'test-external-id');
      });

      test('handles null/missing onesignalId', () {
        // with null onesignalId
        final stateWithNull = OSUserState({
          ...userState,
          'onesignalId': null,
        });
        expect(stateWithNull.onesignalId, isNull);
        expect(stateWithNull.externalId, 'test-external-id');

        // with missing onesignalId key
        final stateWithMissing = OSUserState({
          'externalId': 'test-external-id',
        });
        expect(stateWithMissing.onesignalId, isNull);
        expect(stateWithMissing.externalId, 'test-external-id');
      });

      test('handles null/missing externalId', () {
        // with null externalId
        final stateWithNull = OSUserState({
          ...userState,
          'externalId': null,
        });
        expect(stateWithNull.onesignalId, 'test-onesignal-id');
        expect(stateWithNull.externalId, isNull);

        // with missing externalId key
        final stateWithMissing = OSUserState({
          'onesignalId': 'test-onesignal-id',
        });
        expect(stateWithMissing.onesignalId, 'test-onesignal-id');
        expect(stateWithMissing.externalId, isNull);
      });

      test('handles all null values', () {
        final state = OSUserState({
          'onesignalId': null,
          'externalId': null,
        });

        expect(state.onesignalId, isNull);
        expect(state.externalId, isNull);
      });
    });

    group('jsonRepresentation', () {
      test('returns json string with all fields', () {
        final state = OSUserState(userState);
        final jsonString = state.jsonRepresentation();

        expect(jsonString, contains('"onesignalId": "test-onesignal-id"'));
        expect(jsonString, contains('"externalId": "test-external-id"'));
      });

      test('returns json string with null fields', () {
        final state = OSUserState({
          'onesignalId': null,
          'externalId': null,
        });
        final jsonString = state.jsonRepresentation();

        expect(jsonString, contains('"onesignalId": null'));
        expect(jsonString, contains('"externalId": null'));
      });
    });

    group('field modification', () {
      test('fields can be modified after construction', () {
        final state = OSUserState(userState);

        // Verify initial values
        expect(state.onesignalId, 'test-onesignal-id');
        expect(state.externalId, 'test-external-id');

        // Modify onesignalId
        state.onesignalId = 'new-onesignal-id';
        expect(state.onesignalId, 'new-onesignal-id');

        // Modify externalId
        state.externalId = 'new-external-id';
        expect(state.externalId, 'new-external-id');
      });

      test('modifications reflect in jsonRepresentation', () {
        final state = OSUserState(userState);
        state.onesignalId = 'modified-onesignal-id';
        state.externalId = 'modified-external-id';

        final jsonString = state.jsonRepresentation();

        expect(jsonString, contains('"onesignalId": "modified-onesignal-id"'));
        expect(jsonString, contains('"externalId": "modified-external-id"'));
      });
    });
  });

  group('OSUserChangedState', () {
    test('initializes with current state', () {
      final changedState = OSUserChangedState({
        'current': userState,
      });

      expect(changedState.current.onesignalId, 'test-onesignal-id');
      expect(changedState.current.externalId, 'test-external-id');
    });

    test('handles null values in current state', () {
      final changedState = OSUserChangedState({
        'current': {
          'onesignalId': null,
          'externalId': null,
        },
      });

      expect(changedState.current.onesignalId, isNull);
      expect(changedState.current.externalId, isNull);
    });

    test('jsonRepresentation returns correct format', () {
      final changedState = OSUserChangedState({
        'current': userState,
      });
      final jsonString = changedState.jsonRepresentation();

      expect(jsonString, contains('"current":'));
      expect(jsonString, contains('"onesignalId": "test-onesignal-id"'));
      expect(jsonString, contains('"externalId": "test-external-id"'));
    });
  });

  group('OneSignalUser', () {
    test('setLanguage invokes native method with language', () async {
      await user.setLanguage('es');

      expect(controller.state.language, 'es');
    });

    test('addAlias invokes native method with alias', () async {
      await user.addAlias('customId', '12345');

      expect(controller.state.aliases, {'customId': '12345'});
    });

    test('addAliases invokes native method with multiple aliases', () async {
      await user.addAliases({
        'customId': '12345',
        'userId': 'abc',
      });

      expect(controller.state.aliases, {
        'customId': '12345',
        'userId': 'abc',
      });
    });

    test('removeAlias invokes native method with alias label', () async {
      await user.removeAlias('customId');

      expect(controller.state.removedAliases, ['customId']);
    });

    test('removeAliases invokes native method with multiple labels', () async {
      await user.removeAliases(['customId', 'userId']);

      expect(controller.state.removedAliases, ['customId', 'userId']);
    });

    test('addTagWithKey invokes native method with tag', () async {
      await user.addTagWithKey('level', 10);

      expect(controller.state.tags, {'level': '10'});
    });

    test('addTags invokes native method with multiple tags', () async {
      await user.addTags({
        'level': 10,
        'score': 500,
        'name': 'Player1',
      });

      expect(controller.state.tags, {
        'level': '10',
        'score': '500',
        'name': 'Player1',
      });
    });

    test('removeTag invokes native method with tag key', () async {
      await user.removeTag('level');

      expect(controller.state.deleteTags, ['level']);
    });

    test('removeTags invokes native method with multiple keys', () async {
      await user.removeTags(['level', 'score']);

      expect(controller.state.deleteTags, ['level', 'score']);
    });

    test('getTags returns tags from native', () async {
      controller.state.tags = {
        'level': '10',
        'score': '500',
      };

      final tags = await user.getTags();

      expect(tags, {
        'level': '10',
        'score': '500',
      });
    });

    test('addEmail invokes native method with email', () async {
      await user.addEmail(email);

      expect(controller.state.addedEmail, email);
    });

    test('removeEmail invokes native method with email', () async {
      await user.removeEmail(email);

      expect(controller.state.removedEmail, email);
    });

    test('addSms invokes native method with sms number', () async {
      await user.addSms(sms);

      expect(controller.state.addedSms, sms);
    });

    test('removeSms invokes native method with sms number', () async {
      await user.removeSms(sms);

      expect(controller.state.removedSms, sms);
    });

    test('getExternalId returns external id from native', () async {
      controller.state.externalId = 'external-123';

      final externalId = await user.getExternalId();

      expect(externalId, 'external-123');
    });

    test('getOnesignalId returns onesignal id from native', () async {
      controller.state.onesignalId = 'onesignal-456';

      final onesignalId = await user.getOnesignalId();

      expect(onesignalId, 'onesignal-456');
    });

    test('lifecycleInit invokes native method', () async {
      await user.lifecycleInit();

      expect(controller.state.lifecycleInitCalled, true);
    });

    group('observers', () {
      test('can add observer', () {
        bool observerCalled = false;
        OSUserChangedState? receivedState;

        user.addObserver((stateChanges) {
          observerCalled = true;
          receivedState = stateChanges;
        });

        controller.simulateUserStateChange({
          'current': {'onesignalId': 'new-id', 'externalId': 'new-external'},
        });

        expect(observerCalled, true);
        expect(receivedState!.current.onesignalId, 'new-id');
        expect(receivedState!.current.externalId, 'new-external');
      });

      test('can add multiple observers', () {
        int callCount = 0;
        user.addObserver((stateChanges) => callCount++);
        user.addObserver((stateChanges) => callCount++);

        controller.simulateUserStateChange({
          'current': {'onesignalId': 'id', 'externalId': 'ext'},
        });

        expect(callCount, 2);
      });

      test('can remove observer', () {
        bool observerCalled = false;
        void observer(OSUserChangedState stateChanges) {
          observerCalled = true;
        }

        user.addObserver(observer);
        user.removeObserver(observer);

        controller.simulateUserStateChange({
          'current': {'onesignalId': 'id', 'externalId': 'ext'},
        });

        expect(observerCalled, false);
      });
    });

    group('onUserStateChange', () {
      test('updates state when user state changes', () async {
        OSUserChangedState? receivedState;
        user.addObserver((stateChanges) {
          receivedState = stateChanges;
        });

        await user.lifecycleInit();

        controller.simulateUserStateChange({
          'current': {
            'onesignalId': 'changed-id',
            'externalId': 'changed-external',
          },
        });

        expect(receivedState!.current.onesignalId, 'changed-id');
        expect(receivedState!.current.externalId, 'changed-external');
      });

      test('notifies all observers', () async {
        int callCount = 0;
        user.addObserver((stateChanges) => callCount++);
        user.addObserver((stateChanges) => callCount++);
        user.addObserver((stateChanges) => callCount++);

        await user.lifecycleInit();

        controller.simulateUserStateChange({
          'current': userState,
        });

        expect(callCount, 3);
      });
    });
  });
}
