import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../models/in_app_message_type.dart';
import '../models/notification_type.dart';
import '../repositories/onesignal_repository.dart';
import '../services/preferences_service.dart';

class AppViewModel extends ChangeNotifier {
  final OneSignalRepository _repository;
  final PreferencesService _prefs;

  AppViewModel(this._repository, this._prefs);

  static const _orderStatuses = [
    {
      'status': 'preparing',
      'message': 'Your order is being prepared',
      'estimatedTime': '15 min',
    },
    {
      'status': 'on_the_way',
      'message': 'Driver is heading your way',
      'estimatedTime': '10 min',
    },
    {
      'status': 'delivered',
      'message': 'Order delivered!',
      'estimatedTime': '',
    },
  ];

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // App state
  String _appId = '';
  String get appId => _appId;

  bool _consentRequired = false;
  bool get consentRequired => _consentRequired;

  bool _privacyConsentGiven = false;
  bool get privacyConsentGiven => _privacyConsentGiven;

  String? _externalUserId;
  String? get externalUserId => _externalUserId;

  bool get isLoggedIn => _externalUserId != null;

  // Push state
  String? _pushSubscriptionId;
  String? get pushSubscriptionId => _pushSubscriptionId;

  bool _pushEnabled = false;
  bool get pushEnabled => _pushEnabled;

  bool _hasNotificationPermission = false;
  bool get hasNotificationPermission => _hasNotificationPermission;

  // IAM state
  bool _iamPaused = false;
  bool get iamPaused => _iamPaused;

  // Location state
  bool _locationShared = false;
  bool get locationShared => _locationShared;

  // Live Activity state
  String _activityId = 'order-1';
  String get activityId => _activityId;

  String _orderNumber = 'ORD-1234';
  String get orderNumber => _orderNumber;

  int _statusIndex = 0;

  bool _isLaUpdating = false;
  bool get isLaUpdating => _isLaUpdating;

  bool get hasApiKey => _repository.hasApiKey();

  String get nextStatusLabel {
    final nextIndex = (_statusIndex + 1) % _orderStatuses.length;
    final status = _orderStatuses[nextIndex]['status']!;
    return status.toUpperCase().replaceAll('_', ' ');
  }

  // Data lists
  List<MapEntry<String, String>> _aliasesList = [];
  List<MapEntry<String, String>> get aliasesList =>
      List.unmodifiable(_aliasesList);

  List<String> _emailsList = [];
  List<String> get emailsList => List.unmodifiable(_emailsList);

  List<String> _smsNumbersList = [];
  List<String> get smsNumbersList => List.unmodifiable(_smsNumbersList);

  List<MapEntry<String, String>> _tagsList = [];
  List<MapEntry<String, String>> get tagsList => List.unmodifiable(_tagsList);

  List<MapEntry<String, String>> _triggersList = [];
  List<MapEntry<String, String>> get triggersList =>
      List.unmodifiable(_triggersList);

