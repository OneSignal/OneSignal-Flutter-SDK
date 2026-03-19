import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

const String oneSignalAppId = '77e32082-ea27-42e3-a898-c72e141824ef';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  await OneSignal.initialize(oneSignalAppId);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSignal No-Location Example',
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
  String? _pushSubscriptionId;

  @override
  void initState() {
    super.initState();
    _pushSubscriptionId = OneSignal.User.pushSubscription.id;
    OneSignal.User.pushSubscription.addObserver((stateChanges) {
      setState(() {
        _pushSubscriptionId = stateChanges.current.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = _pushSubscriptionId;

    return Scaffold(
      appBar: AppBar(title: const Text('OneSignal No-Location')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Push subscription ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              id ?? '—',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Location bridge is disabled via Podfile (ONESIGNAL_LOCATION_ENABLED=0).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
