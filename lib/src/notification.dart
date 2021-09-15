import 'package:onesignal_flutter/src/defines.dart';
import 'package:onesignal_flutter/src/utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// A class representing the notification, including the
/// payload of the notification as well as additional
/// parameters (such as whether the notification was `shown`
/// to the user, whether it's `silent`, etc.)
class OSNotification extends JSONStringRepresentable {

  /// The OneSignal notification ID for this notification
  late String notificationId;

  /// If this notification was created from a Template on the
  /// OneSignal dashboard, this will be the ID of that template
  String? templateId;

  /// The name of the template (if any) that was used to
  /// create this push notification
  String? templateName;

  /// The sound file (ie. ping.aiff) that should be played
  /// when the notification is received
  String? sound;

  /// The title for the notification
  String? title;

  /// The body (should contain most of the text)
  String? body;

  /// If set, he launch URL will be opened when the user
  /// taps on your push notification. You can control
  /// whether or not it opens in an in-app webview or
  /// in Safari (with iOS).
  String? launchUrl;

  /// Any additional custom data you want to send along
  /// with this notification.
  Map<String, dynamic>? additionalData;

  /// Any buttons you want to add to the notification.
  /// The notificationOpened handler will provide an
  /// OSNotificationAction object, which will contain
  /// the ID of the Action the user tapped.
  List<OSActionButton>? buttons;

  /// A hashmap object representing the raw key/value
  /// properties of the push notification
  Map<String, dynamic>? rawPayload;

  /// (iOS Only)
  /// Any attachments (images, sounds, videos) you want
  /// to display with this notification.
  Map<String, dynamic>? attachments;

  /// (iOS Only)
  /// Tells the system to launch your app in the background (ie. if
  /// content is available to download in the background)
  bool? contentAvailable;

  /// (iOS Only)
  /// Tells the system to launch the Notification Extension Service
  bool? mutableContent;

  /// (iOS Only)
  /// The category for this notification. This can trigger custom
  /// behavior (ie. if this notification should display a
  /// custom Content Extension for custom UI)
  String? category;

  /// (iOS Only)
  /// If you set the badge to a specific value, this integer
  /// property will be that value
  int? badge;

  /// (iOS Only)
  /// If you want to increment the badge by some value, this
  /// integer will be the increment/decrement
  int? badgeIncrement;

  /// (iOS Only)
  /// The subtitle of the notification
  String? subtitle;

  /// (iOS Only)
  /// value between 0 and 1 for sorting notifications in a notification summary
  double? relevanceScore;

  /// (iOS Only)
  /// The interruption level for the notification. This controls how the
  /// notification will be displayed to the user if they are using focus modes
  /// or notification summaries
  String? interruptionLevel;

  /// (Android Only)
  /// Summary notifications grouped
  /// Notification payload will have the most recent notification received.
  List<OSNotification>? groupedNotifications;

  /// (Android Only)
  /// The android notification ID (not same as  the OneSignal
  /// notification ID)
  int? androidNotificationId;

  /// (Android Only)
  /// The filename of the image to use as the small
  /// icon for the notification
  String? smallIcon;

  /// (Android Only)
  /// The filename for the image to use as the large
  /// icon for the notification
  String? largeIcon;

  /// (Android Only)
  /// The URL or filename for the image to use as
  /// the big picture for the notification
  String? bigPicture;

  /// (Android Only)
  /// The accent color to use on the notification
  /// Hex value in ARGB format (it's a normal
  /// hex color value, but it includes the alpha
  /// channel in addition to red, green, blue)
  String? smallIconAccentColor;

  /// (Android Only)
  /// The color to use to light up the LED (if
  /// applicable) when the notification is received
  /// Given in hex ARGB format.
  String? ledColor;

  /// (Android only) API level 21+
  /// Sets the visibility of the notification
  ///  1 = Public (default)
  ///  0 = Private (hidden from lock screen
  ///    if user set 'Hide Sensitive content')
  ///  -1 = Secret (doesn't appear at all)
  int? lockScreenVisibility;

  /// (Android only)
  /// All notifications with the same group key
  /// from the same app will be grouped together
  String? groupKey;

  /// (Android only) Android 6 and earlier only
  /// The message to display when multiple
  /// notifications have been stacked together.
  /// Note: Android 7 allows groups (stacks)
  /// to be expanded, so group message is no
  /// longer necessary
  String? groupMessage;

