import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

const String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';

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
      home: Scaffold(
        appBar: AppBar(title: const Text('OneSignal No-Location')),
        body: const Center(
          child: Text('OneSignal initialized without location module.'),
        ),
      ),
    );
  }
}
