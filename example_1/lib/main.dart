import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

const String kAppId = '77e32082-ea27-42e3-a898-c72e141824ef';

void main() => runApp(const OneSignalDemoApp());

class OneSignalDemoApp extends StatelessWidget {
  const OneSignalDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSignal Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFFD45653),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD45653),
          primary: const Color(0xFFD45653),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _pushId;
  bool _pushEnabled = true;
  bool _locationShared = true;
  bool _inAppMessagesPaused = true;
  bool _requireConsent = false;

  List<String> _emails = [];
  List<String> _smsNumbers = [];
  Map<String, String> _tags = {};
  Map<String, String> _aliases = {};
  Map<String, String> _triggers = {};

  @override
  void initState() {
    super.initState();
    _initOneSignal();
  }

  Future<void> _initOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.consentRequired(_requireConsent);

    // Initialize and wait for SDK to be ready
    await OneSignal.initialize(kAppId);

    OneSignal.LiveActivities.setupDefault();
    OneSignal.Notifications.clearAll();

    // Set initial state now that SDK is initialized
    setState(() {
      _pushId = OneSignal.User.pushSubscription.id;
      _pushEnabled = OneSignal.User.pushSubscription.optedIn ?? false;
    });

    // Observer for future state changes
    OneSignal.User.pushSubscription.addObserver((state) {
      print(
        'OneSignal push subscription changed: ${state.jsonRepresentation()}',
      );
      setState(() {
        _pushId = state.current.id;
        _pushEnabled = state.current.optedIn;
      });
    });

    OneSignal.User.addObserver((state) {
      print('OneSignal user changed: ${state.jsonRepresentation()}');
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      print('Has permission: $state');
    });

    OneSignal.Notifications.addClickListener((event) {
      print('Notification clicked: ${event.notification.title}');
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('Notification will display: ${event.notification.title}');
      event.notification.display();
    });

    OneSignal.InAppMessages.addClickListener((event) {
      print('In-app message clicked: ${event.result.jsonRepresentation()}');
    });

    OneSignal.InAppMessages.paused(true);
  }

  void _showLoginDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('External User Id'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter external user id'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                OneSignal.login(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('LOGIN'),
          ),
        ],
      ),
    );
  }

  void _showAddAliasDialog() {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Alias'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(labelText: 'Key'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: 'Value'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (keyController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                OneSignal.User.addAlias(
                  keyController.text,
                  valueController.text,
                );
                setState(() {
                  _aliases[keyController.text] = valueController.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  void _showAddEmailDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Email'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Enter email address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                OneSignal.User.addEmail(controller.text);
                setState(() {
                  _emails.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  void _showAddSmsDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New SMS'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'Enter phone number'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                OneSignal.User.addSms(controller.text);
                setState(() {
                  _smsNumbers.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog() {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(labelText: 'Key'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: 'Value'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (keyController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                OneSignal.User.addTagWithKey(
                  keyController.text,
                  valueController.text,
                );
                setState(() {
                  _tags[keyController.text] = valueController.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  void _showAddTriggerDialog() {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Trigger'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(labelText: 'Key'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: 'Value'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (keyController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                OneSignal.InAppMessages.addTrigger(
                  keyController.text,
                  valueController.text,
                );
                setState(() {
                  _triggers[keyController.text] = valueController.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  void _showOutcomeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Outcome'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Outcome name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                OneSignal.Session.addOutcome(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppSection(),
                      const SizedBox(height: 8),
                      _buildActionButton('REVOKE CONSENT', () {
                        OneSignal.consentGiven(false);
                      }),
                      _buildActionButton('LOGIN USER', _showLoginDialog),
                      _buildActionButton('LOGOUT USER', () {
                        OneSignal.logout();
                      }),
                      _buildAliasesSection(),
                      _buildPushSection(),
                      _buildEmailsSection(),
                      _buildSmsSection(),
                      _buildTagsSection(),
                      _buildOutcomeSection(),
                      _buildInAppMessagingSection(),
                      _buildTriggersSection(),
                      _buildLocationSection(),
                      _buildSendPushNotificationSection(),
                      _buildSendInAppMessageSection(),
                      const SizedBox(height: 16),
                      _buildFullWidthButton(
                        'NEXT ACTIVITY',
                        () {
                          // Navigate to next activity if needed
                        },
                        color: Colors.grey.shade300,
                        textColor: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: const Color(0xFFD45653),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '1',
                style: TextStyle(
                  color: Color(0xFFD45653),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'OneSignal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'App',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black87),
              children: [
                TextSpan(
                  text: 'App-Id\n:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: kAppId),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD45653),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildAliasesSection() {
    return _buildListSectionWithItems(
      title: 'Aliases',
      emptyText: 'No Aliases Added',
      items: _aliases.entries.map((e) => MapEntry(e.key, '${e.key}: ${e.value}')).toList(),
      buttonText: 'ADD ALIAS',
      onAdd: _showAddAliasDialog,
      onDelete: (key) {
        OneSignal.User.removeAlias(key);
        setState(() {
          _aliases.remove(key);
        });
      },
    );
  }

  Widget _buildPushSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Push',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87),
                  children: [
                    const TextSpan(
                      text: 'Push-Id:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: _pushId ?? 'Loading...'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enabled'),
                  Switch(
                    value: _pushEnabled,
                    onChanged: (value) {
                      setState(() {
                        _pushEnabled = value;
                      });
                      if (value) {
                        OneSignal.User.pushSubscription.optIn();
                      } else {
                        OneSignal.User.pushSubscription.optOut();
                      }
                    },
                    activeColor: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmailsSection() {
    return _buildListSectionWithItems(
      title: 'Emails',
      emptyText: 'No Emails Added',
      items: _emails.map((e) => MapEntry(e, e)).toList(),
      buttonText: 'ADD EMAIL',
      onAdd: _showAddEmailDialog,
      onDelete: (email) {
        OneSignal.User.removeEmail(email);
        setState(() {
          _emails.remove(email);
        });
      },
    );
  }

  Widget _buildSmsSection() {
    return _buildListSectionWithItems(
      title: 'SMSs',
      emptyText: 'No SMSs Added',
      items: _smsNumbers.map((s) => MapEntry(s, s)).toList(),
      buttonText: 'ADD SMS',
      onAdd: _showAddSmsDialog,
      onDelete: (sms) {
        OneSignal.User.removeSms(sms);
        setState(() {
          _smsNumbers.remove(sms);
        });
      },
    );
  }

  Widget _buildTagsSection() {
    return _buildListSectionWithItems(
      title: 'Tags',
      emptyText: 'No Tags Added',
      items: _tags.entries.map((e) => MapEntry(e.key, '${e.key}: ${e.value}')).toList(),
      buttonText: 'ADD TAG',
      onAdd: _showAddTagDialog,
      onDelete: (key) {
        OneSignal.User.removeTag(key);
        setState(() {
          _tags.remove(key);
        });
      },
    );
  }

  Widget _buildOutcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Outcome Events',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        _buildActionButton('SEND OUTCOME', _showOutcomeDialog),
      ],
    );
  }

  Widget _buildInAppMessagingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'In-App Messaging',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pause In-App Messages:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Toggle in-app messages',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: _inAppMessagesPaused,
                onChanged: (value) {
                  setState(() {
                    _inAppMessagesPaused = value;
                  });
                  OneSignal.InAppMessages.paused(value);
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTriggersSection() {
    return _buildListSectionWithItems(
      title: 'Triggers',
      emptyText: 'No Triggers Added',
      items: _triggers.entries.map((e) => MapEntry(e.key, '${e.key}: ${e.value}')).toList(),
      buttonText: 'ADD TRIGGER',
      onAdd: _showAddTriggerDialog,
      onDelete: (key) {
        OneSignal.InAppMessages.removeTrigger(key);
        setState(() {
          _triggers.remove(key);
        });
      },
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Shared:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Location will be shared from device',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: _locationShared,
                onChanged: (value) {
                  setState(() {
                    _locationShared = value;
                  });
                  OneSignal.Location.setShared(value);
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildActionButton('PROMPT LOCATION', () {
          OneSignal.Location.requestPermission();
        }),
      ],
    );
  }

  Widget _buildSendPushNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Send Push Notification',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: [
            _buildGridButton('General', Icons.notifications),
            _buildGridButton('Greetings', Icons.waving_hand),
            _buildGridButton('Promotions', Icons.local_offer),
            _buildGridButton('Breaking News', Icons.newspaper),
            _buildGridButton('Abandoned Cart', Icons.shopping_cart),
            _buildGridButton('New Post', Icons.image),
            _buildGridButton('Re-Engagement', Icons.touch_app),
            _buildGridButton('Rating', Icons.star),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSendInAppMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Send In-App Message',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: [
            _buildGridButton('Top Banner', Icons.vertical_align_top),
            _buildGridButton('Bottom Banner', Icons.vertical_align_bottom),
            _buildGridButton('Center Modal', Icons.crop_square),
            _buildGridButton('Full Screen', Icons.phone_android),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGridButton(String label, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        // Add trigger to show specific in-app message
        OneSignal.InAppMessages.addTrigger('show_message', label.toLowerCase());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD45653),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildListSectionWithItems({
    required String title,
    required String emptyText,
    required List<MapEntry<String, String>> items,
    required String buttonText,
    required VoidCallback onAdd,
    required void Function(String key) onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    emptyText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  children: items.map((item) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          item.value,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFFD45653)),
                          onPressed: () => onDelete(item.key),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD45653),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFullWidthButton(
    String text,
    VoidCallback onPressed, {
    Color? color,
    Color? textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFFD45653),
          foregroundColor: textColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
