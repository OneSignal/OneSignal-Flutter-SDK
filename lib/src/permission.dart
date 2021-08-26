import 'package:onesignal_flutter/src/subscription.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/utils.dart';

class OSPermissionState extends JSONStringRepresentable {
  bool hasPrompted = false; // iOS only
  bool provisional = false; //iOS only
  OSNotificationPermission? status;

  OSPermissionState(Map<String, dynamic> json) {
    if (json.containsKey('status')) {
      //ios
      this.status = OSNotificationPermission.values[json['status'] as int];
    } else if (json.containsKey('enabled')) {
      bool enabled = json['enabled'] as bool;
      this.status = enabled
          ? OSNotificationPermission.authorized
          : OSNotificationPermission.denied;
    }

    if (json.containsKey('provisional')) {
      this.provisional = json['provisional'] as bool;
    } else {
      this.provisional = false;
    }

    if (json.containsKey('hasPrompted')) {
      this.hasPrompted = json['hasPrompted'] as bool;
    } else {
      this.hasPrompted = false;
    }
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'hasPrompted': this.hasPrompted,
      'provisional': this.provisional,
      'status': this.status?.index ?? null
    });
  }
}

class OSPermissionSubscriptionState extends JSONStringRepresentable {
  late OSPermissionState permissionStatus;
  late OSSubscriptionState subscriptionStatus;
  late OSEmailSubscriptionState emailSubscriptionStatus;

  OSPermissionSubscriptionState(Map<String, dynamic> json) {
    this.permissionStatus =
        OSPermissionState(json['permissionStatus'].cast<String, dynamic>());
    this.subscriptionStatus =
        OSSubscriptionState(json['subscriptionStatus'].cast<String, dynamic>());
    this.emailSubscriptionStatus = OSEmailSubscriptionState(
        json['emailSubscriptionStatus'].cast<String, dynamic>());
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'permissionStatus': this.permissionStatus.jsonRepresentation(),
      'subscriptionStatus': this.subscriptionStatus.jsonRepresentation(),
      'emailSubscriptionStatus':
          this.emailSubscriptionStatus.jsonRepresentation()
    });
  }
}

class OSPermissionStateChanges extends JSONStringRepresentable {
  late OSPermissionState from;
  late OSPermissionState to;

  OSPermissionStateChanges(Map<String, dynamic> json) {
    if (json.containsKey('from'))
      this.from = OSPermissionState(json['from'].cast<String, dynamic>());
    if (json.containsKey('to'))
      this.to = OSPermissionState(json['to'].cast<String, dynamic>());
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'from': this.from.jsonRepresentation(),
      'to': this.to.jsonRepresentation()
    });
  }
}

class OSDeviceState extends JSONStringRepresentable {

  bool hasNotificationPermission = false;
  bool pushDisabled = false;
  bool subscribed = false;
  bool emailSubscribed = false;
  bool smsSubscribed = false;
  String? userId;
  String? pushToken;
  String? emailUserId;
  String? emailAddress;
  String? smsUserId;
  String? smsNumber;
  OSNotificationPermission? notificationPermissionStatus;

  OSDeviceState(Map<String, dynamic> json) {
    this.hasNotificationPermission = json['hasNotificationPermission'] as bool;
    this.pushDisabled = json['pushDisabled'] as bool;
    this.subscribed = json['subscribed'] as bool;
    this.emailSubscribed = json['emailSubscribed'] as bool;
    this.smsSubscribed = json['smsSubscribed'] as bool;
    this.userId = json['userId'] as String?;
    this.pushToken = json['pushToken'] as String?;
    this.emailUserId = json['emailUserId'] as String?;
    this.emailAddress = json['emailAddress'] as String?;
    this.smsUserId = json['smsUserId'] as String?;
    this.smsNumber = json['smsNumber'] as String?;
    this.notificationPermissionStatus = json['notificationPermissionStatus'] == null ? null : OSNotificationPermission.values[json['notificationPermissionStatus']];
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'hasNotificationPermission': this.hasNotificationPermission,
      'isPushDisabled': this.pushDisabled,
      'isSubscribed': this.subscribed,
      'userId': this.userId,
      'pushToken': this.pushToken,
      'isEmailSubscribed': this.emailSubscribed,
      'emailUserId': this.emailUserId,
      'emailAddress': this.emailAddress,
      'isSMSSubscribed': this.smsSubscribed,
      'smsUserId': this.smsUserId,
      'smsNumber': this.smsNumber,
      'notificationPermissionStatus': this.notificationPermissionStatus?.index,
    });
  }
}