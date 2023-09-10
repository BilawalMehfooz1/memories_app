import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memories_app/screens/add_screen.dart';
import 'package:memories_app/screens/favorites_screen.dart';
import 'package:memories_app/screens/home_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  var currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      const AddNewScreen(),
      const FavoriteScreen(),
    ];
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
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
