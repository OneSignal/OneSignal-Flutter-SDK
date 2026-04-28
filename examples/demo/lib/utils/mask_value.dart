import 'package:flutter_dotenv/flutter_dotenv.dart';

const String _maskChar = '\u2022';
final bool _isE2E = dotenv.env['E2E_MODE'] == 'true';

/// Replaces [value] with a mask of equal length when running in E2E mode so
/// real app/push IDs don't leak into screenshots or Appium element captures.
/// Returns [value] unchanged otherwise.
String maskValue(String value) {
  if (_isE2E) {
    return _maskChar * value.length;
  }
  return value;
}
