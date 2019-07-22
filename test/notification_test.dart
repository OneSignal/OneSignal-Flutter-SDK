import 'package:test/test.dart';
import 'package:onesignal_flutter/src/notification.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'test_data.dart';

void main() {
  final notificationJson = TestData.jsonForTest('notification_parsing_test');
  final notification = OSNotification(notificationJson);

  test('expect notification ID to be set', () {
    expect(notification.payload.notificationId,
        "8e0eeec2-aa42-4ff7-a74b-bce9ca9e588b");
  });

  test('expect buttons to be parsed correctly', () {
    expect(notification.payload.buttons.first.id, "test1");
  });

  test('expect content available to be parsed correctly', () {
    expect(notification.payload.contentAvailable, true);
  });

  test('expect sound to be parsed correctly', () {
    expect(notification.payload.sound, "default");
  });

  test('expect raw payload to be parsed correctly', () {
    expect(notification.payload.rawPayload['test'], "raw payload");
  });

  test('expect attachments to be parsed correctly', () {
    expect(notification.payload.attachments['id'], "https://www.onesignal.com");
  });

  test('expect body to be parsed correctly', () {
    expect(notification.payload.body, 'Welcome to OneSignal!');
  });

  test('expect mutable content to be parsed correctly', () {
    expect(notification.payload.mutableContent, true);
  });

  test('expect display type to be parsed correctly', () {
    expect(notification.displayType, OSNotificationDisplayType.alert);
  });

  test('expect body to be parsed correctly', () {
    expect(notification.appInFocus, true);
  });

  test('expect silent to be parsed correctly', () {
    expect(notification.silent, true);
  });

  test('expect shown to be parsed correctly', () {
    expect(notification.shown, true);
  });
}
