import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

const _defaultOneSignalAppId = 'YOUR-ONESIGNAL-APP-ID';
const _brandRed = Color(0xFFE54B4D);

late final String _oneSignalAppId;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('.env file not found, using defaults');
  }

  final envAppId = dotenv.env['ONESIGNAL_APP_ID']?.trim();
  _oneSignalAppId =
      envAppId != null && envAppId.isNotEmpty
          ? envAppId
          : _defaultOneSignalAppId;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: _brandRed,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const NoLocationDemoApp());
}

class NoLocationDemoApp extends StatelessWidget {
  const NoLocationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSignal No-Location Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _brandRed),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: const NoLocationDemoScreen(),
    );
  }
}

class NoLocationDemoScreen extends StatefulWidget {
  const NoLocationDemoScreen({super.key});

  @override
  State<NoLocationDemoScreen> createState() => _NoLocationDemoScreenState();
}

class _NoLocationDemoScreenState extends State<NoLocationDemoScreen> {
  bool? _hasNotificationPermission;
  String? _pushSubscriptionId;
  bool _requestingPermission = false;
  bool _sending = false;
  late final OnPushSubscriptionChangeObserver _pushSubscriptionObserver;
  late final OnNotificationPermissionChangeObserver _permissionObserver;

  bool get _isPlaceholderAppId =>
      _oneSignalAppId.toLowerCase().startsWith('your-');

  @override
  void initState() {
    super.initState();
    _pushSubscriptionObserver = (state) {
      debugPrint('Push subscription state: ${state.jsonRepresentation()}');
      if (!mounted) return;
      setState(() {
        _pushSubscriptionId = state.current.id;
      });
    };
    _permissionObserver = (permission) {
      debugPrint('Permission changed: $permission');
      if (!mounted) return;
      setState(() {
        _hasNotificationPermission = permission;
      });
    };
    OneSignal.User.pushSubscription.addObserver(_pushSubscriptionObserver);
    OneSignal.Notifications.addPermissionObserver(_permissionObserver);
    _initializeOneSignal();
  }

  @override
  void dispose() {
    OneSignal.User.pushSubscription.removeObserver(_pushSubscriptionObserver);
    OneSignal.Notifications.removePermissionObserver(_permissionObserver);
    super.dispose();
  }

  Future<void> _initializeOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    try {
      await OneSignal.initialize(_oneSignalAppId);
      _refreshPushState();
    } catch (error) {
      debugPrint('OneSignal initialization failed: $error');
    }
  }

  void _refreshPushState() {
    if (!mounted) return;
    setState(() {
      _hasNotificationPermission = OneSignal.Notifications.permission;
      _pushSubscriptionId = OneSignal.User.pushSubscription.id;
    });
  }

  Future<void> _requestNotificationPermission() async {
    setState(() {
      _requestingPermission = true;
    });

    try {
      final granted = await OneSignal.Notifications.requestPermission(false);
      if (!mounted) return;
      setState(() {
        _hasNotificationPermission = granted;
        _pushSubscriptionId = OneSignal.User.pushSubscription.id;
      });
    } catch (error) {
      _showMessage('Permission request failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _requestingPermission = false;
        });
      }
    }
  }

  Future<void> _testLocationPermissionRequest() async {
    try {
      await OneSignal.Location.requestPermission();
      debugPrint('OneSignal.Location.requestPermission did not throw.');
    } catch (error) {
      debugPrint('OneSignal.Location.requestPermission failed: $error');
    }
  }

  Future<void> _sendTestNotification() async {
    if (_isPlaceholderAppId) {
      _showMessage(
        'Set ONESIGNAL_APP_ID in .env before sending a test push.',
      );
      return;
    }

    if (_hasNotificationPermission != true) {
      _showMessage(
        'Request notification permission before sending a test push.',
      );
      return;
    }

    final pushSubscriptionId = _pushSubscriptionId;
    if (pushSubscriptionId == null || pushSubscriptionId.isEmpty) {
      _showMessage('Allow notifications, then wait for a push ID.');
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: const {
          'Accept': 'application/vnd.onesignal.v1+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'include_subscription_ids': [pushSubscriptionId],
          'headings': {'en': 'OneSignal No-Location Demo'},
          'contents': {
            'en':
                'This test push was sent without linking the location module.',
          },
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _showMessage('Send failed: ${response.body}');
      }
    } catch (error) {
      _showMessage('Send failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandRed,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: _brandRed,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OneSignal'),
            Text(
              'No-Location Demo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _Section(
            title: 'App',
            child: _InfoRow(label: 'App ID', value: _oneSignalAppId),
          ),
          _Section(
            title: 'Push',
            child: Column(
              children: [
                _InfoRow(label: 'Permission', value: _permissionText),
                const Divider(height: 17),
                _InfoRow(label: 'Push ID', value: _pushSubscriptionId ?? '-'),
                const Divider(height: 17),
                _PrimaryButton(
                  label: 'REQUEST PERMISSION',
                  isLoading: _requestingPermission,
                  onPressed: _requestNotificationPermission,
                ),
                const SizedBox(height: 8),
                _PrimaryButton(
                  label: 'SEND TEST NOTIFICATION',
                  isLoading: _sending,
                  onPressed: _sendTestNotification,
                ),
              ],
            ),
          ),
          _Section(
            title: 'Location Module',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'This demo initializes OneSignal and requests notification '
                  'permission only when you tap the button above. Native build '
                  'flags exclude the location module. The location test call may '
                  'not log a Dart error; check Android Logcat or Xcode logs for '
                  'native diagnostics.',
                  style: TextStyle(color: Color(0xFF616161), fontSize: 16),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _brandRed,
                    side: const BorderSide(color: _brandRed),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _testLocationPermissionRequest,
                  child: const Text('TEST LOCATION REQUEST'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _permissionText {
    final permission = _hasNotificationPermission;
    if (permission == null) return 'Unknown';
    return permission ? 'Granted' : 'Not granted';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF616161),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0x1A000000), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(padding: const EdgeInsets.all(12), child: child),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF616161),
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandRed,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _brandRed.withAlpha(128),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: isLoading ? null : onPressed,
      child:
          isLoading
              ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : Text(label),
    );
  }
}
