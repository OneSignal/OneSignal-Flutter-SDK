import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

const String kAppId = '77e32082-ea27-42e3-a898-c72e141824ef';

/// Notification template data for demo push notifications
enum NotificationType {
  general(
    group: 'General',
    icon: Icons.notifications,
    smallIconRes: 'ic_bell_white_24dp',
    iconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fbell.png?alt=media&token=73c2bdd9-355f-42bb-80d7-aead737a9dbc',
    buttons: [],
    templates: [
      NotificationTemplate(
        title: 'Liked post',
        message: 'Michael DiCioccio liked your post!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fbell_red.png?alt=media&token=c80c4e76-1fd7-4912-93f4-f1aee1d98b20',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: 'Birthdays',
        message: 'Say happy birthday to Rodrigo and 5 others!',
        largeIconUrl: 'https://images.vexels.com/media/users/3/147226/isolated/preview/068af50eededd7a739aac52d8e509ab5-three-candles-birthday-cake-icon-by-vexels.png',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: 'New Post',
        message: 'Neil just posted for the first time in while, check it out!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fbell_red.png?alt=media&token=c80c4e76-1fd7-4912-93f4-f1aee1d98b20',
        bigPictureUrl: '',
      ),
    ],
  ),
  greeting(
    group: 'Greetings',
    icon: Icons.waving_hand,
    smallIconRes: 'ic_human_greeting_white_24dp',
    iconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fhuman-greeting.png?alt=media&token=178bd69d-634e-40b3-ac32-b56c88e6cd6a',
    buttons: [],
    templates: [
      NotificationTemplate(
        title: '',
        message: 'Welcome to Nike!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fhuman-greeting-red.png?alt=media&token=cb9f3418-db61-443c-955a-57e664d30271',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: '',
        message: 'Welcome to Adidas!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fhuman-greeting-red.png?alt=media&token=cb9f3418-db61-443c-955a-57e664d30271',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: '',
        message: "Welcome to Sandra's cooking blog!",
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fhuman-greeting-red.png?alt=media&token=cb9f3418-db61-443c-955a-57e664d30271',
        bigPictureUrl: '',
      ),
    ],
  ),
  promotions(
    group: 'Promotions',
    icon: Icons.local_offer,
    smallIconRes: 'ic_brightness_percent_white_24dp',
    iconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fbrightness-percent.png?alt=media&token=6a8b4348-ad51-4e3a-97d0-4deb46b1576e',
    buttons: [],
    templates: [
      NotificationTemplate(
        title: '50% Off Sale!',
        message: 'Limited time offer. Shop now!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpromotion.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpromotion_big.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
      ),
      NotificationTemplate(
        title: 'Flash Deal!',
        message: 'Hurry! This deal ends in 2 hours.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpromotion.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpromotion_big.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
      ),
      NotificationTemplate(
        title: 'Exclusive Offer',
        message: 'Just for you! Get 20% off your next order.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpromotion.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpromotion_big.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
      ),
    ],
  ),
  breakingNews(
    group: 'Breaking News',
    icon: Icons.newspaper,
    smallIconRes: 'ic_newspaper_white_24dp',
    iconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fnewspaper.png?alt=media&token=053e419b-14f1-4f0d-a439-bb5b46d1b917',
    buttons: [
      {'id': 'id1', 'text': 'View'},
      {'id': 'id2', 'text': 'Save'},
      {'id': 'id3', 'text': 'Share'},
    ],
    templates: [
      NotificationTemplate(
        title: 'Breaking: Major Update',
        message: 'Tap to read the full story.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fnews.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fnews_big.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
      ),
      NotificationTemplate(
        title: 'Tech News Alert',
        message: 'New developments in the tech world.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fnews.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fnews_big.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
      ),
      NotificationTemplate(
        title: 'Sports Update',
        message: 'Your team just scored!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fnews.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fnews_big.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
      ),
    ],
  ),
  abandonedCart(
    group: 'Abandoned Cart',
    icon: Icons.shopping_cart,
    smallIconRes: 'ic_cart_white_24dp',
    iconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fcart.png?alt=media&token=cf7f4d13-6aa2-4824-9b2f-42e5f33f545b',
    buttons: [],
    templates: [
      NotificationTemplate(
        title: 'You Left Something Behind',
        message: 'Your cart is waiting for you.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fcart.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: 'Complete Your Purchase',
        message: 'Items in your cart are selling fast!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fcart.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: 'Don\'t Miss Out',
        message: 'Your saved items might go out of stock.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fcart.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: '',
      ),
    ],
  ),
  newPost(
    group: 'New Post',
    icon: Icons.image,
    smallIconRes: 'ic_image_white_24dp',
    iconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fimage.png?alt=media&token=6fb66f31-23de-4c76-a2ff-da40d46ebf15',
    buttons: [],
    templates: [
      NotificationTemplate(
        title: 'New Photo Posted',
        message: 'Check out the latest post!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpost.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpost_big.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
      ),
      NotificationTemplate(
        title: 'Someone Tagged You',
        message: 'You were tagged in a new post.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpost.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpost_big.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
      ),
      NotificationTemplate(
        title: 'Trending Now',
        message: 'This post is getting lots of attention.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpost.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Fpost_big.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
      ),
    ],
  ),
  reEngagement(
    group: 'Re-Engagement',
    icon: Icons.touch_app,
    smallIconRes: 'ic_gesture_tap_white_24dp',
    iconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fgesture-tap.png?alt=media&token=045ddcb9-f4e5-457e-8577-baa0e264e227',
    buttons: [],
    templates: [
      NotificationTemplate(
        title: 'We Miss You!',
        message: 'It\'s been a while. Come back and see what\'s new.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Freengage.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: 'You\'re Missing Out',
        message: 'New features await you!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Freengage.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: 'Come Back!',
        message: 'Your friends are waiting for you.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Freengage.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: '',
      ),
    ],
  ),
  rating(
    group: 'Rating',
    icon: Icons.star,
    smallIconRes: 'ic_star_white_24dp',
    iconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_ICON%2Fstar.png?alt=media&token=da0987e5-a635-488f-9fba-24a1ee5d704a',
    buttons: [],
    templates: [
      NotificationTemplate(
        title: 'Enjoying the App?',
        message: 'Please take a moment to rate us!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Frating.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: 'Share Your Feedback',
        message: 'Your opinion matters to us.',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Frating.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: '',
      ),
      NotificationTemplate(
        title: 'Rate Us 5 Stars',
        message: 'Help others discover our app!',
        largeIconUrl: 'https://firebasestorage.googleapis.com/v0/b/onesignaltest-e7802.appspot.com/o/NOTIFICATION_IMAGE%2Frating.png?alt=media&token=a3f6a6e8-6bde-49f8-b4d6-cd1d7e10c042',
        bigPictureUrl: '',
      ),
    ],
  );

