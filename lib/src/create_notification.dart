import 'package:onesignal_flutter/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/src/notification.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// The parameters & format to create push notifications is
/// so different from receiving notifications that we represent
/// a Create Notification object as an entirely different class
class OSCreateNotification extends JSONStringRepresentable {
  /// An array of user ID's that should receive this notification
  List<String> playerIds;

  /// The notification's content (excluding title)
  String? content;

  /// The language code (ie. "en" for English) for this notification
  /// defaults to "en" (English)
  String? languageCode;

  /// The title/heading for the notification
  String? heading;

  /// The subtitle for the notification (iOS 10+ only)
  String? subtitle;

  /// Tells the app to launch in the background (iOS only)
  bool? contentAvailable;

  /// Tells the app to launch the Notification Service extension,
  /// which can mutate your notification (ie. download attachments)
  bool? mutableContent;

  /// Additional data you wish to send with the notification
  Map<String, dynamic>? additionalData;

  /// The URL to open when the user taps the notification
  String? url;

  /// Media (images, videos, etc.) for iOS
  /// Maps a custom ID to a resource URL
  /// in the format {'id' : 'https://.....'}
  Map<String, String>? iosAttachments;

  /// An image to use as the big picture (android only)
  String? bigPicture;

  /// A list of buttons to attach to the notification
  List<OSActionButton>? buttons;

  /// The category identifier for iOS (controls various aspects
  /// of the notification, for example, whether to launch a
  /// Notification Content Extension) (iOS only)
  String? iosCategory;

  /// The sound to play (iOS only)
  String? iosSound;

  /// The sound to play (Android only)
  String? androidSound;

  /// A small icon (Android only)
  /// Can be a drawable resource name or a URL
  String? androidSmallIcon;

  /// A large icon (android only)
  /// Can be a drawable resource name or a URL
  String? androidLargeIcon;

  /// The Android Oreo Notification Category to send the notification under
  String? androidChannelId;

  /// can be 'Increase' or 'SetTo'
  OSCreateNotificationBadgeType? iosBadgeType;

  /// The actual badge count to either set to directly, or increment by
  /// To decrement the user's badge count, send a negative value
  int? iosBadgeCount;

  /// If multiple notifications have the same collapse ID, only the most
  /// recent notification will be shown
  String? collapseId;

  /// Allows you to send a notification at a specific date
  DateTime? sendAfter;

  /// You can use several options to send notifications at specific times
  /// ie. you can send notifications to different user's at the same time
  /// in each timezone with the 'timezone' delayedOption
  OSCreateNotificationDelayOption? delayedOption;

  /// Used with delayedOption == timezone, lets you specify what time of day
  /// each user should receive the notification, ie. "9:00 AM"
  String? deliveryTimeOfDay;

  OSCreateNotification(
      {required this.playerIds,
      required this.content,
      this.languageCode,
      this.heading,
      this.subtitle,
      this.contentAvailable,
      this.mutableContent,
      this.additionalData,
      this.url,
      this.iosAttachments,
      this.bigPicture,
      this.buttons,
      this.iosCategory,
      this.iosSound,
      this.androidSound,
      this.androidSmallIcon,
      this.androidLargeIcon,
      this.androidChannelId,
      this.iosBadgeCount,
      this.iosBadgeType,
      this.collapseId,
      this.sendAfter,
      this.delayedOption,
      this.deliveryTimeOfDay});

  OSCreateNotification.silentNotification(
      {required this.playerIds,
      this.additionalData,
      this.sendAfter,
      this.delayedOption,
      this.deliveryTimeOfDay}) {
    this.contentAvailable = true;
  }

  Map<String, dynamic> mapRepresentation() {
    if (this.languageCode == null) this.languageCode = "en";

    var json = <String, dynamic>{"include_player_ids": this.playerIds};

    // add optional parameters to payload if present
    if (this.content != null)
      json['contents'] = {this.languageCode: this.content};
    if (this.heading != null)
      json['headings'] = {this.languageCode: this.heading};
    if (this.subtitle != null)
      json['subtitle'] = {this.languageCode: this.subtitle};
    if (this.contentAvailable != null)
      json['content_available'] = this.contentAvailable;
    if (this.mutableContent != null)
      json['mutable_content'] = this.mutableContent;
    if (this.additionalData != null) json['data'] = this.additionalData;
    if (this.url != null) json['url'] = this.url;
    if (this.iosAttachments != null)
      json['ios_attachments'] = this.iosAttachments;
    if (this.bigPicture != null) json['big_picture'] = this.bigPicture;
    if (this.iosCategory != null) json['ios_category'] = this.iosCategory;
    if (this.iosSound != null) json['ios_sound'] = this.iosSound;
    if (this.androidSound != null) json['android_sound'] = this.androidSound;
    if (this.androidSmallIcon != null)
      json['small_icon'] = this.androidSmallIcon;
    if (this.androidLargeIcon != null)
      json['large_icon'] = this.androidLargeIcon;
    if (this.androidChannelId != null)
      json['android_channel_id'] = this.androidChannelId;
    if (this.iosBadgeCount != null) json['ios_badgeCount'] = this.iosBadgeCount;
    if (this.collapseId != null) json['collapse_id'] = this.collapseId;
    if (this.deliveryTimeOfDay != null)
      json['delivery_time_of_day'] = this.deliveryTimeOfDay;

    // adds optional parameters that require transformations
    if (this.sendAfter != null)
      json['send_after'] = dateToStringWithOffset(this.sendAfter!);
    if (this.iosBadgeType != null)
      json['ios_badgeType'] = convertEnumCaseToValue(this.iosBadgeType);
    if (this.delayedOption != null)
      json['delayed_option'] = convertEnumCaseToValue(this.delayedOption);

    // adds buttons
    if (this.buttons != null) {
      var btns = List<Map<String, dynamic>>.empty(growable: true);
      this.buttons!.forEach((btn) => btns.add(btn.mapRepresentation()));
      json['buttons'] = btns;
    }

    return json;
  }

  @override
  String jsonRepresentation() {
    return convertToJsonString(this.mapRepresentation());
  }
}
