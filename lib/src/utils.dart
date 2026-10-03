import 'dart:convert';

import 'package:flutter/foundation.dart';

void logError(String message) => debugPrint('[OneSignal] $message');

bool isMissing(Object? value, String api) {
  if (value is String && value.isNotEmpty) return false;
  logError('$api is required');
  return true;
}

/// An abstract class to provide JSON decoding
abstract class JSONStringRepresentable {
  String jsonRepresentation();

  String convertToJsonString(Map<String, dynamic>? object) =>
      JsonEncoder.withIndent('  ').convert(object);
}
