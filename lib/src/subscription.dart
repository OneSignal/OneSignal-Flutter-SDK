import 'package:onesignal_flutter/src/utils.dart';

/// Represents the current user's subscription state with OneSignal
class OSSubscriptionState extends JSONStringRepresentable {
  /// Indicates if you have ever called setSubscription(false) to
  /// programmatically disable notifications for this user
  bool userSubscriptionSetting;

  /// A boolean parameter that indicates if the  user
  /// is subscribed to your app with OneSignal
  /// This is only true if the `userId`, `pushToken`, and
  /// `userSubscriptionSetting` parameters are defined/true.
  bool subscribed;

  /// The current user's User ID (AKA playerID) with OneSignal
  String userId; //the user's 'playerId' on OneSignal

  /// The APNS (iOS), GCM/FCM (Android) push token
  String pushToken;

  OSSubscriptionState(Map<String, dynamic> json) {
    this.subscribed = json['subscribed'] as bool;
    this.userSubscriptionSetting = json['userSubscriptionSetting'] as bool;

    if (json.containsKey('userId')) this.userId = json['userId'] as String;
    if (json.containsKey('pushToken'))
      this.pushToken = json['pushToken'] as String;
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'subscribed': this.subscribed,
      'userSubscriptionSetting': this.userSubscriptionSetting,
      'pushToken': this.pushToken,
      'userId': this.userId
    });
  }
}

/// An instance of this class describes a change in the user's OneSignal
/// push notification subscription state, ie. the user subscribed to
/// push notifications with your app.
class OSSubscriptionStateChanges extends JSONStringRepresentable {
  OSSubscriptionState from;
  OSSubscriptionState to;

  OSSubscriptionStateChanges(Map<String, dynamic> json) {
    if (json.containsKey('from'))
      this.from = OSSubscriptionState(json['from'].cast<String, dynamic>());
    if (json.containsKey('to'))
      this.to = OSSubscriptionState(json['to'].cast<String, dynamic>());
  }

  String jsonRepresentation() {
    return convertToJsonString(<String, dynamic>{
      'from': from.jsonRepresentation(),
      'to': to.jsonRepresentation()
    });
  }
}

/// Represents the user's OneSignal email subscription state,
class OSEmailSubscriptionState extends JSONStringRepresentable {
  bool subscribed;
  String emailUserId;
  String emailAddress;

  OSEmailSubscriptionState(Map<String, dynamic> json) {
    this.subscribed = false;

    if (json.containsKey('emailAddress') && json['emailAddress'] != null)
      this.emailAddress = json['emailAddress'] as String;

    if (json.containsKey('emailUserId') && json['emailUserId'] != null) {
      this.emailUserId = json['emailUserId'] as String;
      this.subscribed = true;
    }
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'subscribed': this.subscribed,
      'emailUserId': this.emailUserId,
      'emailAddress': this.emailAddress
    });
  }
}

/// An instance of this class describes a change in the user's
/// email subscription state with OneSignal
class OSEmailSubscriptionStateChanges extends JSONStringRepresentable {
  OSEmailSubscriptionState from;
  OSEmailSubscriptionState to;

  OSEmailSubscriptionStateChanges(Map<String, dynamic> json) {
    if (json.containsKey('from'))
      this.from = OSEmailSubscriptionState(json['from']);
    if (json.containsKey('to')) this.to = OSEmailSubscriptionState(json['to']);
  }

  String jsonRepresentation() {
    return convertToJsonString(<String, dynamic>{
      'from': this.from.jsonRepresentation(),
      'to': this.to.jsonRepresentation()
    });
  }
}
