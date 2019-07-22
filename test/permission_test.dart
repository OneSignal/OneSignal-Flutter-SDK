import 'package:test/test.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'test_data.dart';

void main() {
  // Permission State tests
  final permissionStateChangesJson =
      TestData.jsonForTest("permission_parsing_test") as Map<String, dynamic>;
  final permissionStateChanges =
      OSPermissionStateChanges(permissionStateChangesJson);

  test('expect permission to parse hasPrompted correctly', () {
    expect(permissionStateChanges.from.hasPrompted, false);
    expect(permissionStateChanges.to.hasPrompted, true);
  });

  test('expect permission to parse provisional correctly', () {
    expect(permissionStateChanges.from.provisional, false);
    expect(permissionStateChanges.to.provisional, true);
  });

  test('expect permission to parse status correctly', () {
    expect(permissionStateChanges.from.status,
        OSNotificationPermission.notDetermined);
    expect(
        permissionStateChanges.to.status, OSNotificationPermission.authorized);
  });
}
