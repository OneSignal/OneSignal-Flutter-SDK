import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/permission.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OSPermissionState', () {
    group('constructor', () {
      test('initializes with permission true when provided in json', () {
        final json = {'permission': true};
        final state = OSPermissionState(json);

        expect(state.permission, true);
      });

      test('defaults to false when permission key is missing', () {
        final json = <String, dynamic>{};
        final state = OSPermissionState(json);

        expect(state.permission, false);
      });
    });

    group('jsonRepresentation', () {
      test('returns json string with permission true', () {
        final json = {'permission': true};
        final state = OSPermissionState(json);
        final jsonString = state.jsonRepresentation();

        expect(jsonString, contains('"permission": true'));
      });

      test('returns properly formatted json string', () {
        final json = {'permission': true};
        final state = OSPermissionState(json);
        final jsonString = state.jsonRepresentation();

        expect(jsonString, contains('"permission": true'));
      });
    });

    group('permission field', () {
      test('can be modified after construction', () {
        final json = {'permission': false};
        final state = OSPermissionState(json);

        expect(state.permission, false);

        state.permission = true;
        expect(state.permission, true);
      });

      test('reflects changes in jsonRepresentation', () {
        final json = {'permission': false};
        final state = OSPermissionState(json);

        state.permission = true;
        final jsonString = state.jsonRepresentation();

        expect(jsonString, contains('"permission": true'));
      });
    });
  });
}
