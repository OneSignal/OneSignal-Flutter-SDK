import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OneSignalLocation', () {
    late OneSignalLocation location;
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      location = OneSignalLocation();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('OneSignal#location'),
        (call) async {
          methodCalls.add(call);
          if (call.method == 'OneSignal#isShared') {
            return false;
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('OneSignal#location'),
        null,
      );
    });

    group('requestPermission', () {
      test('invokes OneSignal#requestPermission method', () async {
        await location.requestPermission();

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#requestPermission');
      });
    });

    group('setShared', () {
      test('invokes OneSignal#setShared', () async {
        await location.setShared(true);

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#setShared');
        expect(methodCalls[0].arguments, true);
      });
    });

    group('isShared', () {
      test('invokes OneSignal#isShared method', () async {
        final result = await location.isShared();

        expect(methodCalls.length, 1);
        expect(methodCalls[0].method, 'OneSignal#isShared');
        expect(result, false);
      });

      test('returns correct value from native', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('OneSignal#location'),
          (call) async {
            if (call.method == 'OneSignal#isShared') {
              return true;
            }
            return null;
          },
        );

        final result = await location.isShared();

        expect(result, true);
      });

      test('returns false when location is not shared', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('OneSignal#location'),
          (call) async {
            if (call.method == 'OneSignal#isShared') {
              return false;
            }
            return null;
          },
        );

        final result = await location.isShared();

        expect(result, false);
      });
    });
  });
}
