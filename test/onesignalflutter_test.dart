import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'mock_channel.dart';
import 'test_data.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  OneSignalMockChannelController channelController =
      OneSignalMockChannelController();
  OneSignal onesignal = OneSignal();

  setUp(() {
    channelController.resetState();
  });

  test('verify initialization without iOS Settings', () {
    onesignal.setAppId(testAppId).then(expectAsync1((v) {
      expect(channelController.state.appId, testAppId);
    }));
  });

  test('set set log level', () {
    onesignal
        .setLogLevel(OSLogLevel.info, OSLogLevel.warn)
        .then(expectAsync1((v) {
      expect(channelController.state.logLevel.index, OSLogLevel.info.index);
      expect(channelController.state.visualLevel.index, OSLogLevel.warn.index);
    }));
  });

  test('grant consent', () {
    onesignal.consentGranted(true).then(expectAsync1((v) {
      expect(channelController.state.consentGranted, true);
    }));
  });

  test('prompt permission', () {
    onesignal.promptUserForPushNotificationPermission().then(expectAsync1((v) {
      expect(channelController.state.calledPromptPermission, true);
    }));
  });

  test('disable push', () {
    onesignal.disablePush(true).then(expectAsync1((v) {
      expect(channelController.state.disablePush, true);
    }));
  });

  test('post notification', () {
    onesignal.postNotificationWithJson({
      "content_available": true,
      "include_player_ids": [testPlayerId]
    }).then(expectAsync1((v) {
      expect(channelController.state.postNotificationJson!['content_available'],
          true);
      expect(channelController.state.postNotificationJson!['include_player_ids'],
          [testPlayerId]);
    }));
  });

  test('setting location shared', () {
    onesignal.setLocationShared(true).then(expectAsync1((v) {
      expect(channelController.state.locationShared, true);
    }));
  });

  test('setting email without authentication', () {
    onesignal.setEmail(email: testEmail).then(expectAsync1((v) {
      expect(channelController.state.email, testEmail);
      expect(channelController.state.emailAuthHashToken, null);
    }));
  });

  test('setting email with authentication', () {
    onesignal
        .setEmail(email: testEmail, emailAuthHashToken: testEmailAuthHashToken)
        .then(expectAsync1((v) {
      expect(channelController.state.email, testEmail);
      expect(
          channelController.state.emailAuthHashToken, testEmailAuthHashToken);
    }));
  });

  // Tags tests
  test('setting tags', () {
    var sendTags = {'test': 'value'};

    onesignal.sendTags(sendTags).then(expectAsync1((v) {
      expect(channelController.state.tags, sendTags);
    }));
  });

  test('deleting tags', () {
    onesignal.deleteTag('test1').then(expectAsync1((v) {
      expect(channelController.state.deleteTags, ['test1']);
    }));
  });

  test('setting external user ID', () {
    onesignal.setExternalUserId('test_ext_id').then(expectAsync1((v) {
      expect(channelController.state.externalId, 'test_ext_id');
    }));
  });

  test('removing external user ID', () {
    onesignal.removeExternalUserId().then(expectAsync1((v) {
      expect(channelController.state.externalId, null);
    }));
  });

  //Set Language test
  test('setting language', () {
    onesignal.setLanguage('fr').then(expectAsync1((v) {
      expect(channelController.state.language, 'fr');
    }));
  });
}
