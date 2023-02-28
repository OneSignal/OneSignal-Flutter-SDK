import 'package:onesignal_flutter/src/utils.dart';

class OSPermissionState extends JSONStringRepresentable {
  bool permission = false;
  OSPermissionState(Map<String, dynamic> json) {
    if (json.containsKey('permission')) {
      permission = json['permission'] as bool;
    }
  }

  String jsonRepresentation() {
    return convertToJsonString({'permission': this.permission});
  }
}
