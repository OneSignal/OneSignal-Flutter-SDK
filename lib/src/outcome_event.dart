import 'dart:convert';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/utils.dart';

OSSession sessionFromString(String session) {
    session = session.toLowerCase();
    if (session == 'direct') {
        return OSSession.DIRECT;
    } else if (session == 'indirect') {
        return OSSession.INDIRECT;
    } else if (session == 'unattributed') {
        return OSSession.UNATTRIBUTED;
    }

    return OSSession.DISABLED;
}

/// When an outcome is sent the onSuccess will return an OutcomeEvent
/// This object is converted from the native OutcomeEvent into the OSOutcomeEvent
/// for Dart to use
class OSOutcomeEvent extends JSONStringRepresentable {

  // The session when the outcome event is sent (DIRECT, INDIRECT, UNATTRIBUTED)
  OSSession session = OSSession.DISABLED;

  // List of notification ids that were sent with the outcome
  List<String> notificationIds = [];

  // Name of the outcome event
  String name = "";

  // Time in millis when the outcome was sent
  int timestamp = 0;

  // Value if one exists (default 0.0) that was sent with the outcome
  double weight = 0.0;

  OSOutcomeEvent() {

  }

  OSOutcomeEvent.fromMap(Map<String, dynamic> outcome) {
      // Make sure session exists
      this.session = outcome.containsKey("session") && outcome["session"] != null ?
                     sessionFromString(outcome["session"] as String) :
                     OSSession.DISABLED;

      // Make sure notification_ids exists
      if (outcome.containsKey("notification_ids") && outcome["notification_ids"] != null) {
        if (outcome["notification_ids"] is List) {
          // Handle if type comes in as a List
          this.notificationIds = (outcome["notification_ids"] as List).map<String>((s) => s).toList();
        }
        else if (outcome["notification_ids"] is String) {
          // Handle if type comes in as a String
          this.notificationIds = new List<String>.from(json.decode(outcome["notification_ids"]));
        }
      }

      // Make sure name exists
      this.name = outcome.containsKey("id") && outcome["id"] != null ?
                  outcome["id"] as String :
                  "";

      // Make sure timestamp exists
      this.timestamp = outcome.containsKey("timestamp") && outcome["timestamp"] != null ?
                       outcome["timestamp"] as int :
                       0;

      // Make sure weight exists
      this.weight = outcome.containsKey("weight") && outcome["weight"] != null ?
                    double.parse(outcome["weight"] as String) :
                    0.0;
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'session': convertEnumCaseToValue(this.session),
      'notification_ids': this.notificationIds,
      'id': this.name,
      'timestamp': this.timestamp,
      'weight': this.weight,
    });
  }

}
