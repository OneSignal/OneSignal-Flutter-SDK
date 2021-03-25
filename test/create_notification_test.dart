import 'package:test/test.dart';
import 'test_data.dart';

void main() {
  //silent notification tests
  test('expect silent notifications contentAvailable param to be true', () {
    expect(silentNotification.contentAvailable, true);
  });

  test('expect notification to parse player IDs correctly', () {
    expect(silentNotification.playerIds.first, testPlayerId);
  });

  test('expect notification to parse additional data correctly', () {
    expect(silentNotification.additionalData!['test'], 'value');
  });

  //normal notification tests
  test('expect notification content to be correct', () {
    expect(notificationJson['contents']['es'], 'test_content');
  });

  test('expect notification headings to be correct', () {
    expect(notificationJson['headings']['es'], 'test heading');
  });

  test('expect subtitle to be correct', () {
    expect(notificationJson['subtitle']['es'], 'test subtitle');
  });

  test('expect contentAvailable to be parsed correctly', () {
    expect(notificationJson['content_available'], true);
  });

  test('expect url to be parsed correctly', () {
    expect(notificationJson['url'], 'https://www.google.com/');
  });

  test('expect ios attahgments to be parsed correctly', () {
    expect(notificationJson['ios_attachments']['id1'], 'puppy.jpg');
  });

  test('expect big picture to be parsed correctly', () {
    expect(notificationJson['big_picture'], 'puppy2.jpg');
  });

  test('expect ios category to be parsed correctly', () {
    expect(notificationJson['ios_category'], 'test_category');
  });

  test('expect ios sound to be parsed correctly', () {
    expect(notificationJson['ios_sound'], 'ping.aiff');
  });

  test('expect android sound to be parsed correctly', () {
    expect(notificationJson['android_sound'], 'ping.mp3');
  });

  test('expect android small icon to be parsed correctly', () {
    expect(notificationJson['small_icon'], 'puppy_small.jpg');
  });

  test('expect android large icon to be parsed correctly', () {
    expect(notificationJson['large_icon'], 'puppy_large.jpg');
  });

  test('expect android channel ID to be parsed correctly', () {
    expect(notificationJson['android_channel_id'], 'test_channel_id');
  });

  test('expect iOS badge type to be parsed correctly', () {
    expect(notificationJson['ios_badgeType'], 'Increase');
  });

  test('expect iOS badge count to be parsed correctly', () {
    expect(notificationJson['ios_badgeCount'], 2);
  });

  test('expect collapse ID to be parsed correctly', () {
    expect(notificationJson['collapse_id'], 'test_collapse_id');
  });

  test('expect sendAfter to be parsed correctly', () {
    expect(
        notificationJson['send_after'], "2018-07-24T20:38:24.571Z UTC00:00:00");
  });

  test('expect delayed option to be parsed correctly', () {
    expect(notificationJson['delayed_option'], 'last_active');
  });

  test('expect delivery time of day to be parsed correctly', () {
    expect(notificationJson['delivery_time_of_day'], '9:00 AM');
  });

  test('expect buttons to be parsed correctly', () {
    List<dynamic> buttonsJson = notificationJson['buttons'];
    expect(buttonsJson.first['id'], 'test_id');
    expect(buttonsJson.first['text'], 'test_text');
    expect(buttonsJson.first['icon'], 'test_icon');
  });
}
