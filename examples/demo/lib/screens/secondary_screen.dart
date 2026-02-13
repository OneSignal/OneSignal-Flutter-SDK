import 'package:flutter/material.dart';

class SecondaryScreen extends StatelessWidget {
  const SecondaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secondary Activity'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Secondary Activity',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
