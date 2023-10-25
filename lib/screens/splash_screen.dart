import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Memories',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
      body: Center(
        child: Text('Loading...',
            style:
                TextStyle(color: Theme.of(context).colorScheme.onBackground)),
      ),
    );
  }
}
