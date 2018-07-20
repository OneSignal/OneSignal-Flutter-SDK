import 'package:test/test.dart';
import 'package:OneSignalFlutter/onesignal.dart';
import 'mock_channel.dart';

void main() {
  OneSignalMockChannelController channelController = OneSignalMockChannelController();
  OneSignal onesignal = OneSignal();

  // test values 
  const String testAppId = "35b3mbq4-7ce2-401f-9da0-2d41f287ebaf";
  const String testPlayerId = "c1b395fc-3b17-4c18-aaa6-195cd3461311";
  const String testEmail = "test@example.com";
  const String testEmailAuthHashToken = "4f1916b13a164a765b42b3205b49670a40309127179cb2687ea7feae6f61ee45";

  setUp(() {
    channelController.resetState();
  });

  test ('verify initialization', () {
    onesignal.init(testAppId, iOSSettings: {OSiOSSettings.autoPrompt : true}).then(expectAsync1((v) {
      expect(channelController.state.appId, testAppId);
      expect(channelController.state.iosSettings['kOSSettingsKeyAutoPrompt'], true);
    }));
  });

  test ('set set log level', () {
    onesignal.setLogLevel(OSLogLevel.info, OSLogLevel.warn).then(expectAsync1((v) {
      expect(channelController.state.logLevel.index, OSLogLevel.info.index);
      expect(channelController.state.visualLevel.index, OSLogLevel.warn.index);
    }));
  });

  test ('grant consent', () {
    onesignal.consentGranted(true).then(expectAsync1((v) {
      expect(channelController.state.consentGranted, true);
    }));
  });

  test ('prompt permission', () {
    onesignal.promptUserForPushNotificationPermission().then(expectAsync1((v) {
      expect(channelController.state.calledPromptPermission, true);
    }));
  });

  test ('set display type', () {
    onesignal.setInFocusDisplayType(OSNotificationDisplayType.notification).then(expectAsync1((v) {
      expect(channelController.state.inFocusDisplayType.index, OSNotificationDisplayType.notification.index);
    }));
  });

  test ('set subscription', () {
    onesignal.setSubscription(true).then(expectAsync1((v) {
      expect(channelController.state.subscriptionState, true);
    }));
  });

  test ('post notification', () {
    onesignal.postNotification({"content_available" : true, "include_player_ids" : [testPlayerId]}).then(expectAsync1((v) {
      expect(channelController.state.postNotificationJson['content_available'], true);
      expect(channelController.state.postNotificationJson['include_player_ids'], [testPlayerId]);
    }));
  });

  test ('setting location shared', () {
    onesignal.setLocationShared(true).then(expectAsync1((v) {
      expect(channelController.state.locationShared, true);
    }));
  });

  test ('setting email without authentication', () {
    onesignal.setEmail(email: testEmail).then(expectAsync1((v) {
      expect(channelController.state.email, testEmail);
      expect(channelController.state.emailAuthHashToken, null);
    }));
  });

  test ('setting email with authentication', () {
    onesignal.setEmail(email: testEmail, emailAuthHashToken: testEmailAuthHashToken).then(expectAsync1((v) {
      expect(channelController.state.email, testEmail);
      expect(channelController.state.emailAuthHashToken, testEmailAuthHashToken);
    }));
  });

  // Tags tests
  test ('setting tags', () {
    var sendTags = {'test' : 'value'};

    onesignal.sendTags(sendTags).then(expectAsync1((v) {
      expect(channelController.state.tags, sendTags);
    }));
  });

  test ('deleting tags', () {
    onesignal.deleteTag('test1').then(expectAsync1((v) {
      expect(channelController.state.deleteTags, ['test1']);
    }));
  });
}