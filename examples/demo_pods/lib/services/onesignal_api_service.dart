import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/notification_type.dart';
import '../models/user_data.dart';

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
    try {
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
      if (type.androidChannelId != null) {
        body['android_channel_id'] = type.androidChannelId;
      }

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/vnd.onesignal.v1+json',
        },
        body: jsonEncode(body),
      );

      debugPrint('Send notification response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Send notification error: $e');
      return false;
    }
  }

  Future<bool> sendCustomNotification(
    String title,
    String body,
    String subscriptionId,
  ) async {
    try {
      final payload = <String, dynamic>{
        'app_id': _appId,
        'include_subscription_ids': [subscriptionId],
        'headings': {'en': title},
        'contents': {'en': body},
      };

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/vnd.onesignal.v1+json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('Send custom notification response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Send custom notification error: $e');
      return false;
    }
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
