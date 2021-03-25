import 'package:onesignal_flutter/src/defines.dart';
import 'dart:convert';

// produces a string like this: 2018-07-23T17:56:30.951030 UTC-7:00
String dateToStringWithOffset(DateTime date) {
  var offsetHours = date.timeZoneOffset.inHours;
  var offsetMinutes = date.timeZoneOffset.inMinutes % 60;
  var dateString = "${date.toIso8601String()} ";

  dateString += "UTC" +
      ((offsetHours > 10 || offsetHours < 0)
          ? "$offsetHours"
          : "0$offsetHours");
  dateString += ":" +
      ((offsetMinutes.abs() > 10) ? "$offsetMinutes" : "0$offsetMinutes:00");

  return dateString;
}

// in some places, we want to send an enum value to
// ObjC. Before we can do this, we must convert it
// to a string/int/etc.
// However, in some places such as iOS init settings,
// there could be multiple different types of enum,
// so we've combined it into this one function.
dynamic convertEnumCaseToValue(dynamic key) {
  switch (key) {
    case OSiOSSettings.autoPrompt:
      return "kOSSettingsKeyAutoPrompt";
    case OSiOSSettings.inAppAlerts:
      return "kOSSettingsKeyInAppAlerts";
    case OSiOSSettings.inAppLaunchUrl:
      return "kOSSettingsKeyInAppLaunchURL";
    case OSiOSSettings.inFocusDisplayOption:
      return "kOSSettingsKeyInFocusDisplayOption";
    case OSiOSSettings.promptBeforeOpeningPushUrl:
      return "kOSSSettingsKeyPromptBeforeOpeningPushURL";
  }

  switch (key) {
    case OSCreateNotificationBadgeType.increase:
      return "Increase";
    case OSCreateNotificationBadgeType.setTo:
      return "SetTo";
  }

  switch (key) {
    case OSCreateNotificationDelayOption.lastActive:
      return "last_active";
    case OSCreateNotificationDelayOption.timezone:
      return "timezone";
  }

  switch (key) {
    case OSNotificationDisplayType.none:
      return 0;
    case OSNotificationDisplayType.alert:
      return 1;
    case OSNotificationDisplayType.notification:
      return 2;
  }

  switch (key) {
      case OSSession.DIRECT:
        return "DIRECT";
      case OSSession.INDIRECT:
        return "INDIRECT";
      case OSSession.UNATTRIBUTED:
        return "UNATTRIBUTED";
      case OSSession.DISABLED:
        return "DISABLED";
  }

  return key;
}

/// An abstract class to provide JSON decoding
abstract class JSONStringRepresentable {
  String jsonRepresentation();

  String convertToJsonString(Map<String, dynamic>? object) => JsonEncoder
      .withIndent('  ')
      .convert(object)
      .replaceAll("\\n", "\n")
      .replaceAll("\\", "");
}
