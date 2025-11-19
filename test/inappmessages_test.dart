import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/inappmessage.dart';
import 'package:onesignal_flutter/src/inappmessages.dart';

import 'mock_channel.dart';

const validMessageJson = {
  'message_id': 'test-message-id-123',
};

const validClickResultJson = {
  'action_id': 'action-123',
  'url': 'https://example.com',
  'closing_message': true,
};

const triggerName = 'purchase_made';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OneSignalInAppMessages', () {
    late OneSignalInAppMessages inAppMessages;
    late OneSignalMockChannelController channelController;

    setUp(() {
      channelController = OneSignalMockChannelController();
      channelController.resetState();
      inAppMessages = OneSignalInAppMessages();
    });

    group('addTrigger', () {
      test('invokes OneSignal#addTrigger method with key-value pair', () async {
        await inAppMessages.addTrigger(triggerName, 'true');

        expect(channelController.state.triggers, {triggerName: 'true'});
      });

      test('handles multiple triggers sequentially', () async {
        const triggerName2 = 'trigger2';
        await inAppMessages.addTrigger(triggerName, 'value1');
        expect(channelController.state.triggers, {triggerName: 'value1'});

        await inAppMessages.addTrigger(triggerName2, 'value2');
        expect(channelController.state.triggers, {triggerName2: 'value2'});
      });
    });

    group('addTriggers', () {
      test('invokes OneSignal#addTriggers method with map of triggers',
          () async {
        final triggers = {
          'purchase_made': 'true',
          'user_level': '5',
        };

        await inAppMessages.addTriggers(triggers);

        expect(channelController.state.triggers, triggers);
      });

      test('handles empty triggers map', () async {
        await inAppMessages.addTriggers({});

        expect(channelController.state.triggers, {});
      });
    });

    group('removeTrigger', () {
      test('invokes OneSignal#removeTrigger method with key', () async {
        await inAppMessages.removeTrigger(triggerName);

        expect(channelController.state.removedTrigger, triggerName);
      });
    });

    group('removeTriggers', () {
      test('invokes OneSignal#removeTriggers method with list of keys',
          () async {
        final keys = ['trigger1', 'trigger2'];

        await inAppMessages.removeTriggers(keys);

        expect(channelController.state.removedTriggers, keys);
      });

      test('handles empty keys list', () async {
        await inAppMessages.removeTriggers([]);

        expect(channelController.state.removedTriggers, []);
      });
    });

    group('clearTriggers', () {
      test('invokes OneSignal#clearTriggers method', () async {
        await inAppMessages.clearTriggers();

        expect(channelController.state.clearedTriggers, true);
      });
    });

    group('paused', () {
      test('invokes OneSignal#paused', () async {
        await inAppMessages.paused(true);

        expect(channelController.state.inAppMessagesPaused, true);

        await inAppMessages.paused(false);

        expect(channelController.state.inAppMessagesPaused, false);
      });
    });

    group('arePaused', () {
      test('invokes OneSignal#arePaused method and returns correct value',
          () async {
        await inAppMessages.paused(true);
        final result = await inAppMessages.arePaused();

        expect(result, true);
      });

      test('returns false when not paused', () async {
        final result = await inAppMessages.arePaused();

        expect(result, false);
      });
    });

    group('lifecycleInit', () {
      test('invokes OneSignal#lifecycleInit method', () async {
        await inAppMessages.lifecycleInit();

        expect(channelController.state.lifecycleInitCalled, true);
      });
    });

    group('Click listeners', () {
      test('addClickListener adds listener to list', () async {
        bool listenerCalled = false;

        void listener(OSInAppMessageClickEvent event) {
          listenerCalled = true;
        }

        inAppMessages.addClickListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onClickInAppMessage',
            {
              'message': validMessageJson,
              'result': validClickResultJson,
            },
          ),
        );

        expect(listenerCalled, true);
      });

      test('removeClickListener removes listener from list', () async {
        bool listenerCalled = false;

        void listener(OSInAppMessageClickEvent event) {
          listenerCalled = true;
        }

        inAppMessages.addClickListener(listener);
        inAppMessages.removeClickListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onClickInAppMessage',
            {
              'message': validMessageJson,
              'result': validClickResultJson,
            },
          ),
        );

        expect(listenerCalled, false);
      });
    });

    group('WillDisplay listeners', () {
      test('addWillDisplayListener adds listener', () async {
        bool listenerCalled = false;
        late OSInAppMessageWillDisplayEvent receivedEvent;

        void listener(OSInAppMessageWillDisplayEvent event) {
          listenerCalled = true;
          receivedEvent = event;
        }

        inAppMessages.addWillDisplayListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onWillDisplayInAppMessage',
            {'message': validMessageJson},
          ),
        );

        expect(listenerCalled, true);
        expect(receivedEvent.message.messageId, 'test-message-id-123');
      });

      test('removeWillDisplayListener removes listener', () async {
        bool listenerCalled = false;

        void listener(OSInAppMessageWillDisplayEvent event) {
          listenerCalled = true;
        }

        inAppMessages.addWillDisplayListener(listener);
        inAppMessages.removeWillDisplayListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onWillDisplayInAppMessage',
            {'message': validMessageJson},
          ),
        );

        expect(listenerCalled, false);
      });
    });

    group('DidDisplay listeners', () {
      test('addDidDisplayListener adds listener', () async {
        bool listenerCalled = false;

        void listener(OSInAppMessageDidDisplayEvent event) {
          listenerCalled = true;
        }

        inAppMessages.addDidDisplayListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onDidDisplayInAppMessage',
            {'message': validMessageJson},
          ),
        );

        expect(listenerCalled, true);
      });

      test('removeDidDisplayListener removes listener', () async {
        bool listenerCalled = false;

        void listener(OSInAppMessageDidDisplayEvent event) {
          listenerCalled = true;
        }

        inAppMessages.addDidDisplayListener(listener);
        inAppMessages.removeDidDisplayListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onDidDisplayInAppMessage',
            {'message': validMessageJson},
          ),
        );

        expect(listenerCalled, false);
      });

      test('did display listener is invoked', () async {
        bool listenerCalled = false;

        void listener(OSInAppMessageDidDisplayEvent event) {
          listenerCalled = true;
        }

        inAppMessages.addDidDisplayListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onDidDisplayInAppMessage',
            {'message': validMessageJson},
          ),
        );

        expect(listenerCalled, true);
      });
    });

    group('WillDismiss listeners', () {
      test('addWillDismissListener adds listener', () async {
        bool listenerCalled = false;
        late OSInAppMessageWillDismissEvent receivedEvent;

        void listener(OSInAppMessageWillDismissEvent event) {
          listenerCalled = true;
          receivedEvent = event;
        }

        inAppMessages.addWillDismissListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onWillDismissInAppMessage',
            {'message': validMessageJson},
          ),
        );

        expect(listenerCalled, true);
        expect(receivedEvent.message.messageId, 'test-message-id-123');
      });

      test('removeWillDismissListener removes listener', () async {
        bool listenerCalled = false;

        void listener(OSInAppMessageWillDismissEvent event) {
          listenerCalled = true;
        }

        inAppMessages.addWillDismissListener(listener);
        inAppMessages.removeWillDismissListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onWillDismissInAppMessage',
            {'message': validMessageJson},
          ),
        );

        expect(listenerCalled, false);
      });
    });

    group('DidDismiss listeners', () {
      test('addDidDismissListener adds listener', () async {
        bool listenerCalled = false;
        late OSInAppMessageDidDismissEvent receivedEvent;

        void listener(OSInAppMessageDidDismissEvent event) {
          listenerCalled = true;
          receivedEvent = event;
        }

        inAppMessages.addDidDismissListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onDidDismissInAppMessage',
            {'message': validMessageJson},
          ),
        );

        expect(listenerCalled, true);
        expect(receivedEvent.message.messageId, 'test-message-id-123');
      });

      test('removeDidDismissListener removes listener', () async {
        bool listenerCalled = false;

        void listener(OSInAppMessageDidDismissEvent event) {
          listenerCalled = true;
        }

        inAppMessages.addDidDismissListener(listener);
        inAppMessages.removeDidDismissListener(listener);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onDidDismissInAppMessage',
            {'message': validMessageJson},
          ),
        );

        expect(listenerCalled, false);
      });
    });

    group('Multiple listeners', () {
      test('multiple click listeners are all invoked', () async {
        int listenerCount = 0;

        void listener1(OSInAppMessageClickEvent event) {
          listenerCount++;
        }

        void listener2(OSInAppMessageClickEvent event) {
          listenerCount++;
        }

        inAppMessages.addClickListener(listener1);
        inAppMessages.addClickListener(listener2);

        await inAppMessages.handleMethod(
          MethodCall(
            'OneSignal#onClickInAppMessage',
            {
              'message': validMessageJson,
              'result': validClickResultJson,
            },
          ),
        );

        expect(listenerCount, 2);
      });
    });
  });
}
