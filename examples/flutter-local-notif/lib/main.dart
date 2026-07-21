import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

const _oneSignalAppId = String.fromEnvironment('ONESIGNAL_APP_ID');
const _localChannelId = 'local-notifications';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NotificationExampleApp());
}

class NotificationExampleApp extends StatelessWidget {
  const NotificationExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSignal + Local Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffe54b4d)),
        useMaterial3: true,
      ),
      home: const NotificationHomePage(),
    );
  }
}

class NotificationHomePage extends StatefulWidget {
  const NotificationHomePage({super.key});

  @override
  State<NotificationHomePage> createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePage> {
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _events = <String>[];

  late final OnNotificationClickListener _pushClickListener;
  late final OnNotificationWillDisplayListener _pushForegroundListener;

  bool _ready = false;
  String _status = 'Initializing notification SDKs...';

  bool get _oneSignalConfigured => _oneSignalAppId.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pushClickListener = (event) {
      _recordEvent(
        'OneSignal push opened: ${event.notification.title ?? 'Untitled'}',
      );
    };
    _pushForegroundListener = (event) {
      _recordEvent(
        'OneSignal push received in foreground: '
        '${event.notification.title ?? 'Untitled'}',
      );
    };
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Register the local notification delegate before OneSignal so iOS can
      // preserve both integrations when OneSignal chains the existing delegate.
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          _recordEvent('Local notification opened: ${response.payload}');
        },
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _localChannelId,
              'Local notifications',
              description: 'Notifications created locally by the example app',
              importance: Importance.high,
            ),
          );

      if (_oneSignalConfigured) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
        await OneSignal.initialize(_oneSignalAppId);
        OneSignal.Notifications.addClickListener(_pushClickListener);
        OneSignal.Notifications.addForegroundWillDisplayListener(
          _pushForegroundListener,
        );
      }

      if (!mounted) return;
      setState(() {
        _ready = true;
        _status = _oneSignalConfigured
            ? 'Both notification SDKs are ready.'
            : 'Local notifications are ready. Add ONESIGNAL_APP_ID to enable push.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = 'Initialization failed: $error';
      });
    }
  }

  Future<void> _requestPermission() async {
    bool? granted;
    if (_oneSignalConfigured) {
      granted = await OneSignal.Notifications.requestPermission(true);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      granted = await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      granted = await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    _recordEvent('Notification permission: ${granted ?? 'not available'}');
  }

  Future<void> _showLocalNotification() async {
    await _localNotifications.show(
      id: 1,
      title: 'Local notification',
      body: 'Created by flutter_local_notifications.',
      payload: 'local-example',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _localChannelId,
          'Local notifications',
          channelDescription:
              'Notifications created locally by the example app',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
    _recordEvent('Local notification displayed.');
  }

  void _recordEvent(String event) {
    if (!mounted) return;
    setState(() {
      _events.insert(0, event);
      if (_events.length > 10) _events.removeLast();
    });
  }

  @override
  void dispose() {
    if (_oneSignalConfigured) {
      OneSignal.Notifications.removeClickListener(_pushClickListener);
      OneSignal.Notifications.removeForegroundWillDisplayListener(
        _pushForegroundListener,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OneSignal + Local Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(
            oneSignalConfigured: _oneSignalConfigured,
            ready: _ready,
            status: _status,
          ),
          const SizedBox(height: 16),
          Text('Try it', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _ready ? _requestPermission : null,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Request notification permission'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _ready ? _showLocalNotification : null,
            icon: const Icon(Icons.add_alert_outlined),
            label: const Text('Show local notification'),
          ),
          const SizedBox(height: 24),
          Text('Events', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_events.isEmpty)
            const Text('Notification events will appear here.')
          else
            ..._events.map(
              (event) => Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: Text(event),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.oneSignalConfigured,
    required this.ready,
    required this.status,
  });

  final bool oneSignalConfigured;
  final bool ready;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ready ? Icons.check_circle : Icons.hourglass_top),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('flutter_local_notifications: ${ready ? 'ready' : 'loading'}'),
            Text(
              'onesignal_flutter: '
              '${oneSignalConfigured ? (ready ? 'ready' : 'loading') : 'not configured'}',
            ),
          ],
        ),
      ),
    );
  }
}
