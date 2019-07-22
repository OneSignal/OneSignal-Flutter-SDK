import 'dart:convert';
import 'dart:io';
import 'package:onesignal_flutter/src/create_notification.dart';
import 'package:onesignal_flutter/src/notification.dart';
import 'package:onesignal_flutter/src/defines.dart';

class TestData {
  static final file = new File(Directory.current.path + '/test.json');
  static final json =
      JsonDecoder().convert(file.readAsStringSync()) as Map<dynamic, dynamic>;

  static dynamic jsonForTest(String test) {
    return json[test];
  }
}

// test values
const String testAppId = "35b3mbq4-7ce2-401f-9da0-2d41f287ebaf";
const String testPlayerId = "c1b395fc-3b17-4c18-aaa6-195cd3461311";
const String testEmail = "test@example.com";
const String testEmailAuthHashToken =
    "4f1916b13a164a765b42b3205b49670a40309127179cb2687ea7feae6f61ee45";

final silentNotification = OSCreateNotification.silentNotification(
    playerIds: [testPlayerId], additionalData: {'test': 'value'});

final notificationJson = OSCreateNotification(
        playerIds: [testPlayerId],
        content: 'test_content',
        additionalData: {'test': 'value'},
        languageCode: 'es',
        heading: 'test heading',
        subtitle: 'test subtitle',
        contentAvailable: true,
        mutableContent: true,
        url: 'https://www.google.com/',
        iosAttachments: {'id1': 'puppy.jpg'},
        bigPicture: 'puppy2.jpg',
        buttons: <OSActionButton>[
          OSActionButton(text: 'test_text', id: 'test_id', icon: 'test_icon')
        ],
        iosCategory: 'test_category',
        iosSound: 'ping.aiff',
        androidSound: 'ping.mp3',
        androidSmallIcon: 'puppy_small.jpg',
        androidLargeIcon: 'puppy_large.jpg',
        androidChannelId: 'test_channel_id',
        iosBadgeType: OSCreateNotificationBadgeType.increase,
        iosBadgeCount: 2,
        collapseId: 'test_collapse_id',
        sendAfter: DateTime.fromMillisecondsSinceEpoch(1532464704571,
            isUtc: true), //corresponds to 2018-07-24T20:38:24.571Z UTC00:00:00
        delayedOption: OSCreateNotificationDelayOption.lastActive,
        deliveryTimeOfDay: '9:00 AM')
    .mapRepresentation();
