import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/location.dart';

import 'mock_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OneSignalLocation', () {
    late OneSignalLocation location;
    late OneSignalMockChannelController channelController;

    setUp(() {
      channelController = OneSignalMockChannelController();
      channelController.resetState();
      location = OneSignalLocation();
    });

    group('requestPermission', () {
      test('invokes OneSignal#requestPermission method', () async {
        await location.requestPermission();

        expect(channelController.state.locationPermissionRequested, true);
      });
    });

    group('setShared', () {
      test('invokes OneSignal#setShared with true', () async {
        await location.setShared(true);

        expect(channelController.state.locationShared, true);
      });

      test('handles multiple setShared calls', () async {
        await location.setShared(true);
        expect(channelController.state.locationShared, true);

        await location.setShared(false);
        expect(channelController.state.locationShared, false);

        await location.setShared(true);
        expect(channelController.state.locationShared, true);
      });
    });

    group('isShared', () {
      test('returns false when location is not shared', () async {
        final result = await location.isShared();

        expect(result, false);
      });

      test('returns correct value after toggling', () async {
        await location.setShared(true);
        var result = await location.isShared();
        expect(result, true);

        await location.setShared(false);
        result = await location.isShared();
        expect(result, false);

        await location.setShared(true);
        result = await location.isShared();
        expect(result, true);
      });
    });
  });
}
