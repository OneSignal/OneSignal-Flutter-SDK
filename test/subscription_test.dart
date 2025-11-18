import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/subscription.dart';

final pushSubState = {
  'id': 'test-id-123',
  'token': 'test-token-456',
  'optedIn': true,
};

final pushChangeState = {
  'current': {
    'id': 'current-id',
    'token': 'current-token',
    'optedIn': true,
  },
  'previous': {
    'id': 'previous-id',
    'token': 'previous-token',
    'optedIn': false,
  },
};

final pushNullChangeState = {
  'current': {'id': null, 'token': null, 'optedIn': false},
  'previous': {
    'id': 'previous-id',
    'token': 'previous-token',
    'optedIn': true,
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OSPushSubscriptionState', () {
    group('constructor', () {
      test('initializes with all fields when provided', () {
        final state = OSPushSubscriptionState(pushSubState);

        expect(state.id, 'test-id-123');
        expect(state.token, 'test-token-456');
        expect(state.optedIn, true);
      });

      test('initializes with optedIn false', () {
        final state = OSPushSubscriptionState({
          ...pushSubState,
          'optedIn': false,
        });

        expect(state.id, 'test-id-123');
        expect(state.token, 'test-token-456');
        expect(state.optedIn, false);
      });

      test('handles null/missing id', () {
        // with null id
        final stateWithNull = OSPushSubscriptionState({
          ...pushSubState,
          'id': null,
        });
        expect(stateWithNull.id, isNull);
        expect(stateWithNull.token, 'test-token-456');
        expect(stateWithNull.optedIn, true);

        // with missing id key
        final stateWithMissing = OSPushSubscriptionState({
          'token': 'test-token',
          'optedIn': true,
        });
        expect(stateWithMissing.id, isNull);
        expect(stateWithMissing.token, 'test-token');
        expect(stateWithMissing.optedIn, true);
      });

      test('handles null/missing token', () {
        // with null token
        final stateWithNull = OSPushSubscriptionState({
          ...pushSubState,
          'token': null,
        });
        expect(stateWithNull.id, 'test-id-123');
        expect(stateWithNull.token, isNull);
        expect(stateWithNull.optedIn, true);

        // with missing token key
        final stateWithMissing = OSPushSubscriptionState({
          'id': 'test-id',
          'optedIn': false,
        });
        expect(stateWithMissing.id, 'test-id');
        expect(stateWithMissing.token, isNull);
        expect(stateWithMissing.optedIn, false);
      });

      test('handles all null values', () {
        final state = OSPushSubscriptionState({
          'id': null,
          'token': null,
          'optedIn': false,
        });

        expect(state.id, isNull);
        expect(state.token, isNull);
        expect(state.optedIn, false);
      });
    });

    group('jsonRepresentation', () {
      test('returns json string with all fields', () {
        final state = OSPushSubscriptionState(pushSubState);
        final jsonString = state.jsonRepresentation();

        expect(jsonString, contains('"id": "test-id-123"'));
        expect(jsonString, contains('"token": "test-token-456"'));
        expect(jsonString, contains('"optedIn": true'));
      });

      test('returns json string with null fields', () {
        final state = OSPushSubscriptionState({
          ...pushSubState,
          'id': null,
          'token': null,
          'optedIn': false,
        });
        final jsonString = state.jsonRepresentation();

        expect(jsonString, contains('"id": null'));
        expect(jsonString, contains('"token": null'));
        expect(jsonString, contains('"optedIn": false'));
      });
    });

    group('field modification', () {
      test('fields can be modified after construction', () {
        final state = OSPushSubscriptionState(pushSubState);

        // Verify initial values
        expect(state.id, 'test-id-123');
        expect(state.token, 'test-token-456');
        expect(state.optedIn, true);

        // Modify id
        state.id = 'new-id';
        expect(state.id, 'new-id');

        // Modify token
        state.token = 'new-token';
        expect(state.token, 'new-token');

        // Modify optedIn
        state.optedIn = false;
        expect(state.optedIn, false);
      });

      test('modifications reflect in jsonRepresentation', () {
        final state = OSPushSubscriptionState(pushSubState);
        state.id = 'modified-id';
        state.token = 'modified-token';
        state.optedIn = true;

        final jsonString = state.jsonRepresentation();

        expect(jsonString, contains('"id": "modified-id"'));
        expect(jsonString, contains('"token": "modified-token"'));
        expect(jsonString, contains('"optedIn": true'));
      });
    });
  });

  group('OSPushSubscriptionChangedState', () {
    group('constructor', () {
      test('initializes with current and previous states', () {
        final changedState = OSPushSubscriptionChangedState(pushChangeState);

        expect(changedState.current.id, 'current-id');
        expect(changedState.current.token, 'current-token');
        expect(changedState.current.optedIn, true);

        expect(changedState.previous.id, 'previous-id');
        expect(changedState.previous.token, 'previous-token');
        expect(changedState.previous.optedIn, false);
      });

      test('handles null values in current state', () {
        final changedState =
            OSPushSubscriptionChangedState(pushNullChangeState);

        expect(changedState.current.id, isNull);
        expect(changedState.current.token, isNull);
        expect(changedState.current.optedIn, false);

        expect(changedState.previous.id, 'previous-id');
        expect(changedState.previous.token, 'previous-token');
        expect(changedState.previous.optedIn, true);
      });

      test('handles null values in previous state', () {
        final changedState = OSPushSubscriptionChangedState({
          'current': {
            'id': 'current-id',
            'token': 'current-token',
            'optedIn': true,
          },
          'previous': {'id': null, 'token': null, 'optedIn': false},
        });

        expect(changedState.current.id, 'current-id');
        expect(changedState.current.token, 'current-token');
        expect(changedState.current.optedIn, true);

        expect(changedState.previous.id, isNull);
        expect(changedState.previous.token, isNull);
        expect(changedState.previous.optedIn, false);
      });
    });

    group('jsonRepresentation', () {
      test('returns json string with current and previous states', () {
        final changedState = OSPushSubscriptionChangedState(pushChangeState);
        final jsonString = changedState.jsonRepresentation();

        expect(jsonString, contains('"current":'));
        expect(jsonString, contains('"previous":'));
        expect(jsonString, contains('"id": "current-id"'));
        expect(jsonString, contains('"token": "current-token"'));
        expect(jsonString, contains('"optedIn": true'));
        expect(jsonString, contains('"id": "previous-id"'));
        expect(jsonString, contains('"token": "previous-token"'));
        expect(jsonString, contains('"optedIn": false'));
      });

      test('handles null values in json representation', () {
        final changedState =
            OSPushSubscriptionChangedState(pushNullChangeState);
        final jsonString = changedState.jsonRepresentation();

        expect(jsonString, contains('"current"'));
        expect(jsonString, contains('"previous"'));
        expect(jsonString, contains('"id": null'));
        expect(jsonString, contains('"token": null'));
        expect(jsonString, contains('"optedIn": false'));
        expect(jsonString, contains('"id": "previous-id"'));
        expect(jsonString, contains('"token": "previous-token"'));
        expect(jsonString, contains('"optedIn": true'));
      });
    });

    group('state modification', () {
      test('current state can be modified', () {
        final changedState = OSPushSubscriptionChangedState(pushChangeState);
        changedState.current.id = 'modified-id';
        changedState.current.token = 'modified-token';
        changedState.current.optedIn = false;

        expect(changedState.current.id, 'modified-id');
        expect(changedState.current.token, 'modified-token');
        expect(changedState.current.optedIn, false);
      });

      test('previous state can be modified', () {
        final changedState = OSPushSubscriptionChangedState(pushChangeState);
        changedState.previous.id = 'modified-id';
        changedState.previous.token = 'modified-token';
        changedState.previous.optedIn = true;

        expect(changedState.previous.id, 'modified-id');
        expect(changedState.previous.token, 'modified-token');
        expect(changedState.previous.optedIn, true);
      });

      test('modifications to states reflect in jsonRepresentation', () {
        final changedState = OSPushSubscriptionChangedState(pushChangeState);
        changedState.current.id = 'new-current-id';
        changedState.previous.id = 'new-previous-id';

        final jsonString = changedState.jsonRepresentation();

        expect(jsonString, contains('"id": "new-current-id"'));
        expect(jsonString, contains('"id": "new-previous-id"'));
      });
    });
  });
}
