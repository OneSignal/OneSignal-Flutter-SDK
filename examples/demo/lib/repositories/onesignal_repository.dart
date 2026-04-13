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
    await OneSignal.login(externalUserId);
  }

  Future<void> logoutUser() async {
    await OneSignal.logout();
  }

  // Alias operations
  void addAlias(String label, String id) {
    OneSignal.User.addAlias(label, id);
  }

  void addAliases(Map<String, dynamic> aliases) {
    OneSignal.User.addAliases(aliases);
  }

  // Email operations
  void addEmail(String email) {
    OneSignal.User.addEmail(email);
  }

  void removeEmail(String email) {
    OneSignal.User.removeEmail(email);
  }

  // SMS operations
  void addSms(String smsNumber) {
    OneSignal.User.addSms(smsNumber);
  }

  void removeSms(String smsNumber) {
    OneSignal.User.removeSms(smsNumber);
  }

  // Tag operations
  void addTag(String key, String value) {
    OneSignal.User.addTagWithKey(key, value);
  }

  void addTags(Map<String, dynamic> tags) {
    OneSignal.User.addTags(tags);
  }

  void removeTag(String key) {
    OneSignal.User.removeTag(key);
  }

  void removeTags(List<String> keys) {
    OneSignal.User.removeTags(keys);
  }

  Future<Map<String, String>> getTags() async {
    return await OneSignal.User.getTags();
  }

  // Trigger operations
  void addTrigger(String key, String value) {
    OneSignal.InAppMessages.addTrigger(key, value);
  }

  void addTriggers(Map<String, String> triggers) {
    OneSignal.InAppMessages.addTriggers(triggers);
  }

  void removeTrigger(String key) {
    OneSignal.InAppMessages.removeTrigger(key);
  }

  void removeTriggers(List<String> keys) {
    OneSignal.InAppMessages.removeTriggers(keys);
  }

  void clearTriggers() {
    OneSignal.InAppMessages.clearTriggers();
  }

  // Outcome operations
  void sendOutcome(String name) {
    OneSignal.Session.addOutcome(name);
  }

  void sendUniqueOutcome(String name) {
    OneSignal.Session.addUniqueOutcome(name);
  }

  void sendOutcomeWithValue(String name, double value) {
    OneSignal.Session.addOutcomeWithValue(name, value);
  }

  // Track event
  void trackEvent(String name, Map<String, dynamic>? properties) {
    OneSignal.User.trackEvent(name, properties);
  }

  // Push subscription
  String? getPushSubscriptionId() => OneSignal.User.pushSubscription.id;

  bool? isPushOptedIn() => OneSignal.User.pushSubscription.optedIn;

  void optInPush() {
    OneSignal.User.pushSubscription.optIn();
  }

  void optOutPush() {
    OneSignal.User.pushSubscription.optOut();
  }

  // Notifications
  bool hasPermission() => OneSignal.Notifications.permission;

  Future<bool> requestPermission(bool fallbackToSettings) async {
    LogManager().i('Request permission (fallback: $fallbackToSettings)');
    return await OneSignal.Notifications.requestPermission(fallbackToSettings);
  }

  void clearAllNotifications() {
    OneSignal.Notifications.clearAll();
  }

  // In-app messages
  void setInAppMessagesPaused(bool paused) {
    LogManager().i('Set IAM paused: $paused');
    OneSignal.InAppMessages.paused(paused);
  }

  Future<bool> isInAppMessagesPaused() async {
    return await OneSignal.InAppMessages.arePaused();
  }

  // Location
  void setLocationShared(bool shared) {
    OneSignal.Location.setShared(shared);
  }

  Future<bool> isLocationShared() async {
    return await OneSignal.Location.isShared();
  }

  void requestLocationPermission() {
    LogManager().i('Request location permission');
    OneSignal.Location.requestPermission();
  }

  // Live Activities
  bool hasApiKey() => _apiService.hasApiKey();

  Future<void> startDefaultLiveActivity(
    String activityId,
    Map<String, dynamic> attributes,
    Map<String, dynamic> content,
  ) async {
    await OneSignal.LiveActivities.startDefault(activityId, attributes, content);
  }

  Future<void> exitLiveActivity(String activityId) async {
    // ignore: deprecated_member_use
    await OneSignal.LiveActivities.exitLiveActivity(activityId);
  }

  Future<bool> updateLiveActivity(
    String activityId,
    Map<String, dynamic> eventUpdates,
  ) async {
    return _apiService.updateLiveActivity(activityId, eventUpdates);
  }

  Future<bool> endLiveActivity(String activityId) async {
    return _apiService.endLiveActivity(activityId);
  }

  // Privacy consent
  void setConsentRequired(bool required) {
    LogManager().i('Set consent required: $required');
    OneSignal.consentRequired(required);
  }

  void setConsentGiven(bool granted) {
    LogManager().i('Set consent given: $granted');
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
      LogManager().w('No subscription ID for notification');
      return false;
    }
    return _apiService.sendNotification(type, subscriptionId);
  }

  Future<bool> sendCustomNotification(String title, String body) async {
    final subscriptionId = getPushSubscriptionId();
    if (subscriptionId == null) {
      LogManager().w('No subscription ID for custom notification');
      return false;
    }
    return _apiService.sendCustomNotification(title, body, subscriptionId);
  }

  Future<UserData?> fetchUser(String onesignalId) async {
    return _apiService.fetchUser(onesignalId);
  }
}
