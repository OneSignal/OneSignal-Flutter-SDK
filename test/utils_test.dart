import 'package:flutter_test/flutter_test.dart';
import 'package:onesignal_flutter/src/utils.dart';

void main() {
  group('JSONStringRepresentable', () {
    test('convertToJsonString formats simple map correctly', () {
      final testObj = TestJSONStringRepresentable();
      final map = {'key': 'value', 'number': 42};

      final result = testObj.convertToJsonString(map);

      expect(result, contains('"key": "value"'));
      expect(result, contains('"number": 42'));
      expect(result, contains('\n'));
    });

    test('convertToJsonString formats nested map correctly', () {
      final testObj = TestJSONStringRepresentable();
      final map = {
        'outer': {
          'inner': 'value',
          'nested': {'deep': 'data'}
        }
      };

      final result = testObj.convertToJsonString(map);

      expect(result, contains('"outer"'));
      expect(result, contains('"inner": "value"'));
      expect(result, contains('"nested"'));
      expect(result, contains('"deep": "data"'));
    });

    test('convertToJsonString formats list correctly', () {
      final testObj = TestJSONStringRepresentable();
      final map = {
        'items': [1, 2, 3],
        'strings': ['a', 'b', 'c']
      };

      final result = testObj.convertToJsonString(map);

      expect(result, contains('"items"'));
      expect(result, contains('"strings"'));
      expect(result, contains('['));
      expect(result, contains(']'));
    });

    test('convertToJsonString handles null map', () {
      final testObj = TestJSONStringRepresentable();

      final result = testObj.convertToJsonString(null);

      expect(result, equals('null'));
    });

    test('convertToJsonString handles empty map', () {
      final testObj = TestJSONStringRepresentable();
      final map = <String, dynamic>{};

      final result = testObj.convertToJsonString(map);

      expect(result, equals('{}'));
    });

    test('convertToJsonString removes escaped newlines', () {
      final testObj = TestJSONStringRepresentable();
      final map = {'text': 'line1\nline2'};

      final result = testObj.convertToJsonString(map);

      expect(result, contains('"text": "line1\nline2"'));
    });

    test('convertToJsonString removes escaped backslashes', () {
      final testObj = TestJSONStringRepresentable();
      final map = {'path': 'folder/file'};

      final result = testObj.convertToJsonString(map);

      expect(result, contains('"path": "folder/file"'));
    });

    test('convertToJsonString formats with proper indentation', () {
      final testObj = TestJSONStringRepresentable();
      final map = {
        'level1': {'level2': 'value'}
      };

      final result = testObj.convertToJsonString(map);

      expect(result, contains('  '));
      final lines = result.split('\n');
      expect(lines.length, greaterThan(1));
    });

    test('convertToJsonString handles boolean values', () {
      final testObj = TestJSONStringRepresentable();
      final map = {'isTrue': true, 'isFalse': false};

      final result = testObj.convertToJsonString(map);

      expect(result, contains('"isTrue": true'));
      expect(result, contains('"isFalse": false'));
    });

    test('convertToJsonString handles numeric values', () {
      final testObj = TestJSONStringRepresentable();
      final map = {'integer': 42, 'double': 3.14, 'negative': -10};

      final result = testObj.convertToJsonString(map);

      expect(result, contains('42'));
      expect(result, contains('3.14'));
      expect(result, contains('-10'));
    });

    test('convertToJsonString handles mixed types', () {
      final testObj = TestJSONStringRepresentable();
      final map = {
        'string': 'text',
        'number': 123,
        'bool': true,
        'null': null,
        'list': [1, 2],
        'map': {'nested': 'value'}
      };

      final result = testObj.convertToJsonString(map);

      expect(result, contains('"string": "text"'));
      expect(result, contains('"number": 123'));
      expect(result, contains('"bool": true'));
      expect(result, contains('"null": null'));
      expect(result, contains('"list":'));
      expect(result, contains('"map":'));
      expect(result, contains('"nested": "value"'));
      expect(result, contains('{'));
      expect(result, contains('}'));
    });
  });
}

class TestJSONStringRepresentable extends JSONStringRepresentable {
  @override
  String jsonRepresentation() {
    return convertToJsonString({'test': 'data'});
  }
}
