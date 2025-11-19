import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:onesignal_flutter/src/notification.dart';

import 'mock_channel.dart';

const validNotificationJson = {
  'notificationId': 'notification-123',
  'title': 'Test Title',
  'body': 'Test Body',
  'sound': 'default',
  'launchUrl': 'https://example.com',
  'templateId': 'template-456',
  'templateName': 'Template Name',
  'rawPayload': '{"key":"value"}',
  'additionalData': {'custom_key': 'custom_value'},
  'buttons': [
    {'id': 'btn1', 'text': 'Button 1'},
    {'id': 'btn2', 'text': 'Button 2', 'icon': 'icon.png'},
  ],
};

const iosOnlyJson = {
  'notificationId': 'ios-notification-123',
  'contentAvailable': true,
  'mutableContent': true,
  'category': 'CUSTOM_CATEGORY',
  'badge': 5,
  'badgeIncrement': 1,
  'subtitle': 'iOS Subtitle',
  'relevanceScore': 0.75,
  'interruptionLevel': 'timeSensitive',
  'attachments': {
    'image': 'https://example.com/image.png',
    'video': 'https://example.com/video.mp4',
  },
};

const androidOnlyJson = {
  'notificationId': 'android-notification-123',
  'smallIcon': 'icon_small',
  'largeIcon': 'icon_large',
  'bigPicture': 'https://example.com/big_picture.png',
  'smallIconAccentColor': '#FF0000FF',
  'ledColor': '#FFFF0000',
  'lockScreenVisibility': 1,
  'groupKey': 'group_key_1',
  'groupMessage': 'You have 2 messages',
  'fromProjectNumber': '123456789',
  'collapseId': 'collapse_1',
  'priority': 10,
  'androidNotificationId': 1,
  'backgroundImageLayout': {
    'image': 'https://example.com/bg.png',
    'titleTextColor': '#FF000000',
    'bodyTextColor': '#FF666666',
  },
};

const clickResultJson = {
  'action_id': 'action-123',
  'url': 'https://example.com/action',
};

