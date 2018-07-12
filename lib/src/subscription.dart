
class OSSubscriptionState {
  bool subscribed; //indicates if the user is subscribed to your app with OneSignal
  bool userSubscriptionSetting; //returns setSubscription state
  String userId; //the user's 'playerId' on OneSignal
  String pushToken;
  
  OSSubscriptionState(Map<dynamic, dynamic> json) {
    this.subscribed = json['subscribed'] as bool;
    this.userSubscriptionSetting = json['userSubscriptionSetting'] as bool;

    if (json.containsKey('userId')) this.userId = json['userId'] as String;
    if (json.containsKey('pushToken')) this.pushToken = json['pushToken'] as String;
  }
}

class OSSubscriptionStateChanges {
  OSSubscriptionState from;
  OSSubscriptionState to;

  OSSubscriptionStateChanges(Map<dynamic, dynamic> json) {
    if (json.containsKey('from')) this.from = OSSubscriptionState(json['from'] as Map<dynamic, dynamic>);
    if (json.containsKey('to')) this.to = OSSubscriptionState(json['to'] as Map<dynamic, dynamic>);
  }
}