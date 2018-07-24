import 'package:OneSignalFlutter/src/subscription.dart';
import 'package:OneSignalFlutter/src/defines.dart';
import 'package:OneSignalFlutter/src/utils.dart';

class OSPermissionState extends JSONStringRepresentable {
  bool hasPrompted; // iOS only
  bool provisional; //iOS only
  OSNotificationPermission status;
  
  OSPermissionState(Map<dynamic, dynamic> json) {
    
    if (json.containsKey('status')) {
      //ios
      this.status = OSNotificationPermission.values[json['status'] as int];
    } else if (json.containsKey('enabled')) {
      bool enabled = json['enabled'] as bool;
      this.status = enabled ? OSNotificationPermission.authorized : OSNotificationPermission.denied;
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
      'hasPrompted' : this.hasPrompted,
      'provisional' : this.provisional,
      'status' : this.status.index
    });
  }
}

class OSPermissionSubscriptionState extends JSONStringRepresentable {
  OSPermissionState permissionStatus;
  OSSubscriptionState subscriptionStatus;
  OSEmailSubscriptionState emailSubscriptionStatus;

  OSPermissionSubscriptionState(Map<dynamic, dynamic> json) {
    this.permissionStatus = OSPermissionState(json['permissionStatus']);
    this.subscriptionStatus = OSSubscriptionState(json['subscriptionStatus']);
    this.emailSubscriptionStatus = OSEmailSubscriptionState(json['emailSubscriptionStatus']);
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'permissionStatus' : this.permissionStatus.jsonRepresentation(),
      'subscriptionStatus' : this.subscriptionStatus.jsonRepresentation(),
      'emailSubscriptionStatus' : this.emailSubscriptionStatus.jsonRepresentation()
    });
  }
}

class OSPermissionStateChanges extends JSONStringRepresentable {
  OSPermissionState from;
  OSPermissionState to;

  OSPermissionStateChanges(Map<dynamic, dynamic> json) {
    this.from = OSPermissionState(json['from']);
    this.to = OSPermissionState(json['to']);
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'from' : this.from.jsonRepresentation(),
      'to' : this.to.jsonRepresentation()
    });
  }
}