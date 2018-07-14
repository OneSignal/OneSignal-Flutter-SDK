import 'package:onesignal/defines.dart';

/// Represents an action taken on a push notification, such as
/// tapping the notification (or a button on the notification),
/// or if your `inFocusDisplayType` is set to true - if they 
/// tapped 'close'.
class OSNotificationAction {

  /// An enum that represents whether the user `opened` or 
  /// took a more specific `action` (such as tapping a button
  /// on the notification)
  final OSNotificationActionType type;

  /// The ID of the button on your notification 
  /// that the user tapped
  final String actionId;
  
  OSNotificationAction(this.type, this.actionId);

  static OSNotificationAction fromJson(Map<dynamic, dynamic> json) {
    var type = OSNotificationActionType.opened;

    if (json.containsKey('type')) 
      type = OSNotificationActionType.values[json['type'] as int];
    
    return OSNotificationAction(type, json['id'] as String);
  }
}

/// This class represents the actual payload of the notification,
/// the data that impacts the content of the notification itself.
class OSNotificationPayload extends JSONStringRepresentable {

  /// The OneSignal notification ID for this notification
  String notificationId;

  /// If this notification was created from a Template on the 
  /// OneSignal dashboard, this will be the ID of that template
  String templateId;

  /// The name of the template (if any) that was used to 
  /// create this push notification
  String templateName;

  /// An iOS specific parameter `content-available` that tells
  /// the system to launch your app in the background (ie. if
  /// content is available to download in the background)
  bool contentAvailable;

  /// An iOS specific parameter `mutable-content` that tells
  /// the system to launch the Notification Extension Service
  bool mutableContent;

  /// The category for this notification. This can trigger custom
  /// behavior (ie. if this notification should display a 
  /// custom Content Extension for custom UI)
  String category;

  /// If you set the badge to a specific value, this integer 
  /// property will be that value
  int badge;

  /// If you want to increment the badge by some value, this
  /// integer will be the increment/decrement
  int badgeIncrement;

  /// The sound file (ie. ping.aiff) that should be played
  /// when the notification is received
  String sound;

  /// The title for the notification
  String title;

  /// The subtitle of the notification
  String subtitle;

  /// The body (should contain most of the text)
  String body;

  /// If set, he launch URL will be opened when the user 
  /// taps on your push notification. You can control
  /// whether or not it opens in an in-app webview or
  /// in Safari (with iOS).
  String launchUrl;

  /// Any additional custom data you want to send along
  /// with this notification.
  Map<dynamic, dynamic> additionalData;

  /// Any attachments (images, sounds, videos) you want
  /// to display with this notification.
  Map<dynamic, dynamic> attachments;

  /// Any buttons you want to add to the notification.
  /// The notificationOpened handler will provide an
  /// OSNotificationAction object, which will contain
  /// the ID of the Action the user tapped.
  List<Map<dynamic, dynamic>> buttons;

  /// A hashmap object representing the raw key/value 
  /// properties of the push notification
  Map<dynamic, dynamic> rawPayload;

  OSNotificationPayload(Map<dynamic, dynamic> json) {
    this.notificationId = json['notificationId'] as String;

    //optional properties
    if (json.containsKey('rawPayload')) this.rawPayload = json['rawPayload'] as Map<dynamic, dynamic>;
    if (json.containsKey('templateName')) this.templateName = json['templateName'] as String;
    if (json.containsKey('templateId')) this.templateId = json['templateId'] as String;
    if (json.containsKey('contentAvailable')) this.contentAvailable = json['contentAvailable'] as bool;
    if (json.containsKey('mutableContent')) this.mutableContent = json['mutableContent'] as bool;
    if (json.containsKey('category')) this.category = json['category'] as String;
    if (json.containsKey('badge')) this.badge = json['badge'] as int;
    if (json.containsKey('badgeIncrement')) this.badgeIncrement = json['badgeIncrement'] as int;
    if (json.containsKey('sound')) this.sound = json['sound'] as String;
    if (json.containsKey('title')) this.title = json['title'] as String;
    if (json.containsKey('subtitle')) this.subtitle = json['subtitle'] as String;
    if (json.containsKey('body')) this.body = json['body'] as String;
    if (json.containsKey('launchUrl')) this.launchUrl = json['launchUrl'] as String;
    if (json.containsKey('additionalData')) this.additionalData = json['additionalData'] as Map<dynamic, dynamic>;
    if (json.containsKey('attachments')) this.attachments = json['attachments'] as Map<dynamic, dynamic>;

    if (json.containsKey('buttons')) {
      this.buttons = List<Map<dynamic, dynamic>>();
      var btns = json['buttons'] as List<dynamic>;
      for (var btn in btns) {
        var serialized = btn as Map<dynamic, dynamic>;
        this.buttons.add(serialized);
      }
    }
  }

  String jsonRepresentation() => convertToJsonString(this.rawPayload);
}

/// A class representing the notification, including the
/// payload of the notification as well as additional
/// parameters (such as whether the notification was `shown` 
/// to the user, whether it's `silent`, etc.)
class OSNotification extends JSONStringRepresentable {

  /// Represents the payload, the data received from the
  /// server for this push notification
  final OSNotificationPayload payload;

  /// The display type that the SDK used at the time the
  /// push notification was delivered.
  final OSNotificationDisplayType displayType;

  /// A boolean indicating if the notification was displayed
  final bool shown;

  /// A boolean indicating if your app was open when
  /// the push notification was received
  final bool appInFocus;

  /// Indicates if it was a silent (non user-interactive/background)
  /// push notification.
  final bool silent;

  //constructor
  OSNotification(this.payload, this.displayType, this.shown, this.appInFocus, this.silent);

  //converts JSON map to OSNotification instance
  static OSNotification fromJson(Map<dynamic, dynamic> json) {
    var payload = OSNotificationPayload(json['payload'] as Map<dynamic, dynamic>);
    var type = OSNotificationDisplayType.alert;

    if (json.containsKey('displayType')) 
      type = OSNotificationDisplayType.values[json['displayType'] as int];
    
    return OSNotification(payload, type, json['shown'] as bool, json['appInFocus'] as bool, json['silent'] as bool);
  }
  
  String jsonRepresentation() {
    return convertToJsonString({
      'payload' : this.payload.jsonRepresentation(),
      'displayType' : this.displayType.index,
      'shown' : this.shown,
      'appInFocus' : this.appInFocus,
      'silent' : this.silent
    });
  }
}

/// An instance of this class represents a user interaction with
/// your push notification, ie. if they tap a button
class OSNotificationOpenedResult {
  
  //instance properties
  final OSNotification notification;
  final OSNotificationAction action;

  //constructor
  OSNotificationOpenedResult(this.notification, this.action);

  //converts JSON map to OSNotificationOpenedResult instance
  static OSNotificationOpenedResult fromJson(Map<dynamic, dynamic> json) {
    var not = OSNotification.fromJson(json['notification'] as Map<dynamic, dynamic>);
    var actionMap = json['action'] as Map<dynamic, dynamic>;
    return OSNotificationOpenedResult(not, OSNotificationAction.fromJson(actionMap));
  }
}