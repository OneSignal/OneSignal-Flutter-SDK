import 'dart:convert';
import 'dart:io';

class TestData {
  static final file = new File('test.json');
  static final json = JsonDecoder().convert(file.readAsStringSync()) as Map<dynamic, dynamic>;

  static dynamic jsonForTest(String test) {
    return json[test];
  }
}