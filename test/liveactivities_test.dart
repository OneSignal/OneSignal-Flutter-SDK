import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/liveactivities.dart';

const activityId = 'test-activity-id';
const token = 'test-token';
const activityType = 'TestActivityType';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OneSignalLiveActivities', () {
    late OneSignalLiveActivities liveActivities;
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      liveActivities = OneSignalLiveActivities();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('OneSignal#liveactivities'),
        (call) async {
          methodCalls.add(call);
          return null;
        },
      );
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('OneSignal#liveactivities'),
        null,
      );
    });

    group('enterLiveActivity', () {
      test('invokes OneSignal#enterLiveActivity with activityId and token',
          () async {
        await liveActivities.enterLiveActivity(activityId, token);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#enterLiveActivity');
        expect(methodCalls[0].arguments,
            {'activityId': activityId, 'token': token});
      });
    });

    group('exitLiveActivity', () {
      test('invokes OneSignal#exitLiveActivity with activityId', () async {
        await liveActivities.exitLiveActivity(activityId);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#exitLiveActivity');
        expect(methodCalls[0].arguments, {'activityId': activityId});
      });
    });

    group('setupDefault', () {
      test('invokes OneSignal#setupDefault without options', () async {
        await liveActivities.setupDefault();

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#setupDefault');
        expect(methodCalls[0].arguments['options'], isNull);
      });

      test('invokes OneSignal#setupDefault with custom options', () async {
        final options = LiveActivitySetupOptions(
          enablePushToStart: false,
          enablePushToUpdate: false,
        );

        await liveActivities.setupDefault(options: options);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#setupDefault');
        expect(methodCalls[0].arguments['options'], {
          'enablePushToStart': false,
          'enablePushToUpdate': false,
        });
      });

      test('setupDefault with default option values', () async {
        final options = LiveActivitySetupOptions();

        await liveActivities.setupDefault(options: options);

        expect(methodCalls[0].arguments['options'], {
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

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#startDefault');
        expect(methodCalls[0].arguments, {
          'activityId': activityId,
          'attributes': attributes,
          'content': content,
        });
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

        expect(
            methodCalls[0].arguments['attributes']['nested']['key'], 'value');
        expect(
            methodCalls[0].arguments['content']['data']['status'], 'running');
      });
    });

    group('setPushToStartToken', () {
      test('invokes OneSignal#setPushToStartToken with activityType and token',
          () async {
        await liveActivities.setPushToStartToken(activityType, token);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#setPushToStartToken');
        expect(methodCalls[0].arguments,
            {'activityType': activityType, 'token': token});
      });
    });

    group('removePushToStartToken', () {
      test('invokes OneSignal#removePushToStartToken with activityType',
          () async {
        await liveActivities.removePushToStartToken(activityType);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#removePushToStartToken');
        expect(methodCalls[0].arguments, {'activityType': activityType});
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
