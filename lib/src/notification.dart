import 'package:onesignal/src/defines.dart';

class OSNotificationAction {

  // instance properties
  final OSNotificationActionType type;
  final String actionId;
  
  //constructor
  OSNotificationAction(this.type, this.actionId);

  static OSNotificationAction fromJson(Map<String, dynamic> json) {
    var type = OSNotificationActionType.opened;

    if (json['type'] as int != null) 
      type = OSNotificationActionType.values[json['type'] as int];
    
    return OSNotificationAction(type, json['id'] as String);
  }
}

class OSNotificationPayload {
  
  //instance properties
  String notificationId;
  String templateId;
  String templateName;
  bool contentAvailable;
  bool mutableContent;
  String category;
  int badge;
  int badgeIncrement;
  String sound;
  String title;
  String subtitle;
  String body;
  String launchUrl;
  Map<String, dynamic> additionalData;
  Map<String, dynamic> attachments;
  List<Map<String, String>> buttons;
  Map<String, dynamic> rawPayload;

  OSNotificationPayload(Map<String, dynamic> json) {
    this.notificationId = json['notificationId'];
    this.templateName = json['templateName'];
    this.templateId = json['templateId'];
    this.contentAvailable = json['contentAvailable'];
    this.mutableContent = json['mutableContent'];
    this.category = json['category'];
    this.badge = json['badge'];
    this.badgeIncrement = json['badgeIncrement'];
    this.sound = json['sound'];
    this.title = json['title'];
    this.subtitle = json['subtitle'];
    this.body = json['body'];
    this.launchUrl = json['launchUrl'];
    this.additionalData = json['additionalData'];
    this.attachments = json['attachments'];
    this.buttons = json['buttons'];
    this.rawPayload = json;
  }
}

class OSNotification {

  //instance properties
  final OSNotificationPayload payload;
  final OSNotificationDisplayType displayType;
  final bool shown;
  final bool appInFocus;
  final bool silent;
  final bool mutableContent;

  //constructor
  OSNotification(this.payload, this.displayType, this.shown, this.appInFocus, this.silent, this.mutableContent);

  //converts JSON map to OSNotification instance
  static OSNotification fromJson(Map<String, dynamic> json) {
    var payload = OSNotificationPayload(json);
    var type = OSNotificationDisplayType.alert;

    if (json['displayType'] as int != null) 
      type = OSNotificationDisplayType.values[json['displayType'] as int];
    
    return OSNotification(payload, type, json['shown'] as bool, json['appInFocus'] as bool, json['silent'] as bool, payload.mutableContent);
  }
}

class OSNotificationOpenedResult {
  
  //instance properties
  final OSNotification notification;
  final OSNotificationAction actionId;

  //constructor
  OSNotificationOpenedResult(this.notification, this.actionId);

  //converts JSON map to OSNotificationOpenedResult instance
  static OSNotificationOpenedResult fromJson(Map<String, dynamic> json) {
    return OSNotificationOpenedResult(OSNotification.fromJson(json), OSNotificationAction.fromJson(json['action']));
  }
}