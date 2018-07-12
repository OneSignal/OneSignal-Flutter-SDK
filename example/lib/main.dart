import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:onesignal/onesignal.dart';
import 'package:onesignal/src/notification.dart';
import 'package:onesignal/src/subscription.dart';
import 'package:onesignal/src/defines.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await OneSignal.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    var settings = { 
      OSiOSSettings.autoPrompt : false, 
      OSiOSSettings.inFocusDisplayOption : OSNotificationDisplayType.alert,
      OSiOSSettings.promptBeforeOpeningPushUrl : true 
    };

    OneSignal.shared.init("78e8aff3-7ce2-401f-9da0-2d41f287ebaf", iOSSettings: settings);

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      var title = notification.payload.body;
      print("RECEIVED NOTIFICATION in dart: $title");
    });
    
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      var id = result.action.actionId;
      print("OPENED NOTIFICATION WITH ID in dart: $id");
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED FROM ${changes.from.userId} TO ${changes.to.userId}");
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
