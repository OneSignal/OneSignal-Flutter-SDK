import 'package:onesignal_flutter/src/utils.dart';

/// When a click action is defined on an In App Message form the dashboard,
/// the handler returns an OSInAppMessageClickEvent object so the Dart code can act accordingly
/// This event includes the message and the result of the click
class OSInAppMessageClickEvent extends JSONStringRepresentable {
  late OSInAppMessage message;

  late OSInAppMessageClickResult result;

  OSInAppMessageClickEvent(Map<String, dynamic> json) {
    this.message = OSInAppMessage(json["message"].cast<String, dynamic>());
    this.result =
        OSInAppMessageClickResult(json["result"].cast<String, dynamic>());
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'message': this.message,
      'result': this.result,
    });
  }
}

/// When a click action is defined on an In App Message form the dashboard,
/// the handler returns an OSInAppMessageAction object so the Dart code can act accordingly
/// This allows for custom action events within Dart
class OSInAppMessageClickResult extends JSONStringRepresentable {
  // Name of the action event defined for the IAM element
  String? actionId;

  // URL given to the IAM element defined in the dashboard
  String? url;

  // Whether or not the click action should dismiss the IAM
  bool closingMessage = false;

  OSInAppMessageClickResult(Map<String, dynamic> json) {
    this.actionId = json["action_id"];
    this.url = json["url"];
    this.closingMessage = json["closing_message"] as bool;
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'action_id': this.actionId,
      'url': this.url,
      'closing_message': this.closingMessage,
    });
  }
}

class OSInAppMessage extends JSONStringRepresentable {
  String? messageId;

  OSInAppMessage(Map<String, dynamic> json) {
    this.messageId = json["message_id"];
  }

  String jsonRepresentation() {
    return convertToJsonString({'message_id': this.messageId});
  }
}

class OSInAppMessageWillDisplayEvent extends JSONStringRepresentable {
  late OSInAppMessage message;

  OSInAppMessageWillDisplayEvent(Map<String, dynamic> json) {
    this.message = OSInAppMessage(json["message"].cast<String, dynamic>());
  }

  String jsonRepresentation() {
    return convertToJsonString({'message': this.message.jsonRepresentation()});
  }
}

class OSInAppMessageDidDisplayEvent extends JSONStringRepresentable {
  late OSInAppMessage message;

  OSInAppMessageDidDisplayEvent(Map<String, dynamic> json) {
    this.message = OSInAppMessage(json["message"].cast<String, dynamic>());
  }

  String jsonRepresentation() {
    return convertToJsonString({'message': this.message.jsonRepresentation()});
  }
}

class OSInAppMessageWillDismissEvent extends JSONStringRepresentable {
  late OSInAppMessage message;

  OSInAppMessageWillDismissEvent(Map<String, dynamic> json) {
    this.message = OSInAppMessage(json["message"].cast<String, dynamic>());
  }

  String jsonRepresentation() {
    return convertToJsonString({'message': this.message.jsonRepresentation()});
  }
}

class OSInAppMessageDidDismissEvent extends JSONStringRepresentable {
  late OSInAppMessage message;

  OSInAppMessageDidDismissEvent(Map<String, dynamic> json) {
    this.message = OSInAppMessage(json["message"].cast<String, dynamic>());
  }

  String jsonRepresentation() {
    return convertToJsonString({'message': this.message.jsonRepresentation()});
  }
}
