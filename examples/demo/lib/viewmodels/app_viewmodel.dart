import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../models/in_app_message_type.dart';
import '../models/notification_type.dart';
import '../repositories/onesignal_repository.dart';
import '../services/log_manager.dart';
import '../services/preferences_service.dart';

class AppViewModel extends ChangeNotifier {
  final OneSignalRepository _repository;
  final PreferencesService _prefs;

  AppViewModel(this._repository, this._prefs);

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // SnackBar message
  String? _snackBarMessage;
  String? get snackBarMessage => _snackBarMessage;
  void clearSnackBar() {
    _snackBarMessage = null;
  }

  void _showSnackBar(String message) {
    _snackBarMessage = message;
    LogManager().i('App', message);
    notifyListeners();
  }

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

    try {
      _iamPaused = await _repository.isInAppMessagesPaused();
      _locationShared = await _repository.isLocationShared();
      _externalUserId = await _repository.getExternalId();
    } catch (e) {
      LogManager().e('App', 'Error loading initial state: $e');
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
      LogManager().e('App', 'Error fetching initial user data: $e');
    }
  }

  // Observers
  void setupObservers() {
    OneSignal.User.pushSubscription.addObserver((state) {
      _pushSubscriptionId = state.current.id;
      _pushEnabled = state.current.optedIn;
      LogManager().i('Observer', 'Push subscription changed: id=${state.current.id}, optedIn=${state.current.optedIn}');
      notifyListeners();
    });

    OneSignal.Notifications.addPermissionObserver((permission) {
      _hasNotificationPermission = permission;
      LogManager().i('Observer', 'Permission changed: $permission');
      notifyListeners();
    });

    OneSignal.User.addObserver((state) {
      LogManager().i('Observer', 'User state changed');
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
      LogManager().e('App', 'Error fetching user data: $e');
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

      _showSnackBar('Logged in as: $externalUserId');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      LogManager().e('App', 'Login error: $e');
      _showSnackBar('Login failed');
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
      _showSnackBar('Logged out');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      LogManager().e('App', 'Logout error: $e');
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
    _showSnackBar('Push ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> promptPush() async {
    final granted = await _repository.requestPermission(true);
    _hasNotificationPermission = granted;
    notifyListeners();
  }

  // Notifications
  Future<void> sendNotification(NotificationType type) async {
    final success = await _repository.sendNotification(type);
    _showSnackBar(success ? 'Notification sent: ${type.name}' : 'Failed to send notification');
  }

  Future<void> sendCustomNotification(String title, String body) async {
    final success = await _repository.sendCustomNotification(title, body);
    _showSnackBar(success ? 'Custom notification sent' : 'Failed to send notification');
  }

  // IAM
  Future<void> setIamPaused(bool paused) async {
    _iamPaused = paused;
    _repository.setInAppMessagesPaused(paused);
    await _prefs.setIamPaused(paused);
    notifyListeners();
  }

  void sendInAppMessage(InAppMessageType type) {
    _repository.addTrigger('demo_iam', type.triggerValue);
    _showSnackBar('Sent In-App Message: ${type.label}');
  }

  // Aliases
  void addAlias(String label, String id) {
    _repository.addAlias(label, id);
    _aliasesList = List.from(_aliasesList)..add(MapEntry(label, id));
    notifyListeners();
    _showSnackBar('Alias added: $label');
  }

  void addAliases(Map<String, String> aliases) {
    _repository.addAliases(aliases);
    _aliasesList = List.from(_aliasesList)
      ..addAll(aliases.entries);
    notifyListeners();
    _showSnackBar('${aliases.length} alias(es) added');
  }

  // Emails
  void addEmail(String email) {
    _repository.addEmail(email);
    _emailsList = List.from(_emailsList)..add(email);
    notifyListeners();
    _showSnackBar('Email added: $email');
  }

  void removeEmail(String email) {
    _repository.removeEmail(email);
    _emailsList = List.from(_emailsList)..remove(email);
    notifyListeners();
    _showSnackBar('Email removed: $email');
  }

  // SMS
  void addSms(String smsNumber) {
    _repository.addSms(smsNumber);
    _smsNumbersList = List.from(_smsNumbersList)..add(smsNumber);
    notifyListeners();
    _showSnackBar('SMS added: $smsNumber');
  }

  void removeSms(String smsNumber) {
    _repository.removeSms(smsNumber);
    _smsNumbersList = List.from(_smsNumbersList)..remove(smsNumber);
    notifyListeners();
    _showSnackBar('SMS removed: $smsNumber');
  }

  // Tags
  void addTag(String key, String value) {
    _repository.addTag(key, value);
    _tagsList = List.from(_tagsList)..add(MapEntry(key, value));
    notifyListeners();
    _showSnackBar('Tag added: $key');
  }

  void addTags(Map<String, String> tags) {
    _repository.addTags(tags);
    _tagsList = List.from(_tagsList)..addAll(tags.entries);
    notifyListeners();
    _showSnackBar('${tags.length} tag(s) added');
  }

  void removeTag(String key) {
    _repository.removeTag(key);
    _tagsList = List.from(_tagsList)
      ..removeWhere((e) => e.key == key);
    notifyListeners();
    _showSnackBar('Tag removed: $key');
  }

  void removeSelectedTags(List<String> keys) {
    _repository.removeTags(keys);
    _tagsList = List.from(_tagsList)
      ..removeWhere((e) => keys.contains(e.key));
    notifyListeners();
    _showSnackBar('${keys.length} tag(s) removed');
  }

  // Triggers (in-memory only)
  void addTrigger(String key, String value) {
    _repository.addTrigger(key, value);
    _triggersList = List.from(_triggersList)..add(MapEntry(key, value));
    notifyListeners();
    _showSnackBar('Trigger added: $key');
  }

  void addTriggers(Map<String, String> triggers) {
    _repository.addTriggers(triggers);
    _triggersList = List.from(_triggersList)..addAll(triggers.entries);
    notifyListeners();
    _showSnackBar('${triggers.length} trigger(s) added');
  }

  void removeTrigger(String key) {
    _repository.removeTrigger(key);
    _triggersList = List.from(_triggersList)
      ..removeWhere((e) => e.key == key);
    notifyListeners();
    _showSnackBar('Trigger removed: $key');
  }

  void removeSelectedTriggers(List<String> keys) {
    _repository.removeTriggers(keys);
    _triggersList = List.from(_triggersList)
      ..removeWhere((e) => keys.contains(e.key));
    notifyListeners();
    _showSnackBar('${keys.length} trigger(s) removed');
  }

  void clearAllTriggers() {
    _repository.clearTriggers();
    _triggersList = [];
    notifyListeners();
    _showSnackBar('All triggers cleared');
  }

  // Outcomes
  void sendOutcome(String name) {
    _repository.sendOutcome(name);
    _showSnackBar('Outcome sent: $name');
  }

  void sendUniqueOutcome(String name) {
    _repository.sendUniqueOutcome(name);
    _showSnackBar('Unique outcome sent: $name');
  }

  void sendOutcomeWithValue(String name, double value) {
    _repository.sendOutcomeWithValue(name, value);
    _showSnackBar('Outcome sent: $name = $value');
  }

  // Track Event
  void trackEvent(String name, Map<String, dynamic>? properties) {
    _repository.trackEvent(name, properties);
    _showSnackBar('Event tracked: $name');
  }

  // Location
  Future<void> setLocationShared(bool shared) async {
    _locationShared = shared;
    _repository.setLocationShared(shared);
    await _prefs.setLocationShared(shared);
    notifyListeners();
    _showSnackBar('Location sharing ${shared ? "enabled" : "disabled"}');
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
