import 'package:onesignal/src/defines.dart';

class OSNotificationAction {

  // instance properties
  final OSNotificationActionType type;
  final String actionId;
  
  //constructor
  OSNotificationAction(this.type, this.actionId);

  static OSNotificationAction fromJson(Map<dynamic, dynamic> json) {
    var type = OSNotificationActionType.opened;

    if (json.containsKey('type')) 
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
  Map<dynamic, dynamic> additionalData;
  Map<dynamic, dynamic> attachments;
  List<Map<dynamic, dynamic>> buttons;
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
  static OSNotification fromJson(Map<dynamic, dynamic> json) {
    var payload = OSNotificationPayload(json['payload'] as Map<dynamic, dynamic>);
    var type = OSNotificationDisplayType.alert;

    if (json.containsKey('displayType')) 
      type = OSNotificationDisplayType.values[json['displayType'] as int];
    
    return OSNotification(payload, type, json['shown'] as bool, json['appInFocus'] as bool, json['silent'] as bool, payload.mutableContent);
  }
}

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