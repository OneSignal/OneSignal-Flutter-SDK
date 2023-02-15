import 'package:onesignal_flutter/src/subscription.dart';
import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/utils.dart';

class OSPermissionState extends JSONStringRepresentable {
  bool permission = false; 
  OSPermissionState(Map<String, dynamic> json) {
   if (json.containsKey('permission')) {
      bool enabled = json['permission'] as bool;
    }
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'permission': this.permission
    });
  }
}