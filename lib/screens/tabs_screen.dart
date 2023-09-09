import 'package:flutter/material.dart';
import 'package:memories_app/screens/home_screen.dart';

class TabsScreen extends StatelessWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentIndex = 0;
    Widget? activeScreen;
    if (currentIndex == 0) {
      activeScreen = const HomeScreen();
    }
    return Scaffold(
      body: activeScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (value) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'ADD'),
        ],
      ),
    );
  }
}
