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
  OSSession session;

  // List of notification ids that were sent with the outcome
  List<String> notificationIds;

  // Name of the outcome event
  String name;

  // Time in millis when the outcome was sent
  int timestamp;

  // Value if one exists (default 0.0) that was sent with the outcome
  double weight;

  OSOutcomeEvent(Map<String, dynamic> outcome) {
      // Make sure session exists
      this.session = outcome["session"] == null ?
                     OSSession.DISABLED :
                     sessionFromString(outcome["session"] as String);

      // Make sure notification_ids exists
      this.notificationIds = outcome["notification_ids"] == null ?
                             [] :
                             new List<String>.from(json.decode(outcome["notification_ids"]));

      // Make sure name exists
      this.name = outcome["id"] == null ?
                  "" :
                  outcome["id"] as String;

      // Make sure timestamp exists
      this.timestamp = outcome["timestamp"] == null ?
                       0 :
                       outcome["timestamp"] as int;

      // Make sure weight exists
      this.weight = outcome["weight"] == null ?
                    0 :
                    double.parse(outcome["weight"] as String);
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
