import 'package:test/test.dart';
import 'package:onesignal_flutter/src/subscription.dart';
import 'test_data.dart';

void main() {
  // Subscription State Tests
  // Tests both OSSubscriptionStateChanges and OSSubscriptionState model parsing
  final subscriptionStateChanges =
      TestData.jsonForTest('subscription_changed_test') as Map<String, dynamic>;
  final subscriptionChanges =
      OSSubscriptionStateChanges(subscriptionStateChanges);

  test('expect subscription correctly parses user ID', () {
    expect(subscriptionChanges.from.userId, null);
    expect(
        subscriptionChanges.to.userId, 'c1b395fc-3b17-4c18-aaa6-195cd3461311');
  });

  test('expect subscription correctly parses push token', () {
    expect(subscriptionChanges.to.pushToken,
        '07afbb0b4cb6e7ae5e81efc7fd5d35267ea9a4f12120045aebe29945e52ea30e');
    expect(
        subscriptionChanges.to.pushToken, subscriptionChanges.from.pushToken);
  });

  test('expect subscription correctly parses `subscribed`', () {
    expect(subscriptionChanges.to.subscribed,
        !subscriptionChanges.from.subscribed);
  });

  test('expect subscription correctly parses `userSubscriptionSetting`', () {
    expect(subscriptionChanges.to.userSubscriptionSetting, true);
  });

  // Email Subscription State Tests
  // Tests both OSEmailSubscriptionStateChanges and OSEmailSubscriptionState model parsing
  final emailStateChanges =
      TestData.jsonForTest('email_changed_test') as Map<String, dynamic>;
  final emailChanges = OSEmailSubscriptionStateChanges(emailStateChanges);

  test('expect subscription correctly parses email address', () {
    expect(emailChanges.from.emailAddress, null);
    expect(emailChanges.to.emailAddress, "brad@hesse.io");
  });

  test('expect subscription correctly parses `subscribed`', () {
    expect(emailChanges.from.subscribed, false);
    expect(emailChanges.to.subscribed, true);
  });

  test('expect subscription correctly parses `emailUserId`', () {
    expect(emailChanges.from.emailUserId, null);
    expect(emailChanges.to.emailUserId, "c1b395fc-3b17-4c18-aaa6-195cd3461311");
  });
}
