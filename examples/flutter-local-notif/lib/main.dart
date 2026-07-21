import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _localChannelId = 'local-notifications';
const _testExternalId = 'flutter-local-notif-compat-test';
String _oneSignalAppId = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  final configuredAppId =
      dotenv.env['ONESIGNAL_APP_ID']?.trim() ??
      const String.fromEnvironment('ONESIGNAL_APP_ID');
  _oneSignalAppId = configuredAppId.toLowerCase().startsWith('your-')
      ? ''
      : configuredAppId;
  runApp(const NotificationExampleApp());
}

class NotificationExampleApp extends StatelessWidget {
  const NotificationExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSignal + flutter_local_notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffe54b4d)),
        scaffoldBackgroundColor: const Color(0xfff8f9fa),
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
  final _events = <_EventLog>[];

  late final OnNotificationClickListener _pushClickListener;
  late final OnNotificationWillDisplayListener _pushForegroundListener;
  late final OnNotificationPermissionChangeObserver _permissionObserver;
  late final OnPushSubscriptionChangeObserver _pushSubscriptionObserver;

  String _localPermission = 'unknown';
  bool? _oneSignalPermission;
  String? _pushSubscriptionId;
  bool _ready = false;
  bool _requestingPermission = false;
  bool _schedulingLocal = false;
  bool _sendingOneSignal = false;

  bool get _oneSignalConfigured => _oneSignalAppId.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pushClickListener = (event) {
      _appendLog(
        'OneSignal click',
        event.notification.title ?? 'OneSignal notification tapped',
        _summarizeData(event.notification.additionalData),
      );
    };
    _pushForegroundListener = (event) {
      _appendLog(
        'OneSignal foreground',
        event.notification.title ?? 'OneSignal notification received',
        _summarizeData(event.notification.additionalData),
      );
    };
    _permissionObserver = (granted) {
      if (!mounted) return;
      setState(() => _oneSignalPermission = granted);
      _appendLog(
        'OneSignal',
        'Permission ${granted ? 'granted' : 'not granted'}',
      );
    };
    _pushSubscriptionObserver = (state) {
      if (!mounted) return;
      setState(() => _pushSubscriptionId = state.current.id);
      _appendLog(
        'OneSignal',
        'Push subscription changed',
        state.current.id ?? 'No push ID',
      );
    };
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      _appendLog(
        'App',
        'Registering flutter_local_notifications before OneSignal',
      );
      tz.initializeTimeZones();

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
          _appendLog(
            'Local response',
            'Local notification tapped',
            response.payload,
          );
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

      await _refreshLocalPermission();

      if (_oneSignalConfigured) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
        await OneSignal.initialize(_oneSignalAppId);
        await OneSignal.login(_testExternalId);
        OneSignal.User.pushSubscription.addObserver(_pushSubscriptionObserver);
        OneSignal.Notifications.addClickListener(_pushClickListener);
        OneSignal.Notifications.addPermissionObserver(_permissionObserver);
        OneSignal.Notifications.addForegroundWillDisplayListener(
          _pushForegroundListener,
        );
        _refreshOneSignalState();
      } else {
        _appendLog(
          'OneSignal',
          'Set ONESIGNAL_APP_ID before testing OneSignal callbacks',
        );
      }

      if (!mounted) return;
      setState(() => _ready = true);
    } catch (error) {
      _showError('Initialization failed', error);
    }
  }

  Future<void> _refreshLocalPermission() async {
    bool? granted;
    if (defaultTargetPlatform == TargetPlatform.android) {
      granted = await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final permissions = await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      granted = permissions?.isEnabled;
    }
    if (!mounted) return;
    setState(() {
      _localPermission = granted == null
          ? 'unknown'
          : granted
          ? 'granted'
          : 'denied';
    });
  }

  void _refreshOneSignalState() {
    if (!mounted) return;
    setState(() {
      _oneSignalPermission = OneSignal.Notifications.permission;
      _pushSubscriptionId = OneSignal.User.pushSubscription.id;
    });
  }

  Future<void> _requestPermissions() async {
    setState(() => _requestingPermission = true);
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      if (_oneSignalConfigured) {
        _oneSignalPermission = await OneSignal.Notifications.requestPermission(
          false,
        );
      }

      await _refreshLocalPermission();
      _refreshOneSignalState();
      _appendLog('App', 'Permission request complete');
    } catch (error) {
      _showError('Permission request failed', error);
    } finally {
      if (mounted) setState(() => _requestingPermission = false);
    }
  }

  Future<void> _scheduleLocalNotification() async {
    setState(() => _schedulingLocal = true);
    try {
      await _localNotifications.zonedSchedule(
        id: 1,
        title: 'Flutter local notification',
        body:
            'Tap this to test the flutter_local_notifications response callback.',
        payload: jsonEncode({'route': 'chat/123', 'source': 'flutter-local'}),
        scheduledDate: tz.TZDateTime.now(
          tz.local,
        ).add(const Duration(seconds: 2)),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
      _appendLog(
        'Local scheduled',
        'Local notification scheduled',
        '2 seconds',
      );
    } catch (error) {
      _showError('Schedule failed', error);
    } finally {
      if (mounted) setState(() => _schedulingLocal = false);
    }
  }

  Future<void> _sendOneSignalNotification() async {
    if (!_oneSignalConfigured) {
      _showError(
        'Configure OneSignal',
        'Pass ONESIGNAL_APP_ID with --dart-define before sending a push.',
      );
      return;
    }

    final subscriptionId = _pushSubscriptionId;
    if (subscriptionId == null) {
      _showError(
        'No push subscription',
        'Request permission, then wait for a OneSignal push ID.',
      );
      return;
    }

    setState(() => _sendingOneSignal = true);
    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: const {
          'Accept': 'application/vnd.onesignal.v1+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'include_subscription_ids': [subscriptionId],
          'headings': {'en': 'OneSignal notification'},
          'contents': {
            'en': 'Tap this to compare local and OneSignal response listeners.',
          },
          'data': {'route': 'chat/123', 'source': 'onesignal-api'},
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(response.body);
      }
      _appendLog(
        'OneSignal sent',
        'Remote notification requested',
        subscriptionId,
      );
    } catch (error) {
      _showError('Send failed', error);
    } finally {
      if (mounted) setState(() => _sendingOneSignal = false);
    }
  }

  void _appendLog(String source, String title, [String? detail]) {
    if (!mounted) return;
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    setState(() {
      _events.insert(
        0,
        _EventLog(at: time, source: source, title: title, detail: detail),
      );
      if (_events.length > 20) _events.removeLast();
    });
    debugPrint('[$source] $title ${detail ?? ''}');
  }

  String? _summarizeData(Object? data) {
    if (data == null) return null;
    return jsonEncode(data);
  }

  void _showError(String title, Object error) {
    _appendLog(title, title, error.toString());
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title: $error')));
  }

  @override
  void dispose() {
    if (_oneSignalConfigured) {
      OneSignal.User.pushSubscription.removeObserver(_pushSubscriptionObserver);
      OneSignal.Notifications.removeClickListener(_pushClickListener);
      OneSignal.Notifications.removePermissionObserver(_permissionObserver);
      OneSignal.Notifications.removeForegroundWillDisplayListener(
        _pushForegroundListener,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            Text(
              'OneSignal + flutter_local_notifications',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test whether local notification response callbacks still fire '
              'when OneSignal is installed and initialized.',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _StatusRow(
                      label: 'Platform',
                      value: defaultTargetPlatform.name,
                    ),
                    _StatusRow(
                      label: 'Local permission',
                      value: _localPermission,
                    ),
                    _StatusRow(
                      label: 'OneSignal permission',
                      value: _oneSignalPermission == null
                          ? 'unknown'
                          : _oneSignalPermission!
                          ? 'granted'
                          : 'denied',
                    ),
                    _StatusRow(
                      label: 'OneSignal app ID',
                      value: _oneSignalConfigured
                          ? _oneSignalAppId
                          : 'not configured',
                    ),
                    _StatusRow(
                      label: 'OneSignal push ID',
                      value: _pushSubscriptionId ?? 'waiting',
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              busy: _requestingPermission,
              enabled: _ready,
              label: 'Request Permissions',
              onPressed: _requestPermissions,
            ),
            _ActionButton(
              busy: _schedulingLocal,
              enabled: _ready,
              label: 'Schedule Flutter Local Notification',
              onPressed: _scheduleLocalNotification,
            ),
            _ActionButton(
              busy: _sendingOneSignal,
              enabled: _ready,
              label: 'Send OneSignal Push',
              onPressed: _sendOneSignalNotification,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EVENT LOG',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(_events.clear),
                  child: const Text('Clear'),
                ),
              ],
            ),
            if (_events.isEmpty)
              const Text('No events yet.', style: TextStyle(color: Colors.grey))
            else
              ..._events.map((event) => _EventLogCard(event: event)),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xffeceff1)))
            : null,
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.busy,
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool busy;
  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: enabled && !busy ? onPressed : null,
          child: busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(label.toUpperCase()),
        ),
      ),
    );
  }
}

class _EventLog {
  const _EventLog({
    required this.at,
    required this.source,
    required this.title,
    this.detail,
  });

  final String at;
  final String source;
  final String title;
  final String? detail;
}

class _EventLogCard extends StatelessWidget {
  const _EventLogCard({required this.event});

  final _EventLog event;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event.at} · ${event.source}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (event.detail != null) ...[
              const SizedBox(height: 6),
              Text(
                event.detail!,
                style: const TextStyle(
                  color: Colors.black54,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
