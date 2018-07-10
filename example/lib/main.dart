import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:onesignal/onesignal.dart';
import 'package:onesignal/src/notification.dart';

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

    OneSignal.shared.init("13f8ef36-d990-4fb2-baf4-0f442255755a", <String, dynamic> {});

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      var title = notification.payload.title;
      print("RECEIVED NOTIFICATION: $title");
    });
    
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      var id = result.actionId;
      print("OPENED NOTIFICATION WITH ID: $id");
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
