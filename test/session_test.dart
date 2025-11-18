import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/session.dart';

import 'mock_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OneSignalSession', () {
    late OneSignalSession session;
    late OneSignalMockChannelController channelController;

    setUp(() {
      channelController = OneSignalMockChannelController();
      channelController.resetState();
      session = OneSignalSession();
    });

    group('addOutcome', () {
      test('invokes OneSignal#addOutcome with outcome name', () async {
        const outcomeName = 'test_outcome';

        await session.addOutcome(outcomeName);

        expect(channelController.state.addedOutcome, outcomeName);
      });

      test('can be called multiple times', () async {
        await session.addOutcome('outcome1');
        await session.addOutcome('outcome2');
        await session.addOutcome('outcome3');

        expect(channelController.state.addedOutcome, 'outcome3');
        expect(channelController.state.addOutcomeCallCount, 3);
      });

      test('handles empty string outcome name', () async {
        await session.addOutcome('');

        expect(channelController.state.addedOutcome, '');
      });
    });

    group('addUniqueOutcome', () {
      test('invokes OneSignal#addUniqueOutcome with outcome name', () async {
        const outcomeName = 'unique_outcome';

        await session.addUniqueOutcome(outcomeName);

        expect(channelController.state.addedUniqueOutcome, outcomeName);
      });

      test('can be called multiple times', () async {
        await session.addUniqueOutcome('unique1');
        await session.addUniqueOutcome('unique2');

        expect(channelController.state.addedUniqueOutcome, 'unique2');
        expect(channelController.state.addUniqueOutcomeCallCount, 2);
      });

      test('handles empty string outcome name', () async {
        await session.addUniqueOutcome('');

        expect(channelController.state.addedUniqueOutcome, '');
      });
    });

    group('addOutcomeWithValue', () {
      test('invokes OneSignal#addOutcomeWithValue with name and value',
          () async {
        const outcomeName = 'valued_outcome';
        const outcomeValue = 42.5;

        await session.addOutcomeWithValue(outcomeName, outcomeValue);

        expect(channelController.state.addedOutcomeWithValueName, outcomeName);
        expect(
            channelController.state.addedOutcomeWithValueValue, outcomeValue);
      });

      test('handles negative value', () async {
        const outcomeName = 'negative_outcome';
        const outcomeValue = -10.5;

        await session.addOutcomeWithValue(outcomeName, outcomeValue);

        expect(channelController.state.addedOutcomeWithValueName, outcomeName);
        expect(
            channelController.state.addedOutcomeWithValueValue, outcomeValue);
      });

      test('can be called multiple times with different values', () async {
        await session.addOutcomeWithValue('outcome1', 10.0);
        await session.addOutcomeWithValue('outcome2', 20.5);
        await session.addOutcomeWithValue('outcome3', 30.75);

        expect(channelController.state.addedOutcomeWithValueName, 'outcome3');
        expect(channelController.state.addedOutcomeWithValueValue, 30.75);
        expect(channelController.state.addOutcomeWithValueCallCount, 3);
      });

      test('handles empty string outcome name with value', () async {
        const outcomeValue = 15.5;

        await session.addOutcomeWithValue('', outcomeValue);

        expect(channelController.state.addedOutcomeWithValueName, '');
        expect(
            channelController.state.addedOutcomeWithValueValue, outcomeValue);
      });
    });
  });
}
