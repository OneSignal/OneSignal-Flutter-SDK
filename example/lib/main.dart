import 'package:flutter/material.dart';
import 'dart:async';

// TODO: Figure out how to get all of these classes/enums imported just 
// by importing OneSignal.dart, create some sort of umbrella declaration
// without having to create a giant onesignal file.
import 'package:onesignal/onesignal.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tagsJson = "";
  String _emailAddress;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    var settings = { 
      OSiOSSettings.autoPrompt : false, 
      OSiOSSettings.inFocusDisplayOption : OSNotificationDisplayType.alert,
      OSiOSSettings.promptBeforeOpeningPushUrl : true 
    };

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      var title = notification.payload.body;
      print("RECEIVED NOTIFICATION in dart: $title");
    });
    
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      var id = result.action.actionId;
      print("OPENED NOTIFICATION WITH ID in dart: $id");
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges changes) {
      print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.init("78e8aff3-7ce2-401f-9da0-2d41f287ebaf", iOSSettings: settings);

    try {
      print("Sending tags");
      var tags = await OneSignal.shared.sendTag("test", "value");
      print("Successfully sent tags: $tags");
    } catch (error) {
      print("Encountered exception sending tags: $error");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('OneSignal Flutter Demo'),
          backgroundColor: Color.fromARGB(255, 212, 86, 83),
        ),
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: new Table(
            children: [
              new TableRow(
                children: [
                  new FlatButton(
                    color: Color.fromARGB(255, 212, 86, 83),
                    textColor: Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.all(8.0),
                    child: new Text("Get Tags"),
                    onPressed: () {
                      OneSignal.shared.getTags().then((tags) {
                        setState((() {
                          _tagsJson = "$tags";
                        }));
                      }).catchError((error) {
                        setState(() {
                          _tagsJson = "$error";
                        });
                      });
                    },
                  )
                ]
              ),
              new TableRow(
                children: [
                  Container(
                    height: 8.0,
                  )
                ]
              ),
              new TableRow(
                children: [
                  new FlatButton(
                    color: Color.fromARGB(255, 212, 86, 83),
                    textColor: Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.all(8.0),
                    child: new Text("Send Tags"),
                    onPressed: () {
                      print("Sending tags");
                      OneSignal.shared.sendTag("test1", "val1").then((result) {
                        print("Successfully sent tags: $result");
                      }).catchError((error) {
                        print("Encountered an error sending tags: $error");
                      });
                    },
                  )
                ]
              ),
              new TableRow(
                children: [
                  Container(
                    height: 8.0,
                  )
                ]
              ),
              new TableRow(
                children: [
                  new FlatButton(
                    color: Color.fromARGB(255, 212, 86, 83),
                    textColor: Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.all(8.0),
                    child: new Text("Prompt for Push Permission"),
                    onPressed: () {
                      print("Prompting for Permission");
                      OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
                        print("Accepted permission: $accepted");
                      });
                    },
                  )
                ]
              ),
              new TableRow(
                children: [
                  Container(
                    height: 8.0,
                  )
                ]
              ),
              new TableRow(
                children: [
                  new FlatButton(
                    color: Color.fromARGB(255, 212, 86, 83),
                    textColor: Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.all(8.0),
                    child: new Text("Get Permission Subscription State"),
                    onPressed: () {
                      print("Getting permissionSubscriptionState");
                      OneSignal.shared.getPermissionSubscriptionState().then((status) {
                        this.setState(() {
                          _tagsJson = status.jsonRepresentation();
                        });
                      });
                    },
                  )
                ]
              ),
              new TableRow(
                children: [
                  Container(
                    height: 8.0,
                  )
                ]
              ),
              new TableRow(
                children: [
                  new TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "Email Address",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 212, 86, 83),
                      )
                    ),
                    onChanged: (text) {
                      this.setState(() {
                        _emailAddress = text == "" ? null : text;
                      });
                    },
                  )
                ]
              ),
              new TableRow(
                children: [
                  Container(
                    height: 8.0,
                  )
                ]
              ),
              new TableRow(
                children: [
                  new FlatButton(
                    color: Color.fromARGB(255, 212, 86, 83),
                    textColor: Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.all(8.0),
                    child: new Text("Set Email"),
                    onPressed: () {
                      if (_emailAddress == null) return;

                      print("Setting email");
                      OneSignal.shared.setEmail(email: _emailAddress).then((response) {
                        print("Successfully set email: $response");
                      }, onError: (error) {
                        print("Failed to set email with error: $error");
                      });
                    },
                  )
                ]
              ),
              new TableRow(
                children: [
                  Container(
                    height: 8.0,
                  )
                ]
              ),
              new TableRow(
                children: [
                  new Container(
                    child: new Text(_tagsJson),
                    alignment: Alignment.center,
                  )
                ]
              )
            ],
          ),
        )
      ),
    );
  }
}