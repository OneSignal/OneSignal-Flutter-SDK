import 'package:flutter/material.dart';
import 'dart:async';

//import OneSignal
import 'package:OneSignalFlutter/onesignal.dart';

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
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    var settings = { 
      OSiOSSettings.autoPrompt : false,
      OSiOSSettings.promptBeforeOpeningPushUrl : true 
    };

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      print("RECEIVED NOTIFICATION in dart: ${notification.jsonRepresentation()}");
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

    await OneSignal.shared.init("b2f7f966-d8cc-11e4-bed1-df8f05be55ba", iOSSettings: settings);
  }

  void handleGetTags() {
    OneSignal.shared.getTags().then((tags) {
      if (tags == null) return;

      setState((() {
        _tagsJson = "$tags";
      }));
    }).catchError((error) {
      setState(() {
        _tagsJson = "$error";
      });
    });
  }

  void handleSendTags() {
    print("Sending tags");
    OneSignal.shared.sendTag("test2", "val2").then((result) {
      print("Successfully sent tags: $result");
    }).catchError((error) {
      print("Encountered an error sending tags: $error");
    });
  }

  void handlePromptForPushPermission() {
    print("Prompting for Permission");
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });
  }

  void handleGetPermissionSubscriptionState() {
    print("Getting permissionSubscriptionState");
    OneSignal.shared.getPermissionSubscriptionState().then((status) {
      this.setState(() {
        _tagsJson = status.jsonRepresentation();
      });
    });
  }

  void handleSetEmail() {
    if (_emailAddress == null) return;

    print("Setting email");

    OneSignal.shared.setEmail(email: _emailAddress).whenComplete(() {
      print("Successfully set email");
    }).catchError((error) {
      print("Failed to set email with error: $error");
    });
  }

  void handleLogoutEmail() {
    print("Logging out of email");
    OneSignal.shared.logoutEmail().then((v) {
      print("Successfully logged out of email");
    }).catchError((error) {
      print("Failed to log out of email: $error");
    });
  }

  void handleSetConsent() {
    print("Setting consent to true");
    OneSignal.shared.consentGranted(true);
  }

  void handleSetLocationShared() {
    print("Setting location shared to true");
    OneSignal.shared.setLocationShared(true);
  }

  void handleDeleteTag() {
    print("Deleting tag");
    OneSignal.shared.deleteTag("test2").then((tags) {
      print("Successfully deleted tags, current tags = $tags");
    }).catchError((error) {
      print("Encountered error deleting tag: $error");
    });
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
                  new OneSignalButton("Get Tags", handleGetTags)
                ]
              ),
              new TableRow(
                children: [
                  new OneSignalButton("Send Tags", handleSendTags)
                ]
              ),
              new TableRow(
                children: [
                  new OneSignalButton("Prompt for Push Permission", handlePromptForPushPermission)
                ]
              ),
              new TableRow(
                children: [
                  new OneSignalButton("Print Permission Subscription State", handleGetPermissionSubscriptionState)
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
                  new OneSignalButton("Set Email", handleSetEmail)
                ]
              ),
              new TableRow(
                children: [
                  new OneSignalButton("Logout Email", handleLogoutEmail)
                ]
              ),
              new TableRow(
                children: [
                  new OneSignalButton("Provide GDPR Consent", handleSetConsent)
                ]
              ),
              new TableRow(
                children: [
                  new OneSignalButton("Set Location Shared", handleSetLocationShared)
                ]
              ),
              new TableRow(
                children: [
                  new OneSignalButton("Delete Tag", handleDeleteTag)
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

typedef void OnButtonPressed();

class OneSignalButton extends StatefulWidget {
  final String title;
  final OnButtonPressed onPressed;

  OneSignalButton(this.title, this.onPressed);

  State<StatefulWidget> createState() => new OneSignalButtonState();
}

class OneSignalButtonState extends State<OneSignalButton> {
  @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return new Table(
        children: [
          new TableRow(
            children: [
              new FlatButton(
                color: Color.fromARGB(255, 212, 86, 83),
                textColor: Color.fromARGB(255, 255, 255, 255),
                padding: EdgeInsets.all(8.0),
                child: new Text(widget.title),
                onPressed: widget.onPressed,
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
        ],
      );
    }
}