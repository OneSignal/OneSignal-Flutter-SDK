import 'package:flutter_local_notif/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows both notification integrations', (tester) async {
    await tester.pumpWidget(const NotificationExampleApp());

    expect(find.text('OneSignal + Local Notifications'), findsOneWidget);
    expect(find.text('Request notification permission'), findsOneWidget);
    expect(find.text('Show local notification'), findsOneWidget);
  });
}
