import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/pushsubscription.dart';
import 'package:onesignal_flutter/src/subscription.dart';

import 'mock_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OneSignalPushSubscription', () {
    late OneSignalPushSubscription pushSubscription;
    late OneSignalMockChannelController channelController;

    setUp(() {
      channelController = OneSignalMockChannelController();
      channelController.resetState();
      pushSubscription = OneSignalPushSubscription();
    });

    group('initial state', () {
      test('id, token, and optedIn are null initially', () {
        expect(pushSubscription.id, isNull);
        expect(pushSubscription.token, isNull);
        expect(pushSubscription.optedIn, isNull);
      });
    });

    group('lifecycleInit', () {
      test('fetches and sets id, token, and optedIn', () async {
        channelController.state.pushSubscriptionId = 'test-id-123';
        channelController.state.pushSubscriptionToken = 'test-token-456';
        channelController.state.pushSubscriptionOptedIn = true;

        await pushSubscription.lifecycleInit();

        expect(pushSubscription.id, 'test-id-123');
        expect(pushSubscription.token, 'test-token-456');
        expect(pushSubscription.optedIn, true);
        expect(channelController.state.lifecycleInitCalled, true);
      });

      test('handles null values from native', () async {
        channelController.state.pushSubscriptionId = null;
        channelController.state.pushSubscriptionToken = null;
        channelController.state.pushSubscriptionOptedIn = false;

        await pushSubscription.lifecycleInit();

        expect(pushSubscription.id, isNull);
        expect(pushSubscription.token, isNull);
        expect(pushSubscription.optedIn, false);
      });

      test('updates state when values change', () async {
        channelController.state.pushSubscriptionId = 'id-1';
        channelController.state.pushSubscriptionToken = 'token-1';
        channelController.state.pushSubscriptionOptedIn = false;

        await pushSubscription.lifecycleInit();

        expect(pushSubscription.id, 'id-1');
        expect(pushSubscription.token, 'token-1');
        expect(pushSubscription.optedIn, false);

        // Change mock state
        channelController.state.pushSubscriptionId = 'id-2';
        channelController.state.pushSubscriptionToken = 'token-2';
        channelController.state.pushSubscriptionOptedIn = true;

        await pushSubscription.lifecycleInit();

        expect(pushSubscription.id, 'id-2');
        expect(pushSubscription.token, 'token-2');
        expect(pushSubscription.optedIn, true);
      });
    });

    group('optIn', () {
      test('calls native optIn method', () async {
        await pushSubscription.optIn();

        expect(channelController.state.pushSubscriptionOptInCalled, true);
      });

      test('can be called multiple times', () async {
        await pushSubscription.optIn();
        await pushSubscription.optIn();
        await pushSubscription.optIn();

        expect(channelController.state.pushSubscriptionOptInCallCount, 3);
      });
    });

    group('optOut', () {
      test('calls native optOut method', () async {
        await pushSubscription.optOut();

        expect(channelController.state.pushSubscriptionOptOutCalled, true);
      });

      test('can be called multiple times', () async {
        await pushSubscription.optOut();
        await pushSubscription.optOut();

        expect(channelController.state.pushSubscriptionOptOutCallCount, 2);
      });
    });

    group('observers', () {
      test('can add observer', () {
        bool observerCalled = false;

        pushSubscription.addObserver((stateChanges) {
          observerCalled = true;
        });

        // Trigger a change via mock channel
        final changeData = {
          'current': {'id': 'new-id', 'token': 'new-token', 'optedIn': true},
          'previous': {'id': 'old-id', 'token': 'old-token', 'optedIn': false},
        };

        channelController.simulatePushSubscriptionChange(changeData);

        expect(observerCalled, true);
      });

      test('can add multiple observers', () {
        int observer1CallCount = 0;
        int observer2CallCount = 0;

        pushSubscription.addObserver((stateChanges) {
          observer1CallCount++;
        });

        pushSubscription.addObserver((stateChanges) {
          observer2CallCount++;
        });

        final changeData = {
          'current': {'id': 'id', 'token': 'token', 'optedIn': true},
          'previous': {'id': 'id', 'token': 'token', 'optedIn': false},
        };

        channelController.simulatePushSubscriptionChange(changeData);

        expect(observer1CallCount, 1);
        expect(observer2CallCount, 1);
      });

      test('can remove observer', () {
        int callCount = 0;

        void observer(OSPushSubscriptionChangedState stateChanges) {
          callCount++;
        }

        pushSubscription.addObserver(observer);
        pushSubscription.removeObserver(observer);

        final changeData = {
          'current': {'id': 'id', 'token': 'token', 'optedIn': true},
          'previous': {'id': 'id', 'token': 'token', 'optedIn': false},
        };

        channelController.simulatePushSubscriptionChange(changeData);

        expect(callCount, 0);
      });

      test('observer receives correct state changes', () {
        OSPushSubscriptionChangedState? receivedState;

        pushSubscription.addObserver((stateChanges) {
          receivedState = stateChanges;
        });

        final changeData = {
          'current': {'id': 'new-id', 'token': 'new-token', 'optedIn': true},
          'previous': {'id': 'old-id', 'token': 'old-token', 'optedIn': false},
        };

        channelController.simulatePushSubscriptionChange(changeData);

        expect(receivedState, isNotNull);
        expect(receivedState!.current.id, 'new-id');
        expect(receivedState!.current.token, 'new-token');
        expect(receivedState!.current.optedIn, true);
        expect(receivedState!.previous.id, 'old-id');
        expect(receivedState!.previous.token, 'old-token');
        expect(receivedState!.previous.optedIn, false);
      });
    });

    group('onPushSubscriptionChange', () {
      test('updates internal state when subscription changes', () async {
        channelController.state.pushSubscriptionId = 'initial-id';
        channelController.state.pushSubscriptionToken = 'initial-token';
        channelController.state.pushSubscriptionOptedIn = false;

        await pushSubscription.lifecycleInit();

        expect(pushSubscription.id, 'initial-id');
        expect(pushSubscription.token, 'initial-token');
        expect(pushSubscription.optedIn, false);

        // Simulate a subscription change
        final changeData = {
          'current': {
            'id': 'updated-id',
            'token': 'updated-token',
            'optedIn': true
          },
          'previous': {
            'id': 'initial-id',
            'token': 'initial-token',
            'optedIn': false
          },
        };

        channelController.simulatePushSubscriptionChange(changeData);

        expect(pushSubscription.id, 'updated-id');
        expect(pushSubscription.token, 'updated-token');
        expect(pushSubscription.optedIn, true);
      });

      test('handles null values in state changes', () async {
        channelController.state.pushSubscriptionId = 'id';
        channelController.state.pushSubscriptionToken = 'token';
        channelController.state.pushSubscriptionOptedIn = true;

        await pushSubscription.lifecycleInit();

        final changeData = {
          'current': {'id': null, 'token': null, 'optedIn': false},
          'previous': {'id': 'id', 'token': 'token', 'optedIn': true},
        };

        channelController.simulatePushSubscriptionChange(changeData);

        expect(pushSubscription.id, isNull);
        expect(pushSubscription.token, isNull);
        expect(pushSubscription.optedIn, false);
      });
    });
  });
}
