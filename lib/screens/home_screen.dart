import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Memories'),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         FirebaseAuth.instance.signOut();
      //       },
      //       icon: const Icon(Icons.exit_to_app),
      //     ),
      //   ],
      // ),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
