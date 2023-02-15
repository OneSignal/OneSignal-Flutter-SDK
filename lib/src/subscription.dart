import 'package:onesignal_flutter/src/utils.dart';


/// Represents the current user's subscription state with OneSignal
class OSPushSubscriptionState extends JSONStringRepresentable {

  String? id;

  /// The APNS (iOS), GCM/FCM (Android) push token
  String? token;

  bool optedIn = false;
  
  OSPushSubscriptionState(Map<String, dynamic> json) {

    if (json.containsKey('id'))
      this.id = json['id'] as String?;
    if (json.containsKey('token')) this.token = json['token'] as String?;
    this.optedIn = json['optedIn'] as bool;
    
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'id': this.id,
      'token': this.token,
      'optedIn': this.optedIn
    });
  }
}

/// An instance of this class describes a change in the user's OneSignal
/// push notification subscription state, ie. the user subscribed to
/// push notifications with your app.
class OSPushSubscriptionStateChanges extends JSONStringRepresentable {
  late OSPushSubscriptionState from;
  late OSPushSubscriptionState to;

  OSPushSubscriptionStateChanges(Map<String, dynamic> json) {
    if (json.containsKey('from'))
      this.from = OSPushSubscriptionState(json['from'].cast<String, dynamic>());
    if (json.containsKey('to'))
      this.to = OSPushSubscriptionState(json['to'].cast<String, dynamic>());
  }

  String jsonRepresentation() {
    return convertToJsonString(<String, dynamic>{
      'from': from.jsonRepresentation(),
      'to': to.jsonRepresentation()
    });
  }
}