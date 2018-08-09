import 'package:onesignal/src/defines.dart';
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

String createNotificationDelayOptionToString(OSCreateNotificationDelayOption option) {
  if (option == OSCreateNotificationDelayOption.lastActive) {
    return "last_active";
  } else {
    return "timezone";
  }
}

String createNotificationBadgeTypeToString(OSCreateNotificationBadgeType type) {
  if (type == OSCreateNotificationBadgeType.increase) {
    return "Increase";
  } else {
    return "SetTo";
  }
}

int notificationDisplayTypeToInt(OSNotificationDisplayType type) {
  switch (type) {
    case OSNotificationDisplayType.none:
      return 0;
    case OSNotificationDisplayType.alert:
      return 1;
    default:
      return 2;
  }
}

/// An abstract class to provide JSON decoding
abstract class JSONStringRepresentable {
  String jsonRepresentation();

  String convertToJsonString(Map<String, dynamic> object) => JsonEncoder
      .withIndent('  ')
      .convert(object)
      .replaceAll("\\n", "\n")
      .replaceAll("\\", "");
}
