import 'package:flutter_local_notif/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows both notification integrations', (tester) async {
    await tester.pumpWidget(const NotificationExampleApp());

    expect(
      find.text('OneSignal + flutter_local_notifications'),
      findsOneWidget,
    );
    expect(find.text('REQUEST PERMISSIONS'), findsOneWidget);
    expect(find.text('SCHEDULE FLUTTER LOCAL NOTIFICATION'), findsOneWidget);
    expect(find.text('SEND ONESIGNAL PUSH'), findsOneWidget);
  });
}