  /// (Android Only)
  /// Tells you what project number/sender ID
  /// the notification was sent from
  String? fromProjectNumber;

  /// (Android Only)
  /// The collapse ID for the notification
  /// As opposed to groupKey (which causes stacking),
  /// the collapse ID will completely replace any
  /// previously received push notifications that
  /// use the same collapse_id
  String? collapseId;

  /// (Android Only)
  /// The priority used with GCM/FCM to describe how
  /// urgent the notification is. A higher priority
  /// means the notification will be delivered faster.
  /// Default = 10.
  int? priority;

  /// (Android Only)
  /// Describes the background image layout of the
  /// notification (if set)
  OSAndroidBackgroundImageLayout? backgroundImageLayout;

  //converts JSON map to OSNotification instance
  OSNotification(Map<String, dynamic> json) {
    // iOS Specific Parameters
    if (json.containsKey('contentAvailable'))
      this.contentAvailable = json['contentAvailable'] as bool?;
    if (json.containsKey('mutableContent'))
      this.mutableContent = json['mutableContent'] as bool?;
    if (json.containsKey('category'))
      this.category = json['category'] as String?;
    if (json.containsKey('badge')) 
      this.badge = json['badge'] as int?;
    if (json.containsKey('badgeIncrement'))
      this.badgeIncrement = json['badgeIncrement'] as int?;
    if (json.containsKey('subtitle'))
      this.subtitle = json['subtitle'] as String?;
    if (json.containsKey('attachments'))
      this.attachments = json['attachments'].cast<String, dynamic>();
    if (json.containsKey('relevanceScore'))
      this.relevanceScore = json['relevanceScore'] as double?;
    if (json.containsKey('interruptionLevel'))
      this.interruptionLevel = json['interruptionLevel'] as String?;

    // Android Specific Parameters
    if (json.containsKey("smallIcon"))
      this.smallIcon = json['smallIcon'] as String?;
    if (json.containsKey("largeIcon"))
      this.largeIcon = json['largeIcon'] as String?;
    if (json.containsKey("bigPicture"))
      this.bigPicture = json['bigPicture'] as String?;
    if (json.containsKey("smallIconAccentColor"))
      this.smallIconAccentColor = json['smallIconAccentColor'] as String?;
    if (json.containsKey("ledColor"))
      this.ledColor = json['ledColor'] as String?;
    if (json.containsKey("lockScreenVisibility"))
      this.lockScreenVisibility = json['lockScreenVisibility'] as int?;
    if (json.containsKey("groupMessage"))
      this.groupMessage = json['groupMessage'] as String?;
    if (json.containsKey("groupKey"))
      this.groupKey = json['groupKey'] as String?;
    if (json.containsKey("fromProjectNumber"))
      this.fromProjectNumber = json['fromProjectNumber'] as String?;
    if (json.containsKey("collapseId"))
      this.collapseId = json['collapseId'] as String?;
    if (json.containsKey("priority")) 
      this.priority = json['priority'] as int?;
    if (json.containsKey("androidNotificationId"))
      this.androidNotificationId = json['androidNotificationId'] as int?;
    if (json.containsKey('backgroundImageLayout')) {
      this.backgroundImageLayout = OSAndroidBackgroundImageLayout(
          json['backgroundImageLayout'].cast<String, dynamic>());
    }
    if (json.containsKey('groupedNotifications')) {
      final dynamic jsonGroupedNotifications = json['groupedNotifications'];
      final jsonList = jsonDecode(jsonGroupedNotifications.toString()) as List<dynamic>;
      this.groupedNotifications = jsonList.map((dynamic item) =>
          OSNotification(item as Map<String, dynamic>)).toList();
    }
    
    // shared parameters
    this.notificationId = json['notificationId'] as String;

    if (json.containsKey('templateName'))
      this.templateName = json['templateName'] as String?;
    if (json.containsKey('templateId'))
      this.templateId = json['templateId'] as String?;
    if (json.containsKey('sound')) 
      this.sound = json['sound'] as String?;
    if (json.containsKey('title'))
      this.title = json['title'] as String?;
    if (json.containsKey('body')) 
      this.body = json['body'] as String?;
    if (json.containsKey('launchUrl'))
      this.launchUrl = json['launchUrl'] as String?;
    if (json.containsKey('additionalData'))
      this.additionalData = json['additionalData'].cast<String, dynamic>();

    // raw payload comes as a JSON string
    if (json.containsKey('rawPayload')) {
      var raw = json['rawPayload'] as String;
      JsonDecoder decoder = JsonDecoder();
      this.rawPayload = decoder.convert(raw);
    }

    if (json.containsKey('buttons')) {
      this.buttons = List<OSActionButton>.empty(growable: true);
      var btns = json['buttons'] as List<dynamic>;
      for (var btn in btns) {
        var serialized = btn.cast<String, dynamic>();
        this.buttons!.add(OSActionButton.fromJson(serialized));
      }
    }
  }

