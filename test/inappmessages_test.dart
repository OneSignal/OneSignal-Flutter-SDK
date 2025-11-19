import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/inappmessage.dart';
import 'package:onesignal_flutter/src/inappmessages.dart';

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
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      inAppMessages = OneSignalInAppMessages();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('OneSignal#inappmessages'),
        (call) async {
          methodCalls.add(call);
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('OneSignal#inappmessages'),
        null,
      );
    });

    group('addTrigger', () {
      test('invokes OneSignal#addTrigger method with key-value pair', () async {
        await inAppMessages.addTrigger(triggerName, 'true');

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#addTrigger');
        expect(methodCalls[0].arguments, {triggerName: 'true'});
      });

      test('handles multiple triggers sequentially', () async {
        const triggerName2 = 'trigger2';
        await inAppMessages.addTrigger(triggerName, 'value1');
        await inAppMessages.addTrigger(triggerName2, 'value2');

        expect(methodCalls.length, 2);
        expect(methodCalls[0].arguments, {triggerName: 'value1'});
        expect(methodCalls[1].arguments, {triggerName2: 'value2'});
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

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#addTriggers');
        expect(methodCalls[0].arguments, triggers);
      });

      test('handles empty triggers map', () async {
        await inAppMessages.addTriggers({});

        expect(methodCalls.length, 1);
        expect(methodCalls[0].arguments, {});
      });
    });

    group('removeTrigger', () {
      test('invokes OneSignal#removeTrigger method with key', () async {
        await inAppMessages.removeTrigger(triggerName);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#removeTrigger');
        expect(methodCalls[0].arguments, triggerName);
      });
    });

    group('removeTriggers', () {
      test('invokes OneSignal#removeTriggers method with list of keys',
          () async {
        final keys = ['trigger1', 'trigger2'];

        await inAppMessages.removeTriggers(keys);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#removeTriggers');
        expect(methodCalls[0].arguments, keys);
      });

      test('handles empty keys list', () async {
        await inAppMessages.removeTriggers([]);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].arguments, []);
      });
    });

    group('clearTriggers', () {
      test('invokes OneSignal#clearTriggers method', () async {
        await inAppMessages.clearTriggers();

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#clearTriggers');
      });
    });

    group('paused', () {
      test('invokes OneSignal#paused', () async {
        await inAppMessages.paused(true);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#paused');
        expect(methodCalls[0].arguments, true);

        await inAppMessages.paused(false);

        expect(methodCalls.length, 2);
        expect(methodCalls[1].method, 'OneSignal#paused');
        expect(methodCalls[1].arguments, false);
      });
    });

    group('arePaused', () {
      test('invokes OneSignal#arePaused method', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('OneSignal#inappmessages'),
          (call) async {
            if (call.method == 'OneSignal#arePaused') {
              return true;
            }
            return null;
          },
        );

        final result = await inAppMessages.arePaused();

        expect(result, true);
      });
    });

    group('lifecycleInit', () {
      test('invokes OneSignal#lifecycleInit method', () async {
        await inAppMessages.lifecycleInit();

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#lifecycleInit');
      });
    });

    group('Click listeners', () {
      test('addClickListener adds listener to list', () async {
        bool listenerCalled = false;

        void listener(OSInAppMessageClickEvent event) {
          listenerCalled = true;
        }

        inAppMessages.addClickListener(listener);

        // Simulate native call to verify listener was added
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

        // Simulate native call to verify listener was removed
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

        // Simulate native call to verify listener was added
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

        // Simulate native call to verify listener was removed
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

        // Simulate native call to verify listener was added
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

        // Simulate native call to verify listener was removed
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

        // Simulate native call to verify listener was added
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

        // Simulate native call to verify listener was removed
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

        // Simulate native call to verify listener was added
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

        // Simulate native call to verify listener was removed
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
