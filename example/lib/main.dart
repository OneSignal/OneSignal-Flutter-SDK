import 'package:flutter/material.dart';
import 'dart:async';

//import OneSignal
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp>
    with
        OneSignalPushSubscriptionObserver,
        OneSignalPermissionObserver,
        OneSignalInAppMessageClickListener,
        OneSignalNotificationLifecycleListener,
        OneSignalNotificationClickListener {
  String _debugLabelString = "";
  String? _emailAddress;
  String? _smsNumber;
  String? _externalUserId;
  String? _language;
  bool _enableConsentButton = false;

  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.shared.consentRequired(_requireConsent);

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    OneSignal.shared.initialize("77e32082-ea27-42e3-a898-c72e141824ef");

    // AndroidOnly stat only
    // OneSignal.Notifications.removeNotification(1);
    // OneSignal.Notifications.removeGroupedNotifications("group5");

    OneSignal.Notifications.clearAll();

    OneSignal.User.pushSubscription.addObserver(this);
    OneSignal.Notifications.addPermissionObserver(this);
    OneSignal.Notifications.addClickListener(this);
    OneSignal.Notifications.addLifecycleListener(this);
    OneSignal.InAppMessages.addClickListener(this);
    OneSignal.InAppMessages.addWillDisplayListener((event) {
      print("ON WILL DISPLAY IN APP MESSAGE ${event.message.messageId}");
    });
    OneSignal.InAppMessages.addDidDisplayListener((event) {
      print("ON DID DISPLAY IN APP MESSAGE ${event.message.messageId}");
    });
    OneSignal.InAppMessages.addWillDismissListener((event) {
      print("ON WILL DISMISS IN APP MESSAGE ${event.message.messageId}");
    });
    OneSignal.InAppMessages.addDidDismissListener((event) {
      print("ON DID DISMISS IN APP MESSAGE ${event.message.messageId}");
    });

    // iOS-only method to open launch URLs in Safari when set to false
    OneSignal.shared.setLaunchURLsInApp(false);

    this.setState(() {
      _enableConsentButton = _requireConsent;
    });

    // Some examples of how to use In App Messaging public methods with OneSignal SDK
    oneSignalInAppMessagingTriggerExamples();

    // Some examples of how to use Outcome Events public methods with OneSignal SDK
    oneSignalOutcomeExamples();

    OneSignal.InAppMessages.paused(false);
  }

  void onNotificationPermissionDidChange(bool state) {
    print("Has permission " + state.toString());
  }

  void onOSPushSubscriptionChange(OSPushSubscriptionChangedState state) {
    print(OneSignal.User.pushSubscription.optedIn);
    print(OneSignal.User.pushSubscription.id);
    print(OneSignal.User.pushSubscription.token);
    print(state.current.jsonRepresentation());
  }

  void onClickInAppMessage(OSInAppMessageClickEvent event) {
    this.setState(() {
      _debugLabelString =
          "In App Message Clicked: \n${event.result.jsonRepresentation().replaceAll("\\n", "\n")}";
    });
  }

  void onClickNotification(OSNotificationClickEvent event) {
    print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
    this.setState(() {
      _debugLabelString =
          "Clicked notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
    });
  }

  void onWillDisplayNotification(OSNotificationWillDisplayEvent event) {
    print(
        'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');

    /// Display Notification, preventDefault to not display
    event.preventDefault();

    /// Do async work

    /// notification.display() to display after preventing default
    event.notification.display();

    this.setState(() {
      _debugLabelString =
          "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
    });
  }

  void _handleSendTags() {
    print("Sending tags");
    OneSignal.User.addTagWithKey("test2", "val2");

    print("Sending tags array");
    var sendTags = {'test': 'value', 'test2': 'value2'};
    OneSignal.User.addTags(sendTags);
  }

  void _handleRemoveTag() {
    print("Deleting tag");
    OneSignal.User.removeTag("test2");

    print("Deleting tags array");
    OneSignal.User.removeTags(['test']);
  }

  void _handlePromptForPushPermission() {
    print("Prompting for Permission");
    OneSignal.Notifications.requestPermission(true);
  }

  void _handleSetLanguage() {
    if (_language == null) return;
    print("Setting language");
    OneSignal.User.setLanguage(_language!);
  }

  void _handleSetEmail() {
    if (_emailAddress == null) return;
    print("Setting email");

    OneSignal.User.addEmail(_emailAddress!);
  }

  void _handleRemoveEmail() {
    if (_emailAddress == null) return;
    print("Remove email");

    OneSignal.User.removeEmail(_emailAddress!);
  }

  void _handleSetSMSNumber() {
    if (_smsNumber == null) return;
    print("Setting SMS Number");

    OneSignal.User.addSms(_smsNumber!);
  }

  void _handleRemoveSMSNumber() {
    if (_smsNumber == null) return;
    print("Remove smsNumber");

    OneSignal.User.removeSms(_smsNumber!);
  }

  void _handleConsent() {
    print("Setting consent to true");
    OneSignal.shared.consentGiven(true);

    print("Setting state");
    this.setState(() {
      _enableConsentButton = false;
    });
  }

  void _handleSetLocationShared() {
    print("Setting location shared to true");
    OneSignal.Location.setShared(true);
  }

  void _handleLogin() {
    print("Setting external user ID");
    if (_externalUserId == null) return;
    OneSignal.shared.login(_externalUserId!);
    OneSignal.User.addAlias("fb_id", "1341524");
  }

  void _handleLogout() {
    OneSignal.shared.logout();
    OneSignal.User.removeAlias("fb_id");
  }

  oneSignalInAppMessagingTriggerExamples() async {
    /// Example addTrigger call for IAM
    /// This will add 1 trigger so if there are any IAM satisfying it, it
    /// will be shown to the user
    OneSignal.InAppMessages.addTrigger("trigger_1", "one");

    /// Example addTriggers call for IAM
    /// This will add 2 triggers so if there are any IAM satisfying these, they
    /// will be shown to the user
    Map<String, String> triggers = new Map<String, String>();
    triggers["trigger_2"] = "two";
    triggers["trigger_3"] = "three";
    OneSignal.InAppMessages.addTriggers(triggers);

    // Removes a trigger by its key so if any future IAM are pulled with
    // these triggers they will not be shown until the trigger is added back
    OneSignal.InAppMessages.removeTrigger("trigger_2");

    // Create a list and bulk remove triggers based on keys supplied
    List<String> keys = ["trigger_1", "trigger_3"];
    OneSignal.InAppMessages.removeTriggers(keys);

    // Toggle pausing (displaying or not) of IAMs
    OneSignal.InAppMessages.paused(true);
    var arePaused = await OneSignal.InAppMessages.arePaused();
    print('Notifications paused ${arePaused}');
  }

  oneSignalOutcomeExamples() async {
    OneSignal.Session.addOutcome("normal_1");
    OneSignal.Session.addOutcome("normal_2");

    OneSignal.Session.addUniqueOutcome("unique_1");
    OneSignal.Session.addUniqueOutcome("unique_2");

    OneSignal.Session.addOutcomeWithValue("value_1", 3.2);
    OneSignal.Session.addOutcomeWithValue("value_2", 3.9);
  }

  void _handleOptIn() {
    OneSignal.User.pushSubscription.optIn();
  }

  void _handleOptOut() {
    OneSignal.User.pushSubscription.optOut();
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
            child: SingleChildScrollView(
              child: new Table(
                children: [
                  new TableRow(children: [
                    new OneSignalButton(
                        "Send Tags", _handleSendTags, !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new OneSignalButton("Prompt for Push Permission",
                        _handlePromptForPushPermission, !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          hintText: "Email Address",
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 212, 86, 83),
                          )),
                      onChanged: (text) {
                        this.setState(() {
                          _emailAddress = text == "" ? null : text;
                        });
                      },
                    )
                  ]),
                  new TableRow(children: [
                    Container(
                      height: 8.0,
                    )
                  ]),
                  new TableRow(children: [
                    new OneSignalButton(
                        "Set Email", _handleSetEmail, !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new OneSignalButton("Logout Email", _handleRemoveEmail,
                        !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          hintText: "SMS Number",
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 212, 86, 83),
                          )),
                      onChanged: (text) {
                        this.setState(() {
                          _smsNumber = text == "" ? null : text;
                        });
                      },
                    )
                  ]),
                  new TableRow(children: [
                    Container(
                      height: 8.0,
                    )
                  ]),
                  new TableRow(children: [
                    new OneSignalButton("Set SMS Number", _handleSetSMSNumber,
                        !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new OneSignalButton("Remove SMS Number",
                        _handleRemoveSMSNumber, !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new OneSignalButton("Provide GDPR Consent", _handleConsent,
                        _enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new OneSignalButton("Set Location Shared",
                        _handleSetLocationShared, !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new OneSignalButton(
                        "Remove Tag", _handleRemoveTag, !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          hintText: "External User ID",
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 212, 86, 83),
                          )),
                      onChanged: (text) {
                        this.setState(() {
                          _externalUserId = text == "" ? null : text;
                        });
                      },
                    )
                  ]),
                  new TableRow(children: [
                    Container(
                      height: 8.0,
                    )
                  ]),
                  new TableRow(children: [
                    new OneSignalButton("Set External User ID", _handleLogin,
                        !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new OneSignalButton("Remove External User ID",
                        _handleLogout, !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          hintText: "Language",
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 212, 86, 83),
                          )),
                      onChanged: (text) {
                        this.setState(() {
                          _language = text == "" ? null : text;
                        });
                      },
                    )
                  ]),
                  new TableRow(children: [
                    Container(
                      height: 8.0,
                    )
                  ]),
                  new TableRow(children: [
                    new OneSignalButton("Set Language", _handleSetLanguage,
                        !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new Container(
                      child: new Text(_debugLabelString),
                      alignment: Alignment.center,
                    )
                  ]),
                  new TableRow(children: [
                    new OneSignalButton(
                        "Opt In", _handleOptIn, !_enableConsentButton)
                  ]),
                  new TableRow(children: [
                    new OneSignalButton(
                        "Opt Out", _handleOptOut, !_enableConsentButton)
                  ]),
                ],
              ),
            ),
          )),
    );
  }
}

typedef void OnButtonPressed();

class OneSignalButton extends StatefulWidget {
  final String title;
  final OnButtonPressed onPressed;
  final bool enabled;

  OneSignalButton(this.title, this.onPressed, this.enabled);

  State<StatefulWidget> createState() => new OneSignalButtonState();
}

class OneSignalButtonState extends State<OneSignalButton> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Table(
      children: [
        new TableRow(children: [
          new TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 212, 86, 83),
              disabledBackgroundColor: Color.fromARGB(180, 212, 86, 83),
              padding: EdgeInsets.all(8.0),
            ),
            child: new Text(widget.title),
            onPressed: widget.enabled ? widget.onPressed : null,
          )
        ]),
        new TableRow(children: [
          Container(
            height: 8.0,
          )
        ]),
      ],
    );
  }
}
