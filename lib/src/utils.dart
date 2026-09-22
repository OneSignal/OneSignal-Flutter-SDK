import 'dart:convert';

import 'package:flutter/foundation.dart';

bool rejectNullOrEmpty(Object? value, String api) {
  if (value is String && value.isNotEmpty) return false;
  debugPrint('OneSignal: $api is required');
  return true;
}

/// An abstract class to provide JSON decoding
abstract class JSONStringRepresentable {
  String jsonRepresentation();

  String convertToJsonString(Map<String, dynamic>? object) =>
      JsonEncoder.withIndent('  ').convert(object);
}
