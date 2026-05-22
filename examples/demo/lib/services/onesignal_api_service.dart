import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/notification_type.dart';
import '../models/user_data.dart';

const String _defaultAndroidChannelId = 'b3b015d9-c050-4042-8548-dcc34aa44aa4';

String _resolveAndroidChannelId() {
  String? envValue;
  try {
    envValue = dotenv.env['ONESIGNAL_ANDROID_CHANNEL_ID']?.trim();
  } catch (_) {
    envValue = null;
  }
  return (envValue != null && envValue.isNotEmpty)
      ? envValue
      : _defaultAndroidChannelId;
}

class OneSignalApiService {
  String _appId = '';
  String _apiKey = '';

  void setAppId(String appId) => _appId = appId;
  String get appId => _appId;

  void setApiKey(String apiKey) => _apiKey = apiKey;
  bool hasApiKey() => _apiKey.isNotEmpty && _apiKey != 'your_rest_api_key';

  Future<bool> sendNotification(
    NotificationType type,
    String subscriptionId,
  ) async {
    final body = <String, dynamic>{
      'app_id': _appId,
      'include_subscription_ids': [subscriptionId],
      'headings': {'en': type.title},
      'contents': {'en': type.body},
    };
    if (type.bigPicture != null) {
      body['big_picture'] = type.bigPicture;
    }
    if (type.iosAttachments != null) {
      body['ios_attachments'] = type.iosAttachments;
    }
    if (type.iosSound != null) {
      body['ios_sound'] = type.iosSound;
    }
    if (type.useAndroidChannel) {
      body['android_channel_id'] = _resolveAndroidChannelId();
    }

    return _postNotification(body);
  }

  Future<bool> sendCustomNotification(
    String title,
    String body,
    String subscriptionId,
  ) async {
    final payload = <String, dynamic>{
      'app_id': _appId,
      'include_subscription_ids': [subscriptionId],
      'headings': {'en': title},
      'contents': {'en': body},
    };

    return _postNotification(payload);
  }

  Future<bool> _postNotification(Map<String, dynamic> payload) async {
    const maxAttempts = 5;
    int backoffMs(int n) => 2000 * (1 << (n - 1));

    // Retry on `invalid_player_ids` to absorb the brief race where the
    // subscription has been created locally but is not yet visible to the
    // /notifications endpoint.
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http.post(
          Uri.parse('https://onesignal.com/api/v1/notifications'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/vnd.onesignal.v1+json',
          },
          body: jsonEncode(payload),
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          debugPrint('Send notification failed: ${response.body}');
          return false;
        }

        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final errors = decoded['errors'];
          if (errors is Map<String, dynamic>) {
            final invalidIds = errors['invalid_player_ids'];
            if (invalidIds is List && invalidIds.isNotEmpty) {
              if (attempt < maxAttempts) {
                await Future<void>.delayed(
                  Duration(milliseconds: backoffMs(attempt)),
                );
                continue;
              }
              debugPrint(
                'Send notification failed: invalid_player_ids $invalidIds',
              );
              return false;
            }
          }
        }

        return true;
      } catch (e) {
        debugPrint('Send notification error: $e');
        return false;
      }
    }

    return false;
  }

  Future<bool> updateLiveActivity(
    String activityId,
    Map<String, dynamic> eventUpdates,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://api.onesignal.com/apps/$_appId/live_activities/$activityId/notifications',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Key $_apiKey',
        },
        body: jsonEncode({
          'event': 'update',
          'event_updates': eventUpdates,
          'name': 'live_activity_update',
          'priority': 10,
        }),
      );

      debugPrint(
        'Update live activity response: ${response.statusCode} ${response.body}',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Update live activity error: $e');
      return false;
    }
  }

  Future<bool> endLiveActivity(String activityId) async {
    try {
      final dismissalDate =
          DateTime.now().add(const Duration(seconds: 5)).millisecondsSinceEpoch ~/
              1000;
      final response = await http.post(
        Uri.parse(
          'https://api.onesignal.com/apps/$_appId/live_activities/$activityId/notifications',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Key $_apiKey',
        },
        body: jsonEncode({
          'event': 'end',
          'event_updates': {'message': 'Ended'},
          'dismissal_date': dismissalDate,
          'name': 'live_activity_end',
        }),
      );

      debugPrint(
        'End live activity response: ${response.statusCode} ${response.body}',
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('End live activity error: $e');
      return false;
    }
  }

  Future<UserData?> fetchUser(String onesignalId) async {
    try {
      final url =
          'https://api.onesignal.com/apps/$_appId/users/by/onesignal_id/$onesignalId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UserData.fromJson(json);
      }
      debugPrint('Fetch user returned ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Fetch user error: $e');
      return null;
    }
  }
}