  String jsonRepresentation() => convertToJsonString(this.rawPayload);
}

/// An instance of this class represents a user interaction with
/// your push notification, ie. if they tap a button
class OSNotificationOpenedResult {
  //instance properties
  late OSNotification notification;
  OSNotificationAction? action;

  //constructor
  OSNotificationOpenedResult(Map<String, dynamic> json) {
    this.notification =
        OSNotification(json['notification'].cast<String, dynamic>());

    if (json.containsKey('action')) {
      this.action =
          OSNotificationAction(json['action'].cast<String, dynamic>());
    }
  }
}

/// Represents an action taken on a push notification, such as
/// tapping the notification (or a button on the notification),
/// or if your `inFocusDisplayType` is set to true - if they
/// tapped 'close'.
class OSNotificationAction {
  /// An enum that represents whether the user `opened` or
  /// took a more specific `action` (such as tapping a button
  /// on the notification)
  late OSNotificationActionType type;

  /// The ID of the button on your notification
  /// that the user tapped
  String? actionId;

  OSNotificationAction(Map<String, dynamic> json) {
    this.type = OSNotificationActionType.opened;
    this.actionId = json['id'] as String?;

    if (json.containsKey('type'))
      this.type = OSNotificationActionType.values[json['type'] as int];
  }
}

/// Represents a button sent as part of a push notification
class OSActionButton extends JSONStringRepresentable {
  /// The custom unique ID for this button
  late String id;

  /// The text to display for the button
  late String text;

  /// (Android only)
  /// The URL/filename to show as the
  /// button's icon
  String? icon;

  OSActionButton({required this.id, required this.text, this.icon});

  OSActionButton.fromJson(Map<String, dynamic> json) {
    this.id = json['id'] as String;
    this.text = json['text'] as String;

    if (json.containsKey('icon')) this.icon = json['icon'] as String?;
  }

  Map<String, dynamic> mapRepresentation() {
    return {'id': this.id, 'text': this.text, 'icon': this.icon};
  }

  String jsonRepresentation() {
    return convertToJsonString(this.mapRepresentation());
  }
}

/// (Android Only)
/// This class represents the background image layout
/// used for push notifications that show a background image
class OSAndroidBackgroundImageLayout extends JSONStringRepresentable {
  /// (Android Only)
  /// The image URL/filename to show as the background image
  String? image;

  /// (Android Only)
  /// The color of the title text
  String? titleTextColor;

  /// (Android Only)
  /// The color of the body text
  String? bodyTextColor;

  OSAndroidBackgroundImageLayout(Map<String, dynamic> json) {
    if (json.containsKey('image')) this.image = json['image'] as String?;
    if (json.containsKey('titleTextColor'))
      this.titleTextColor = json['titleTextColor'] as String?;
    if (json.containsKey('bodyTextColor'))
      this.bodyTextColor = json['bodyTextColor'] as String?;
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'image': this.image,
      'titleTextColor': this.titleTextColor,
      'bodyTextColor': this.bodyTextColor
    });
  }
}

class OSNotificationReceivedEvent extends JSONStringRepresentable {

  late OSNotification notification;

  OSNotificationReceivedEvent(Map<String, dynamic> json) {
    notification = OSNotification(json);
  }

  void complete(OSNotification? notification) {
    print('OSNotificationReceivedEvent complete with notification: $notification');
    if (notification != null) {
        OneSignal.shared.completeNotification(notification.notificationId, true);
    } else {
        OneSignal.shared.completeNotification(this.notification.notificationId, false);
    }
  }

  String jsonRepresentation() {
    return convertToJsonString({
      'notification': this.notification.jsonRepresentation()
    });
  }
}