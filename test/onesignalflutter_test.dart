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

  test('set log level', () {
    OneSignal.Debug.setLogLevel(
      OSLogLevel.info,
    ).then(expectAsync1((v) {
      expect(channelController.state.logLevel.index, OSLogLevel.info.index);
    }));
  });
}