  // Initialize
  Future<void> loadInitialState(String appId) async {
    _appId = appId;

    _consentRequired = _prefs.consentRequired;
    _privacyConsentGiven = _prefs.privacyConsent;
    _externalUserId = _prefs.externalUserId;

    _iamPaused = _prefs.iamPaused;
    _locationShared = _prefs.locationShared;

    if (_externalUserId != null) {
      _repository.loginUser(_externalUserId!);
    }

    _pushSubscriptionId = _repository.getPushSubscriptionId();
    _pushEnabled = _repository.isPushOptedIn() ?? false;
    _hasNotificationPermission = _repository.hasPermission();

    notifyListeners();

    // Fetch user data if we have a OneSignal ID
    try {
      final onesignalId = await _repository.getOnesignalId();
      if (onesignalId != null) {
        _isLoading = true;
        notifyListeners();
        await fetchUserDataFromApi();
        await Future.delayed(const Duration(milliseconds: 100));
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching initial user data: $e');
    }
  }

  // Observers
  void setupObservers() {
    OneSignal.User.pushSubscription.addObserver((state) {
      _pushSubscriptionId = state.current.id;
      _pushEnabled = state.current.optedIn;
      debugPrint(
        'Push subscription changed: id=${state.current.id}, optedIn=${state.current.optedIn}',
      );
      notifyListeners();
    });

    OneSignal.Notifications.addPermissionObserver((permission) {
      _hasNotificationPermission = permission;
      debugPrint('Permission changed: $permission');
      notifyListeners();
    });

    OneSignal.User.addObserver((state) {
      debugPrint('User state changed');
      fetchUserDataFromApi();
    });
  }

  // Fetch user data from API
  Future<void> fetchUserDataFromApi() async {
    try {
      final onesignalId = await _repository.getOnesignalId();
      if (onesignalId == null) return;

      final userData = await _repository.fetchUser(onesignalId);
      if (userData != null) {
        _aliasesList = userData.aliases.entries.toList();
        _tagsList = userData.tags.entries.toList();
        _emailsList = List.from(userData.emails);
        _smsNumbersList = List.from(userData.smsNumbers);

        if (userData.externalId != null) {
          _externalUserId = userData.externalId;
          await _prefs.setExternalUserId(userData.externalId);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // Login / Logout
  Future<void> loginUser(String externalUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _aliasesList = [];
      _emailsList = [];
      _smsNumbersList = [];
      _tagsList = [];
      _triggersList = [];

      await _repository.loginUser(externalUserId);
      _externalUserId = externalUserId;
      await _prefs.setExternalUserId(externalUserId);

      _isLoading = false;
      notifyListeners();
      debugPrint('Logged in as: $externalUserId');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e');
    }
  }

  Future<void> logoutUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logoutUser();
      _externalUserId = null;
      _aliasesList = [];
      _emailsList = [];
      _smsNumbersList = [];
      _tagsList = [];
      _triggersList = [];
      await _prefs.setExternalUserId(null);

      _isLoading = false;
      notifyListeners();
      debugPrint('Logged out');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Logout error: $e');
    }
  }

  // Consent
  Future<void> setConsentRequired(bool value) async {
    _consentRequired = value;
    _repository.setConsentRequired(value);
    await _prefs.setConsentRequired(value);
    if (!value) {
      _privacyConsentGiven = false;
      await _prefs.setPrivacyConsent(false);
    }
    notifyListeners();
  }

  Future<void> setPrivacyConsent(bool value) async {
    _privacyConsentGiven = value;
    _repository.setConsentGiven(value);
    await _prefs.setPrivacyConsent(value);
    notifyListeners();
  }

  // Push
  void togglePush(bool enabled) {
    if (enabled) {
      _repository.optInPush();
    } else {
      _repository.optOutPush();
    }
    _pushEnabled = enabled;
    notifyListeners();
    debugPrint('Push ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> promptPush() async {
    final granted = await _repository.requestPermission(true);
    _hasNotificationPermission = granted;
    notifyListeners();
  }

  // Notifications
  Future<void> sendNotification(NotificationType type) async {
    final success = await _repository.sendNotification(type);
    if (success) {
      debugPrint('Notification sent: ${type.name}');
    } else {
      debugPrint('Failed to send notification');
    }
  }

  Future<void> sendCustomNotification(String title, String body) async {
    final success = await _repository.sendCustomNotification(title, body);
    if (success) {
      debugPrint('Custom notification sent');
    } else {
      debugPrint('Failed to send notification');
    }
  }

  void clearAllNotifications() {
    _repository.clearAllNotifications();
    debugPrint('All notifications cleared');
  }

  // IAM
  Future<void> setIamPaused(bool paused) async {
    _iamPaused = paused;
    _repository.setInAppMessagesPaused(paused);
    await _prefs.setIamPaused(paused);
    notifyListeners();
  }

  void sendInAppMessage(InAppMessageType type) {
    _repository.addTrigger('iam_type', type.triggerValue);
    _triggersList = List.from(_triggersList)
      ..removeWhere((e) => e.key == 'iam_type')
      ..add(MapEntry('iam_type', type.triggerValue));
    notifyListeners();
    debugPrint('Sent In-App Message: ${type.label}');
  }

  // Aliases
  void addAlias(String label, String id) {
    _repository.addAlias(label, id);
    _aliasesList = List.from(_aliasesList)..add(MapEntry(label, id));
    notifyListeners();
    debugPrint('Alias added: $label');
  }

  void addAliases(Map<String, String> aliases) {
    _repository.addAliases(aliases);
    _aliasesList = List.from(_aliasesList)..addAll(aliases.entries);
    notifyListeners();
    debugPrint('${aliases.length} alias(es) added');
  }

  // Emails
  void addEmail(String email) {
    _repository.addEmail(email);
    _emailsList = List.from(_emailsList)..add(email);
    notifyListeners();
    debugPrint('Email added: $email');
  }

  void removeEmail(String email) {
    _repository.removeEmail(email);
    _emailsList = List.from(_emailsList)..remove(email);
    notifyListeners();
    debugPrint('Email removed: $email');
  }

  // SMS
  void addSms(String smsNumber) {
    _repository.addSms(smsNumber);
    _smsNumbersList = List.from(_smsNumbersList)..add(smsNumber);
    notifyListeners();
    debugPrint('SMS added: $smsNumber');
  }

  void removeSms(String smsNumber) {
    _repository.removeSms(smsNumber);
    _smsNumbersList = List.from(_smsNumbersList)..remove(smsNumber);
    notifyListeners();
    debugPrint('SMS removed: $smsNumber');
  }

  // Tags
  void addTag(String key, String value) {
    _repository.addTag(key, value);
    _tagsList = List.from(_tagsList)..add(MapEntry(key, value));
    notifyListeners();
    debugPrint('Tag added: $key');
  }

  void addTags(Map<String, String> tags) {
    _repository.addTags(tags);
    _tagsList = List.from(_tagsList)..addAll(tags.entries);
    notifyListeners();
    debugPrint('${tags.length} tag(s) added');
  }

  void removeTag(String key) {
    _repository.removeTag(key);
    _tagsList = List.from(_tagsList)..removeWhere((e) => e.key == key);
    notifyListeners();
    debugPrint('Tag removed: $key');
  }

  void removeSelectedTags(List<String> keys) {
    _repository.removeTags(keys);
    _tagsList = List.from(_tagsList)..removeWhere((e) => keys.contains(e.key));
    notifyListeners();
    debugPrint('${keys.length} tag(s) removed');
  }

  // Triggers (in-memory only)
  void addTrigger(String key, String value) {
    _repository.addTrigger(key, value);
    _triggersList = List.from(_triggersList)..add(MapEntry(key, value));
    notifyListeners();
    debugPrint('Trigger added: $key');
  }

  void addTriggers(Map<String, String> triggers) {
    _repository.addTriggers(triggers);
    _triggersList = List.from(_triggersList)..addAll(triggers.entries);
    notifyListeners();
    debugPrint('${triggers.length} trigger(s) added');
  }

  void removeTrigger(String key) {
    _repository.removeTrigger(key);
    _triggersList = List.from(_triggersList)..removeWhere((e) => e.key == key);
    notifyListeners();
    debugPrint('Trigger removed: $key');
  }

  void removeSelectedTriggers(List<String> keys) {
    _repository.removeTriggers(keys);
    _triggersList = List.from(_triggersList)
      ..removeWhere((e) => keys.contains(e.key));
    notifyListeners();
    debugPrint('${keys.length} trigger(s) removed');
  }

  void clearAllTriggers() {
    _repository.clearTriggers();
    _triggersList = [];
    notifyListeners();
    debugPrint('All triggers cleared');
  }

  // Outcomes
  void sendOutcome(String name) {
    _repository.sendOutcome(name);
    debugPrint('Outcome sent: $name');
  }

  void sendUniqueOutcome(String name) {
    _repository.sendUniqueOutcome(name);
    debugPrint('Unique outcome sent: $name');
  }

  void sendOutcomeWithValue(String name, double value) {
    _repository.sendOutcomeWithValue(name, value);
    debugPrint('Outcome sent: $name = $value');
  }

  // Custom Events
  void trackEvent(String name, Map<String, dynamic>? properties) {
    _repository.trackEvent(name, properties);
    debugPrint('Event tracked: $name');
  }

  // Live Activities
  void setActivityId(String id) {
    _activityId = id;
    notifyListeners();
  }

  void setOrderNumber(String number) {
    _orderNumber = number;
    notifyListeners();
  }

  Future<void> startLiveActivity() async {
    final attributes = {'orderNumber': _orderNumber};
    final content = Map<String, dynamic>.from(_orderStatuses[0]);
    _statusIndex = 0;
    await _repository.startDefaultLiveActivity(_activityId, attributes, content);
    notifyListeners();
    debugPrint('Started Live Activity: $_activityId');
  }

  Future<void> updateLiveActivity() async {
    _isLaUpdating = true;
    notifyListeners();

    final nextIndex = (_statusIndex + 1) % _orderStatuses.length;
    final content = Map<String, dynamic>.from(_orderStatuses[nextIndex]);
    final eventUpdates = {'data': content};
    final success =
        await _repository.updateLiveActivity(_activityId, eventUpdates);

    _isLaUpdating = false;
    if (success) {
      _statusIndex = nextIndex;
      debugPrint('Updated Live Activity: $_activityId');
    } else {
      debugPrint('Failed to update Live Activity');
    }
    notifyListeners();
  }

  Future<void> exitLiveActivity() async {
    await _repository.exitLiveActivity(_activityId);
    debugPrint('Exited Live Activity: $_activityId');
  }

  Future<void> endLiveActivity() async {
    final success = await _repository.endLiveActivity(_activityId);
    if (success) {
      _statusIndex = 0;
      debugPrint('Ended Live Activity: $_activityId');
    } else {
      debugPrint('Failed to end Live Activity');
    }
    notifyListeners();
  }

  // Location
  Future<void> setLocationShared(bool shared) async {
    _locationShared = shared;
    _repository.setLocationShared(shared);
    await _prefs.setLocationShared(shared);
    notifyListeners();
    debugPrint('Location sharing ${shared ? "enabled" : "disabled"}');
  }

  void promptLocation() {
    _repository.requestLocationPermission();
  }

  // Dismiss loading (called from user state change observer)
  void dismissLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
