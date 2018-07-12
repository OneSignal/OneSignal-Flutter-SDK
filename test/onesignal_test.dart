import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:onesignal/onesignal.dart'

void main() {
  OneSignal onesignal;

  setUp() {
    onesignal = OneSignal();
    onesignal.init("test_app_id", <String, dynamic>{});
  }
  
  test('initializes OneSignal correctly', () {
    
  });
}