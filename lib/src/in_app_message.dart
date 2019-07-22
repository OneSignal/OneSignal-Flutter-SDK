import 'package:onesignal_flutter/src/utils.dart';

/// When a click action is defined on an In App Message form the dashboard,
/// the handler returns an OSInAppMessageAction object so the Dart code can act accordingly
/// This allows for custom action events within Dart
class OSInAppMessageAction extends JSONStringRepresentable {

  // Name of the action event defined for the IAM element
  String clickName;

  // URL given to the IAM element defined in the dashboard
  String clickUrl;

  // Determines if a first click has occurred or not on the IAM element
  bool firstClick;

  // Whether or not the click action should dismiss the IAM
  bool closesMessage;

  OSInAppMessageAction(Map<String, dynamic> json) {
    this.clickName = json["click_name"];
    this.clickUrl = json["click_url"];
    this.firstClick = json["first_click"] as bool;
    this.closesMessage = json["closes_message"] as bool;
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'click_name': this.clickName,
      'click_url': this.clickUrl,
      'first_click': this.firstClick,
      'closes_message': this.closesMessage,
    });
  }

}
