import 'package:test/test.dart';
import 'package:onesignal_flutter/src/notification.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'test_data.dart';

void main() {
  final notificationJson = TestData.jsonForTest('notification_parsing_test');
  final notification = OSNotification(notificationJson);

  test('expect notification ID to be set', () {
    expect(notification.notificationId,
        "8e0eeec2-aa42-4ff7-a74b-bce9ca9e588b");
  });

  test('expect buttons to be parsed correctly', () {
    expect(notification.buttons!.first.id, "test1");
  });

  test('expect content available to be parsed correctly', () {
    expect(notification.contentAvailable, true);
  });

  test('expect sound to be parsed correctly', () {
    expect(notification.sound, "default");
  });

  test('expect raw payload to be parsed correctly', () {
    expect(notification.rawPayload!['test'], "raw payload");
  });

  test('expect attachments to be parsed correctly', () {
    expect(notification.attachments!['id'], "https://www.onesignal.com");
  });

  test('expect body to be parsed correctly', () {
    expect(notification.body, 'Welcome to OneSignal!');
  });

  test('expect mutable content to be parsed correctly', () {
    expect(notification.mutableContent, true);
  });
}
