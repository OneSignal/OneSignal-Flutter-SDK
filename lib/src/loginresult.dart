/// Profile applied to the user as part of [OneSignal.loginWithProfile].
class OSUserProfile {
  final String? email;
  final String? sms;
  final Map<String, String>? tags;
  final Map<String, String>? aliases;

  const OSUserProfile({this.email, this.sms, this.tags, this.aliases});

  Map<String, dynamic> mapRepresentation() => {
        'email': email,
        'sms': sms,
        'tags': tags,
        'aliases': aliases,
      };
}

/// The payload of a successful [OneSignal.loginWithProfile].
class OSLoginData {
  final String onesignalId;
  final String externalId;
  final String? emailSubscriptionId;
  final String? smsSubscriptionId;

  const OSLoginData({
    required this.onesignalId,
    required this.externalId,
    this.emailSubscriptionId,
    this.smsSubscriptionId,
  });
}

/// A single reason a call failed.
class OSResultError {
  /// One of BACKEND_ERROR, INVALID_ARGUMENT, NOT_INITIALIZED, STORAGE_LOCKED, UNKNOWN.
  final String code;

  /// CLIENT or BACKEND.
  final String source;
  final String? backendCode;
  final int? httpStatus;
  final String message;
  final Map<String, dynamic>? meta;

  const OSResultError({
    required this.code,
    required this.source,
    required this.message,
    this.backendCode,
    this.httpStatus,
    this.meta,
  });
}

/// The outcome of [OneSignal.loginWithProfile]: [data] on success, a non-empty [error] otherwise.
class OSLoginResult {
  final bool success;
  final OSLoginData? data;
  final List<OSResultError>? error;

  const OSLoginResult._(this.success, this.data, this.error);

  factory OSLoginResult.failure(String code, String message) => OSLoginResult._(
        false,
        null,
        [OSResultError(code: code, source: 'CLIENT', message: message)],
      );

  /// Never throws: anything that is not a well-formed envelope becomes an UNKNOWN failure.
  factory OSLoginResult.fromWire(dynamic raw) {
    if (raw is! Map) return _malformed();
    final success = raw['success'];
    if (success == true) {
      final data = _parseData(raw['data']);
      return data == null ? _malformed() : OSLoginResult._(true, data, null);
    }
    if (success != false) return _malformed();
    final error = raw['error'];
    if (error is! List || error.isEmpty) return _malformed();
    return OSLoginResult._(false, null, error.map(_parseError).toList());
  }

  static const _codes = {
    'BACKEND_ERROR',
    'INVALID_ARGUMENT',
    'NOT_INITIALIZED',
    'STORAGE_LOCKED',
    'UNKNOWN',
  };

  static OSLoginResult _malformed() =>
      OSLoginResult.failure('UNKNOWN', 'Malformed loginWithProfile result');

  static OSLoginData? _parseData(dynamic raw) {
    if (raw is! Map) return null;
    final onesignalId = _string(raw['onesignalId']);
    final externalId = _string(raw['externalId']);
    if (onesignalId == null || externalId == null) return null;
    return OSLoginData(
      onesignalId: onesignalId,
      externalId: externalId,
      emailSubscriptionId: _string(raw['emailSubscriptionId']),
      smsSubscriptionId: _string(raw['smsSubscriptionId']),
    );
  }

  static OSResultError _parseError(dynamic raw) {
    if (raw is! Map) {
      return const OSResultError(
        code: 'UNKNOWN',
        source: 'CLIENT',
        message: 'Malformed error',
      );
    }
    final code = raw['code'];
    final source = raw['source'];
    final httpStatus = raw['httpStatus'];
    final meta = raw['meta'];
    return OSResultError(
      code: _codes.contains(code) ? code as String : 'UNKNOWN',
      source: source == 'BACKEND' ? 'BACKEND' : 'CLIENT',
      backendCode: _string(raw['backendCode']),
      httpStatus: httpStatus is int ? httpStatus : null,
      message: raw['message'] is String ? raw['message'] as String : '',
      meta: meta is Map
          ? meta.map((key, value) => MapEntry(key.toString(), value))
          : null,
    );
  }

  static String? _string(dynamic value) =>
      value is String && value.isNotEmpty ? value : null;
}
