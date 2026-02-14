import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notification_type.dart';
import '../models/user_data.dart';
import '../services/log_manager.dart';

class OneSignalApiService {
  String _appId = '';

  void setAppId(String appId) => _appId = appId;
  String get appId => _appId;

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

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/vnd.onesignal.v1+json',
        },
        body: jsonEncode(body),
      );

      LogManager().i(
        'API',
        'Send notification response: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } catch (e) {
      LogManager().e('API', 'Send notification error: $e');
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

      LogManager().i(
        'API',
        'Send custom notification response: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } catch (e) {
      LogManager().e('API', 'Send custom notification error: $e');
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
      LogManager().w('API', 'Fetch user returned ${response.statusCode}');
      return null;
    } catch (e) {
      LogManager().e('API', 'Fetch user error: $e');
      return null;
    }
  }
}