  const NotificationType({
    required this.group,
    required this.icon,
    required this.smallIconRes,
    required this.iconUrl,
    required this.buttons,
    required this.templates,
  });

  final String group;
  final IconData icon;
  final String smallIconRes;
  final String iconUrl;
  final List<Map<String, String>> buttons;
  final List<NotificationTemplate> templates;
}

class NotificationTemplate {
  const NotificationTemplate({
    required this.title,
    required this.message,
    required this.largeIconUrl,
    required this.bigPictureUrl,
  });

  final String title;
  final String message;
  final String largeIconUrl;
  final String bigPictureUrl;
}

/// Tracks template position for cycling through templates
final _templatePositions = <NotificationType, int>{};

int _getTemplatePos(NotificationType type) {
  final pos = _templatePositions[type] ?? 0;
  _templatePositions[type] = (pos + 1) % type.templates.length;
  return pos;
}

Future<void> sendDeviceNotification(NotificationType notification) async {
  final subscription = OneSignal.User.pushSubscription;
  final subscriptionId = subscription.id;

  if (subscriptionId == null || !(subscription.optedIn ?? false)) {
    debugPrint('Push subscription not available or not opted in');
    return;
  }

  final pos = _getTemplatePos(notification);
  final template = notification.templates[pos];

  final notificationContent = <String, dynamic>{
    'app_id': kAppId,
    'include_player_ids': [subscriptionId],
    'contents': {'en': template.message},
    'small_icon': notification.smallIconRes,
    'large_icon': template.largeIconUrl,
    'android_group': notification.group,
    'android_led_color': 'FFE9444E',
    'android_accent_color': 'FFE9444E',
    'android_sound': 'nil',
  };

  if (template.title.isNotEmpty) {
    notificationContent['headings'] = {'en': template.title};
  }

  if (template.bigPictureUrl.isNotEmpty) {
    notificationContent['big_picture'] = template.bigPictureUrl;
  }

  if (notification.buttons.isNotEmpty) {
    notificationContent['buttons'] = notification.buttons;
  }

  try {
    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
    );
    request.headers.set('Accept', 'application/vnd.onesignal.v1+json');
    request.headers.set('Content-Type', 'application/json; charset=UTF-8');
    request.write(jsonEncode(notificationContent));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200 || response.statusCode == 202) {
      debugPrint('Success sending notification: $responseBody');
    } else {
      debugPrint('Failure sending notification: $responseBody');
    }
    client.close();
  } catch (e) {
    debugPrint('Error sending notification: $e');
  }
}

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
    final tags = await OneSignal.User.getTags();
    setState(() {
      _pushId = OneSignal.User.pushSubscription.id;
      _pushEnabled = OneSignal.User.pushSubscription.optedIn ?? false;
      _tags = tags;
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
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    String selectedType = 'Normal Outcome';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'Normal Outcome',
                    child: Text('Normal Outcome'),
                  ),
                  DropdownMenuItem(
                    value: 'Unique Outcome',
                    child: Text('Unique Outcome'),
                  ),
                  DropdownMenuItem(
                    value: 'Outcome with Value',
                    child: Text('Outcome with Value'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              if (selectedType == 'Outcome with Value') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(hintText: 'Value'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  switch (selectedType) {
                    case 'Normal Outcome':
                      OneSignal.Session.addOutcome(nameController.text);
                      break;
                    case 'Unique Outcome':
                      OneSignal.Session.addUniqueOutcome(nameController.text);
                      break;
                    case 'Outcome with Value':
                      final value =
                          double.tryParse(valueController.text) ?? 0.0;
                      OneSignal.Session.addOutcomeWithValue(
                        nameController.text,
                        value,
                      );
                      break;
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('SEND'),
            ),
          ],
        ),
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
      items: _aliases.entries
          .map((e) => MapEntry(e.key, '${e.key}: ${e.value}'))
          .toList(),
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
      items: _tags.entries
          .map((e) => MapEntry(e.key, '${e.key}: ${e.value}'))
          .toList(),
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
      items: _triggers.entries
          .map((e) => MapEntry(e.key, '${e.key}: ${e.value}'))
          .toList(),
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
          children: NotificationType.values
              .map((type) => _buildPushNotificationButton(type))
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPushNotificationButton(NotificationType type) {
    return ElevatedButton(
      onPressed: () => sendDeviceNotification(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD45653),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(type.icon, size: 28),
          const SizedBox(height: 4),
          Text(
            type.group,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
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
            _buildInAppMessageButton('Top Banner', Icons.vertical_align_top),
            _buildInAppMessageButton('Bottom Banner', Icons.vertical_align_bottom),
            _buildInAppMessageButton('Center Modal', Icons.crop_square),
            _buildInAppMessageButton('Full Screen', Icons.phone_android),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInAppMessageButton(String label, IconData icon) {
    return ElevatedButton(
      onPressed: () {
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
                          icon: const Icon(
                            Icons.delete,
                            color: Color(0xFFD45653),
                          ),
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
