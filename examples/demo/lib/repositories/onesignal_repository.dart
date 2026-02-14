import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../models/notification_type.dart';
import '../models/user_data.dart';
import '../services/log_manager.dart';
import '../services/onesignal_api_service.dart';

class OneSignalRepository {
  final OneSignalApiService _apiService;

  OneSignalRepository(this._apiService);

  // User operations
  Future<void> loginUser(String externalUserId) async {
    LogManager().i('SDK', 'Login user: $externalUserId');
    await OneSignal.login(externalUserId);
  }

  Future<void> logoutUser() async {
    LogManager().i('SDK', 'Logout user');
    await OneSignal.logout();
  }

  // Alias operations
  void addAlias(String label, String id) {
    LogManager().i('SDK', 'Add alias: $label = $id');
    OneSignal.User.addAlias(label, id);
  }

  void addAliases(Map<String, dynamic> aliases) {
    LogManager().i('SDK', 'Add aliases: $aliases');
    OneSignal.User.addAliases(aliases);
  }

  // Email operations
  void addEmail(String email) {
    LogManager().i('SDK', 'Add email: $email');
    OneSignal.User.addEmail(email);
  }

  void removeEmail(String email) {
    LogManager().i('SDK', 'Remove email: $email');
    OneSignal.User.removeEmail(email);
  }

  // SMS operations
  void addSms(String smsNumber) {
    LogManager().i('SDK', 'Add SMS: $smsNumber');
    OneSignal.User.addSms(smsNumber);
  }

  void removeSms(String smsNumber) {
    LogManager().i('SDK', 'Remove SMS: $smsNumber');
    OneSignal.User.removeSms(smsNumber);
  }

  // Tag operations
  void addTag(String key, String value) {
    LogManager().i('SDK', 'Add tag: $key = $value');
    OneSignal.User.addTagWithKey(key, value);
  }

  void addTags(Map<String, dynamic> tags) {
    LogManager().i('SDK', 'Add tags: $tags');
    OneSignal.User.addTags(tags);
  }

  void removeTag(String key) {
    LogManager().i('SDK', 'Remove tag: $key');
    OneSignal.User.removeTag(key);
  }

  void removeTags(List<String> keys) {
    LogManager().i('SDK', 'Remove tags: $keys');
    OneSignal.User.removeTags(keys);
  }

  Future<Map<String, String>> getTags() async {
    return await OneSignal.User.getTags();
  }

  // Trigger operations
  void addTrigger(String key, String value) {
    LogManager().i('SDK', 'Add trigger: $key = $value');
    OneSignal.InAppMessages.addTrigger(key, value);
  }

  void addTriggers(Map<String, String> triggers) {
    LogManager().i('SDK', 'Add triggers: $triggers');
    OneSignal.InAppMessages.addTriggers(triggers);
  }

  void removeTrigger(String key) {
    LogManager().i('SDK', 'Remove trigger: $key');
    OneSignal.InAppMessages.removeTrigger(key);
  }

  void removeTriggers(List<String> keys) {
    LogManager().i('SDK', 'Remove triggers: $keys');
    OneSignal.InAppMessages.removeTriggers(keys);
  }

  void clearTriggers() {
    LogManager().i('SDK', 'Clear all triggers');
    OneSignal.InAppMessages.clearTriggers();
  }

  // Outcome operations
  void sendOutcome(String name) {
    LogManager().i('SDK', 'Send outcome: $name');
    OneSignal.Session.addOutcome(name);
  }

  void sendUniqueOutcome(String name) {
    LogManager().i('SDK', 'Send unique outcome: $name');
    OneSignal.Session.addUniqueOutcome(name);
  }

  void sendOutcomeWithValue(String name, double value) {
    LogManager().i('SDK', 'Send outcome with value: $name = $value');
    OneSignal.Session.addOutcomeWithValue(name, value);
  }

  // Track event
  void trackEvent(String name, Map<String, dynamic>? properties) {
    LogManager().i('SDK', 'Track event: $name, properties: $properties');
    OneSignal.User.trackEvent(name, properties);
  }

  // Push subscription
  String? getPushSubscriptionId() => OneSignal.User.pushSubscription.id;

  bool? isPushOptedIn() => OneSignal.User.pushSubscription.optedIn;

  void optInPush() {
    LogManager().i('SDK', 'Opt in push');
    OneSignal.User.pushSubscription.optIn();
  }

  void optOutPush() {
    LogManager().i('SDK', 'Opt out push');
    OneSignal.User.pushSubscription.optOut();
  }

  // Notifications
  bool hasPermission() => OneSignal.Notifications.permission;

  Future<bool> requestPermission(bool fallbackToSettings) async {
    LogManager().i('SDK', 'Request permission (fallback: $fallbackToSettings)');
    return await OneSignal.Notifications.requestPermission(fallbackToSettings);
  }

  // In-app messages
  void setInAppMessagesPaused(bool paused) {
    LogManager().i('SDK', 'Set IAM paused: $paused');
    OneSignal.InAppMessages.paused(paused);
  }

  Future<bool> isInAppMessagesPaused() async {
    return await OneSignal.InAppMessages.arePaused();
  }

  // Location
  void setLocationShared(bool shared) {
    LogManager().i('SDK', 'Set location shared: $shared');
    OneSignal.Location.setShared(shared);
  }

  Future<bool> isLocationShared() async {
    return await OneSignal.Location.isShared();
  }

  void requestLocationPermission() {
    LogManager().i('SDK', 'Request location permission');
    OneSignal.Location.requestPermission();
  }

  // Privacy consent
  void setConsentRequired(bool required) {
    LogManager().i('SDK', 'Set consent required: $required');
    OneSignal.consentRequired(required);
  }

  void setConsentGiven(bool granted) {
    LogManager().i('SDK', 'Set consent given: $granted');
    OneSignal.consentGiven(granted);
  }

  // User IDs
  Future<String?> getExternalId() async {
    return await OneSignal.User.getExternalId();
  }

  Future<String?> getOnesignalId() async {
    return await OneSignal.User.getOnesignalId();
  }

  // REST API calls
  Future<bool> sendNotification(NotificationType type) async {
    final subscriptionId = getPushSubscriptionId();
    if (subscriptionId == null) {
      LogManager().w('SDK', 'No subscription ID for notification');
      return false;
    }
    return _apiService.sendNotification(type, subscriptionId);
  }

  Future<bool> sendCustomNotification(String title, String body) async {
    final subscriptionId = getPushSubscriptionId();
    if (subscriptionId == null) {
      LogManager().w('SDK', 'No subscription ID for custom notification');
      return false;
    }
    return _apiService.sendCustomNotification(title, body, subscriptionId);
  }

  Future<UserData?> fetchUser(String onesignalId) async {
    return _apiService.fetchUser(onesignalId);
  }
}
