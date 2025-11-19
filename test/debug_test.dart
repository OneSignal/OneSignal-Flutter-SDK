import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'mock_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  OneSignalMockChannelController channelController =
      OneSignalMockChannelController();

  setUp(() {
    channelController.resetState();
  });

  group('OneSignalDebug', () {
    group('setLogLevel', () {
      for (final logLevel in OSLogLevel.values) {
        test('sets log level to ${logLevel.toString().split('.').last}',
            () async {
          await OneSignal.Debug.setLogLevel(logLevel);
          expect(channelController.state.logLevel, logLevel);
        });
      }
    });

    group('setAlertLevel', () {
      for (final logLevel in OSLogLevel.values) {
        test('sets alert level to ${logLevel.toString().split('.').last}',
            () async {
          await OneSignal.Debug.setAlertLevel(logLevel);
          expect(channelController.state.visualLevel, logLevel);
        });
      }
    });
  });
}
