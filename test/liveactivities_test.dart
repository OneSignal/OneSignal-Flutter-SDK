import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/liveactivities.dart';

import 'mock_channel.dart';

const activityId = 'test-activity-id';
const token = 'test-token';
const activityType = 'TestActivityType';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OneSignalLiveActivities', () {
    late OneSignalLiveActivities liveActivities;
    late OneSignalMockChannelController channelController;

    setUp(() {
      channelController = OneSignalMockChannelController();
      channelController.resetState();
      liveActivities = OneSignalLiveActivities();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    group('enterLiveActivity', () {
      test('invokes OneSignal#enterLiveActivity with activityId and token',
          () async {
        await liveActivities.enterLiveActivity(activityId, token);

        expect(channelController.state.liveActivityEntered, true);
        expect(channelController.state.liveActivityId, activityId);
        expect(channelController.state.liveActivityToken, token);
      });
    });

    group('exitLiveActivity', () {
      test('invokes OneSignal#exitLiveActivity with activityId', () async {
        await liveActivities.exitLiveActivity(activityId);

        expect(channelController.state.liveActivityExited, true);
        expect(channelController.state.liveActivityId, activityId);
      });
    });

    group('setupDefault', () {
      test('invokes OneSignal#setupDefault without options', () async {
        await liveActivities.setupDefault();

        expect(channelController.state.liveActivitySetupCalled, true);
        expect(channelController.state.liveActivitySetupOptions, isNull);
      });

      test('invokes OneSignal#setupDefault with custom options', () async {
        final options = LiveActivitySetupOptions(
          enablePushToStart: false,
          enablePushToUpdate: false,
        );

        await liveActivities.setupDefault(options: options);

        expect(channelController.state.liveActivitySetupCalled, true);
        expect(channelController.state.liveActivitySetupOptions, {
          'enablePushToStart': false,
          'enablePushToUpdate': false,
        });
      });

      test('setupDefault with default option values', () async {
        final options = LiveActivitySetupOptions();

        await liveActivities.setupDefault(options: options);

        expect(channelController.state.liveActivitySetupOptions, {
          'enablePushToStart': true,
          'enablePushToUpdate': true,
        });
      });
    });

    group('startDefault', () {
      test('invokes OneSignal#startDefault with required parameters', () async {
        final attributes = {'name': 'John', 'score': 100};
        final content = {'message': 'Hello'};

        await liveActivities.startDefault(activityId, attributes, content);

        expect(channelController.state.liveActivityStarted, true);
        expect(channelController.state.liveActivityId, activityId);
        expect(channelController.state.liveActivityAttributes, attributes);
        expect(channelController.state.liveActivityContent, content);
      });

      test('handles complex nested attributes and content', () async {
        final complexAttributes = {
          'nested': {'key': 'value'},
          'array': [1, 2, 3],
        };
        final complexContent = {
          'state': 'active',
          'data': {'status': 'running'},
        };

        await liveActivities.startDefault(
            activityId, complexAttributes, complexContent);

        expect(channelController.state.liveActivityAttributes['nested']['key'],
            'value');
        expect(channelController.state.liveActivityContent['data']['status'],
            'running');
      });
    });

    group('setPushToStartToken', () {
      test('invokes OneSignal#setPushToStartToken with activityType and token',
          () async {
        await liveActivities.setPushToStartToken(activityType, token);

        expect(channelController.state.liveActivityPushToStartSet, true);
        expect(channelController.state.liveActivityType, activityType);
        expect(channelController.state.liveActivityPushToken, token);
      });
    });

    group('removePushToStartToken', () {
      test('invokes OneSignal#removePushToStartToken with activityType',
          () async {
        await liveActivities.removePushToStartToken(activityType);

        expect(channelController.state.liveActivityPushToStartRemoved, true);
        expect(channelController.state.liveActivityType, activityType);
      });
    });
  });

  group('LiveActivitySetupOptions', () {
    test('creates with default values', () {
      final options = LiveActivitySetupOptions();

      expect(options.enablePushToStart, true);
      expect(options.enablePushToUpdate, true);
    });

    test('creates with both custom values', () {
      final options = LiveActivitySetupOptions(
        enablePushToStart: false,
        enablePushToUpdate: false,
      );

      expect(options.enablePushToStart, false);
      expect(options.enablePushToUpdate, false);
    });
  });
}