void main() {
  group('OSNotification', () {
    test('creates from valid JSON with all shared parameters', () {
      final notification = OSNotification(validNotificationJson);

      expect(notification.notificationId, 'notification-123');
      expect(notification.title, 'Test Title');
      expect(notification.body, 'Test Body');
      expect(notification.sound, 'default');
      expect(notification.launchUrl, 'https://example.com');
      expect(notification.templateId, 'template-456');
      expect(notification.templateName, 'Template Name');
    });

    test('creates from JSON with null optional fields', () {
      final json = {'notificationId': 'simple-notification'};
      final notification = OSNotification(json);

      expect(notification.notificationId, 'simple-notification');
      expect(notification.title, isNull);
      expect(notification.body, isNull);
      expect(notification.sound, isNull);
      expect(notification.launchUrl, isNull);
    });

    test('parses additionalData correctly', () {
      final notification = OSNotification(validNotificationJson);

      expect(notification.additionalData, isNotNull);
      expect(notification.additionalData!['custom_key'], 'custom_value');
    });

    test('parses buttons correctly', () {
      final notification = OSNotification(validNotificationJson);

      expect(notification.buttons, isNotNull);
      expect(notification.buttons!.length, 2);
      expect(notification.buttons![0].id, 'btn1');
      expect(notification.buttons![0].text, 'Button 1');
      expect(notification.buttons![1].id, 'btn2');
      expect(notification.buttons![1].text, 'Button 2');
      expect(notification.buttons![1].icon, 'icon.png');
    });

    test('parses iOS-specific parameters', () {
      final notification = OSNotification(iosOnlyJson);

      expect(notification.contentAvailable, true);
      expect(notification.mutableContent, true);
      expect(notification.category, 'CUSTOM_CATEGORY');
      expect(notification.badge, 5);
      expect(notification.badgeIncrement, 1);
      expect(notification.subtitle, 'iOS Subtitle');
      expect(notification.relevanceScore, 0.75);
      expect(notification.interruptionLevel, 'timeSensitive');
      expect(notification.attachments, isNotNull);
    });

    test('parses Android-specific parameters', () {
      final notification = OSNotification(androidOnlyJson);

      expect(notification.smallIcon, 'icon_small');
      expect(notification.largeIcon, 'icon_large');
      expect(notification.bigPicture, 'https://example.com/big_picture.png');
      expect(notification.smallIconAccentColor, '#FF0000FF');
      expect(notification.ledColor, '#FFFF0000');
      expect(notification.lockScreenVisibility, 1);
      expect(notification.groupKey, 'group_key_1');
      expect(notification.groupMessage, 'You have 2 messages');
      expect(notification.fromProjectNumber, '123456789');
      expect(notification.collapseId, 'collapse_1');
      expect(notification.priority, 10);
      expect(notification.androidNotificationId, 1);
    });

    test('parses backgroundImageLayout correctly', () {
      final notification = OSNotification(androidOnlyJson);

      expect(notification.backgroundImageLayout, isNotNull);
      expect(notification.backgroundImageLayout!.image,
          'https://example.com/bg.png');
      expect(notification.backgroundImageLayout!.titleTextColor, '#FF000000');
      expect(notification.backgroundImageLayout!.bodyTextColor, '#FF666666');
    });

    test('parses grouped notifications correctly', () {
      final groupedNotificationsJson = '''[
        {"notificationId": "grouped-1", "title": "Title 1", "body": "Body 1"},
        {"notificationId": "grouped-2", "title": "Title 2", "body": "Body 2"},
        {"notificationId": "grouped-3", "title": "Title 3", "body": "Body 3"}
      ]''';

      final json = {
        'notificationId': 'parent-notification',
        'title': 'Parent Title',
        'body': 'Parent Body',
        'groupedNotifications': groupedNotificationsJson,
      };
      final notification = OSNotification(json);

      expect(notification.groupedNotifications, isNotNull);
      expect(notification.groupedNotifications!.length, 3);
      expect(notification.groupedNotifications![0].notificationId, 'grouped-1');
      expect(notification.groupedNotifications![0].title, 'Title 1');
      expect(notification.groupedNotifications![1].notificationId, 'grouped-2');
      expect(notification.groupedNotifications![1].body, 'Body 2');
      expect(notification.groupedNotifications![2].notificationId, 'grouped-3');
      expect(notification.groupedNotifications![2].title, 'Title 3');
    });

    test('creates with empty grouped notifications', () {
      final groupedNotificationsJson = '[]';

      final json = {
        'notificationId': 'notification-with-empty-group',
        'groupedNotifications': groupedNotificationsJson,
      };
      final notification = OSNotification(json);

      expect(notification.groupedNotifications, isNotNull);
      expect(notification.groupedNotifications!.length, 0);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final notification = OSNotification(validNotificationJson);
      final jsonRep = notification.jsonRepresentation();

      expect(jsonRep, isA<String>());
      expect(jsonRep, contains('key'));
      expect(jsonRep, contains('value'));
    });
  });

  group('OSNotificationClickResult', () {
    test('creates from valid JSON', () {
      final result = OSNotificationClickResult(clickResultJson);

      expect(result.actionId, 'action-123');
      expect(result.url, 'https://example.com/action');
    });

    test('creates from JSON with null fields', () {
      final json = <String, dynamic>{};
      final result = OSNotificationClickResult(json);

      expect(result.actionId, isNull);
      expect(result.url, isNull);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final result = OSNotificationClickResult(clickResultJson);
      final jsonRep = result.jsonRepresentation();

      expect(jsonRep, isA<String>());
      expect(jsonRep, contains('action-123'));
      expect(jsonRep, contains('https://example.com/action'));
    });

    test('jsonRepresentation handles null values', () {
      final json = <String, dynamic>{};
      final result = OSNotificationClickResult(json);
      final jsonRep = result.jsonRepresentation();

      expect(jsonRep, isA<String>());
      expect(jsonRep, contains('action_id'));
      expect(jsonRep, contains('url'));
    });
  });

  group('OSActionButton', () {
    test('creates with required parameters', () {
      final button = OSActionButton(id: 'btn1', text: 'Click Me');

      expect(button.id, 'btn1');
      expect(button.text, 'Click Me');
      expect(button.icon, isNull);
    });

    test('creates with all parameters', () {
      final button = OSActionButton(
        id: 'btn2',
        text: 'Share',
        icon: 'share_icon.png',
      );

      expect(button.id, 'btn2');
      expect(button.text, 'Share');
      expect(button.icon, 'share_icon.png');
    });

    test('creates from JSON', () {
      final json = {
        'id': 'action1',
        'text': 'Open',
        'icon': 'open.png',
      };
      final button = OSActionButton.fromJson(json);

      expect(button.id, 'action1');
      expect(button.text, 'Open');
      expect(button.icon, 'open.png');
    });

    test('creates from JSON without icon', () {
      final json = {
        'id': 'action2',
        'text': 'Dismiss',
      };
      final button = OSActionButton.fromJson(json);

      expect(button.id, 'action2');
      expect(button.text, 'Dismiss');
      expect(button.icon, isNull);
    });

    test('mapRepresentation returns correct map', () {
      final button = OSActionButton(
        id: 'btn',
        text: 'Text',
        icon: 'icon.png',
      );
      final map = button.mapRepresentation();

      expect(map['id'], 'btn');
      expect(map['text'], 'Text');
      expect(map['icon'], 'icon.png');
    });

    test('jsonRepresentation returns correct JSON string', () {
      final button = OSActionButton(
        id: 'btn1',
        text: 'Action Text',
        icon: 'icon.png',
      );
      final jsonRep = button.jsonRepresentation();

      expect(jsonRep, isA<String>());
      expect(jsonRep, contains('btn1'));
      expect(jsonRep, contains('Action Text'));
    });
  });

  group('OSAndroidBackgroundImageLayout', () {
    test('creates from valid JSON', () {
      final layout = OSAndroidBackgroundImageLayout({
        'image': 'https://example.com/bg.png',
        'titleTextColor': '#FF000000',
        'bodyTextColor': '#FF666666',
      });

      expect(layout.image, 'https://example.com/bg.png');
      expect(layout.titleTextColor, '#FF000000');
      expect(layout.bodyTextColor, '#FF666666');
    });

    test('creates from empty JSON', () {
      final layout = OSAndroidBackgroundImageLayout({});

      expect(layout.image, isNull);
      expect(layout.titleTextColor, isNull);
      expect(layout.bodyTextColor, isNull);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final layout = OSAndroidBackgroundImageLayout({
        'image': 'https://example.com/bg.png',
        'titleTextColor': '#FF000000',
        'bodyTextColor': '#FF666666',
      });
      final jsonRep = layout.jsonRepresentation();

      expect(jsonRep, isA<String>());
      expect(jsonRep, contains('image'));
      expect(jsonRep, contains('titleTextColor'));
      expect(jsonRep, contains('bodyTextColor'));
    });
  });

  group('OSNotificationWillDisplayEvent', () {
    test('creates from valid JSON', () {
      final json = {
        'notification': validNotificationJson,
      };
      final event = OSNotificationWillDisplayEvent(json);

      expect(event.notification, isNotNull);
      expect(event.notification.notificationId, 'notification-123');
      expect(event.notification.title, 'Test Title');
    });

    test('creates with iOS notification data', () {
      final json = {
        'notification': iosOnlyJson,
      };
      final event = OSNotificationWillDisplayEvent(json);

      expect(event.notification.contentAvailable, true);
      expect(event.notification.category, 'CUSTOM_CATEGORY');
    });

    test('jsonRepresentation returns correct JSON string', () {
      final json = {
        'notification': validNotificationJson,
      };
      final event = OSNotificationWillDisplayEvent(json);
      final jsonRep = event.jsonRepresentation();

      expect(jsonRep, isA<String>());
      expect(jsonRep, contains('notification'));
    });
  });

  group('OSNotificationClickEvent', () {
    test('creates from valid JSON with both notification and result', () {
      final json = {
        'notification': validNotificationJson,
        'result': clickResultJson,
      };
      final event = OSNotificationClickEvent(json);

      expect(event.notification, isNotNull);
      expect(event.notification.notificationId, 'notification-123');
      expect(event.result, isNotNull);
      expect(event.result.actionId, 'action-123');
      expect(event.result.url, 'https://example.com/action');
    });

    test('creates from JSON with minimal data', () {
      final json = {
        'notification': {'notificationId': 'click-123'},
        'result': <String, dynamic>{},
      };
      final event = OSNotificationClickEvent(json);

      expect(event.notification.notificationId, 'click-123');
      expect(event.result.actionId, isNull);
      expect(event.result.url, isNull);
    });

    test('jsonRepresentation returns correct JSON string', () {
      final json = {
        'notification': validNotificationJson,
        'result': clickResultJson,
      };
      final event = OSNotificationClickEvent(json);
      final jsonRep = event.jsonRepresentation();

      expect(jsonRep, isA<String>());
      expect(jsonRep, contains('notification'));
      expect(jsonRep, contains('result'));
    });

    test('jsonRepresentation includes action data from result', () {
      final json = {
        'notification': validNotificationJson,
        'result': clickResultJson,
      };
      final event = OSNotificationClickEvent(json);
      final jsonRep = event.jsonRepresentation();

      // The notification's jsonRepresentation only includes rawPayload
      // The result includes actionId and url
      expect(jsonRep, contains('action-123'));
      expect(jsonRep, contains('https://example.com/action'));
    });
  });

  group('OSDisplayNotification extension', () {
    late OneSignalMockChannelController channelController;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      channelController = OneSignalMockChannelController();
      channelController.resetState();
    });

    test('display() calls displayNotification with correct notification ID',
        () {
      final notification = OSNotification(validNotificationJson);

      notification.display();

      expect(
          channelController.state.displayedNotificationId, 'notification-123');
    });

    test('display() works with different notification IDs', () {
      final json = {'notificationId': 'custom-notification-id'};
      final notification = OSNotification(json);

      notification.display();

      expect(channelController.state.displayedNotificationId,
          'custom-notification-id');
    });

    test('multiple display() calls update the displayed notification ID', () {
      final notification1 = OSNotification({'notificationId': 'first-id'});
      final notification2 = OSNotification({'notificationId': 'second-id'});

      notification1.display();
      expect(channelController.state.displayedNotificationId, 'first-id');

      notification2.display();
      expect(channelController.state.displayedNotificationId, 'second-id');
    });
  });

  group('OSNotificationWillDisplayEvent preventDefault', () {
    late OneSignalMockChannelController channelController;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      channelController = OneSignalMockChannelController();
      channelController.resetState();
    });

    test('preventDefault() calls preventDefault with correct notification ID',
        () {
      final json = {
        'notification': validNotificationJson,
      };
      final event = OSNotificationWillDisplayEvent(json);

      event.preventDefault();

      expect(
          channelController.state.preventedNotificationId, 'notification-123');
    });

    test('preventDefault() works with different notification IDs', () {
      final json = {
        'notification': {'notificationId': 'custom-will-display-id'},
      };
      final event = OSNotificationWillDisplayEvent(json);

      event.preventDefault();

      expect(channelController.state.preventedNotificationId,
          'custom-will-display-id');
    });

    test('multiple preventDefault() calls update the prevented notification ID',
        () {
      final json1 = {
        'notification': {'notificationId': 'prevent-1'},
      };
      final json2 = {
        'notification': {'notificationId': 'prevent-2'},
      };
      final event1 = OSNotificationWillDisplayEvent(json1);
      final event2 = OSNotificationWillDisplayEvent(json2);

      event1.preventDefault();
      expect(channelController.state.preventedNotificationId, 'prevent-1');

      event2.preventDefault();
      expect(channelController.state.preventedNotificationId, 'prevent-2');
    });
  });

  group('OSNotificationClickEvent preventDefault', () {
    late OneSignalMockChannelController channelController;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      channelController = OneSignalMockChannelController();
      channelController.resetState();
    });

    test('preventDefault() calls preventDefault with correct notification ID',
        () {
      final json = {
        'notification': validNotificationJson,
        'result': clickResultJson,
      };
      final event = OSNotificationClickEvent(json);

      event.preventDefault();

      expect(
          channelController.state.preventedNotificationId, 'notification-123');
    });

    test('preventDefault() works with different notification IDs', () {
      final json = {
        'notification': {'notificationId': 'custom-click-id'},
        'result': <String, dynamic>{},
      };
      final event = OSNotificationClickEvent(json);

      event.preventDefault();

      expect(
          channelController.state.preventedNotificationId, 'custom-click-id');
    });

    test('multiple preventDefault() calls update the prevented notification ID',
        () {
      final json1 = {
        'notification': {'notificationId': 'click-prevent-1'},
        'result': <String, dynamic>{},
      };
      final json2 = {
        'notification': {'notificationId': 'click-prevent-2'},
        'result': <String, dynamic>{},
      };
      final event1 = OSNotificationClickEvent(json1);
      final event2 = OSNotificationClickEvent(json2);

      event1.preventDefault();
      expect(
          channelController.state.preventedNotificationId, 'click-prevent-1');

      event2.preventDefault();
      expect(
          channelController.state.preventedNotificationId, 'click-prevent-2');
    });
  });
}
