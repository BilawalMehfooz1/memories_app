import 'package:flutter/material.dart';
import 'package:memories_app/providers/tabscreen_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreen extends ConsumerWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changeScreen = ref.watch(tabScreenProvider);
    final currentScreenData =
        ref.read(tabScreenProvider.notifier).currentScreenData(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentScreenData.item2),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: currentScreenData.item1,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: changeScreen,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (value) {
          ref.read(provider)
        },
        items: [
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentIndex == 0 ? Icons.home : Icons.home_outlined,
                  size: 25,
                ),
                const Text(
                  'Home',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: Icon(
                currentIndex == 1 ? Icons.add_circle : Icons.add_circle_outline,
                size: 45,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentIndex == 2 ? Icons.favorite : Icons.favorite_border,
                  size: 25,
                ),
                const Text(
                  'Favorites',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
