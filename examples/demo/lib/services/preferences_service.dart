import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyAppId = 'app_id';
  static const _keyConsentRequired = 'consent_required';
  static const _keyPrivacyConsent = 'privacy_consent';
  static const _keyExternalUserId = 'external_user_id';
  static const _keyLocationShared = 'location_shared';
  static const _keyIamPaused = 'iam_paused';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // App ID
  String? get appId => _prefs.getString(_keyAppId);
  Future<void> setAppId(String value) => _prefs.setString(_keyAppId, value);

  // Consent required
  bool get consentRequired => _prefs.getBool(_keyConsentRequired) ?? false;
  Future<void> setConsentRequired(bool value) =>
      _prefs.setBool(_keyConsentRequired, value);

  // Privacy consent
  bool get privacyConsent => _prefs.getBool(_keyPrivacyConsent) ?? false;
  Future<void> setPrivacyConsent(bool value) =>
      _prefs.setBool(_keyPrivacyConsent, value);

  // External user ID
  String? get externalUserId => _prefs.getString(_keyExternalUserId);
  Future<void> setExternalUserId(String? value) {
    if (value == null) return _prefs.remove(_keyExternalUserId);
    return _prefs.setString(_keyExternalUserId, value);
  }

  // Location shared
  bool get locationShared => _prefs.getBool(_keyLocationShared) ?? false;
  Future<void> setLocationShared(bool value) =>
      _prefs.setBool(_keyLocationShared, value);

  // In-app messaging paused
  bool get iamPaused => _prefs.getBool(_keyIamPaused) ?? false;
  Future<void> setIamPaused(bool value) =>
      _prefs.setBool(_keyIamPaused, value);
}
