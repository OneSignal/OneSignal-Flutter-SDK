import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/inappmessage.dart';

const validMessageJson = {
  'message_id': 'test-message-id-123',
};

const validClickResultJson = {
  'action_id': 'action-123',
  'url': 'https://example.com',
  'closing_message': true,
};

void main() {
  group('OSInAppMessage', () {
    test('creates from valid JSON with message_id', () {
      final message = OSInAppMessage(validMessageJson);

      expect(message.messageId, validMessageJson['message_id']);
    });

    test('creates from JSON with null message_id', () {
      final json = <String, dynamic>{};
      final message = OSInAppMessage(json);

      expect(message.messageId, isNull);
    });

    test('jsonRepresentation returns correct JSON string', () {
      // Test with valid message_id
      final message1 = OSInAppMessage(validMessageJson);
      final jsonString1 = message1.jsonRepresentation();
      expect(jsonString1, contains('"message_id": "test-message-id-123"'));

      // Test with null message_id
      final json = <String, dynamic>{};
      final message2 = OSInAppMessage(json);
      final jsonString2 = message2.jsonRepresentation();
      expect(jsonString2, contains('"message_id"'));
      expect(jsonString2, contains('null'));
    });
  });

  group('OSInAppMessageClickResult', () {
    test('creates from valid JSON with all fields', () {
      final result = OSInAppMessageClickResult(validClickResultJson);

      expect(result.actionId, 'action-123');
      expect(result.url, 'https://example.com');
      expect(result.closingMessage, true);
    });

    test('creates from empty JSON', () {
      final json = <String, dynamic>{};
      final result = OSInAppMessageClickResult(json);

      expect(result.actionId, isNull);
      expect(result.url, isNull);
      expect(result.closingMessage, false);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final result = OSInAppMessageClickResult(validClickResultJson);
      final jsonString = result.jsonRepresentation();

      expect(jsonString, contains('"action_id": "action-123"'));
      expect(jsonString, contains('"url": "https://example.com"'));
      expect(jsonString, contains('"closing_message": true'));
    });

    test('jsonRepresentation handles null optional fields', () {
      final json = <String, dynamic>{};
      final result = OSInAppMessageClickResult(json);
      final jsonString = result.jsonRepresentation();

      expect(jsonString, contains('"action_id": null'));
      expect(jsonString, contains('"url": null'));
      expect(jsonString, contains('"closing_message": false'));
    });
  });

  group('OSInAppMessageClickEvent', () {
    test('creates from valid JSON with message and result', () {
      final json = {
        'message': validMessageJson,
        'result': validClickResultJson,
      };
      final event = OSInAppMessageClickEvent(json);

      expect(event.message.messageId, 'test-message-id-123');
      expect(event.result.actionId, 'action-123');
      expect(event.result.url, 'https://example.com');
      expect(event.result.closingMessage, true);
    });

    test('creates from JSON with minimal fields', () {
      final json = {
        'message': validMessageJson,
        'result': {},
      };
      final event = OSInAppMessageClickEvent(json);

      expect(event.message.messageId, 'test-message-id-123');
      expect(event.result.actionId, isNull);
      expect(event.result.url, isNull);
      expect(event.result.closingMessage, false);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final json = {
        'message': {
          'message_id': 'test-message-id-123',
        },
        'result': {
          'action_id': 'action-123',
          'url': 'https://example.com',
          'closing_message': true,
        },
      };
      final event = OSInAppMessageClickEvent(json);
      final jsonString = event.jsonRepresentation();
      print(jsonString);

      expect(jsonString, contains('"message"'));
      expect(jsonString, contains('"result"'));
    });
  });

  group('OSInAppMessageWillDisplayEvent', () {
    test('creates from valid JSON with message', () {
      final json = {
        'message': validMessageJson,
      };
      final event = OSInAppMessageWillDisplayEvent(json);

      expect(event.message.messageId, 'test-message-id-123');
    });

    test('creates from JSON with null message_id', () {
      final json = {
        'message': <String, dynamic>{},
      };
      final event = OSInAppMessageWillDisplayEvent(json);

      expect(event.message.messageId, isNull);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final json = {
        'message': validMessageJson,
      };
      final event = OSInAppMessageWillDisplayEvent(json);
      final jsonString = event.jsonRepresentation();

      expect(jsonString, contains('"message"'));
    });
  });

  group('OSInAppMessageDidDisplayEvent', () {
    test('creates from valid JSON with message', () {
      final json = {
        'message': validMessageJson,
      };
      final event = OSInAppMessageDidDisplayEvent(json);

      expect(event.message.messageId, 'test-message-id-123');
    });

    test('creates from JSON with null message_id', () {
      final json = {
        'message': <String, dynamic>{},
      };
      final event = OSInAppMessageDidDisplayEvent(json);

      expect(event.message.messageId, isNull);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final json = {
        'message': validMessageJson,
      };
      final event = OSInAppMessageDidDisplayEvent(json);
      final jsonString = event.jsonRepresentation();

      expect(jsonString, contains('"message"'));
    });
  });

  group('OSInAppMessageWillDismissEvent', () {
    test('creates from valid JSON with message', () {
      final json = {
        'message': validMessageJson,
      };
      final event = OSInAppMessageWillDismissEvent(json);

      expect(event.message.messageId, 'test-message-id-123');
    });

    test('creates from JSON with null message_id', () {
      final json = {
        'message': <String, dynamic>{},
      };
      final event = OSInAppMessageWillDismissEvent(json);

      expect(event.message.messageId, isNull);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final json = {
        'message': validMessageJson,
      };
      final event = OSInAppMessageWillDismissEvent(json);
      final jsonString = event.jsonRepresentation();

      expect(jsonString, contains('"message"'));
    });
  });

  group('OSInAppMessageDidDismissEvent', () {
    test('creates from valid JSON with message', () {
      final json = {
        'message': validMessageJson,
      };
      final event = OSInAppMessageDidDismissEvent(json);

      expect(event.message.messageId, 'test-message-id-123');
    });

    test('creates from JSON with null message_id', () {
      final json = {
        'message': <String, dynamic>{},
      };
      final event = OSInAppMessageDidDismissEvent(json);

      expect(event.message.messageId, isNull);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final json = {
        'message': validMessageJson,
      };
      final event = OSInAppMessageDidDismissEvent(json);
      final jsonString = event.jsonRepresentation();

      expect(jsonString, contains('"message"'));
    });
  });
}
