import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_app/providers/tabscreen_provider.dart';

class TabsScreen extends ConsumerWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changeScreen = ref.watch(tabScreenProvider);
    final currentScreenData =
        ref.read(tabScreenProvider.notifier).currentScreenData(context);

    return Scaffold(
      body: currentScreenData.item1,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: changeScreen,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (value) {
          ref.read(tabScreenProvider.notifier).changeScreen(value);
        },
        items: [
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  changeScreen == 0 ? Icons.home : Icons.home_outlined,
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
                changeScreen == 1 ? Icons.add_circle : Icons.add_circle_outline,
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
                  changeScreen == 2 ? Icons.favorite : Icons.favorite_border,
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
