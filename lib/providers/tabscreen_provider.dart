import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memories_app/screens/add_memory_screen.dart';
import 'package:memories_app/screens/favorites_screen.dart';
import 'package:memories_app/screens/home_screen.dart';

import 'package:tuple/tuple.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabScreenNotifier extends StateNotifier<int> {
  TabScreenNotifier() : super(0);

  void changeScreen(int index) {
    state = index;
  }

  Tuple3<Widget, String, List<Widget>> currentScreenData(BuildContext context) {
    switch (state) {
      case 1:
        return const Tuple3(AddNewMemoryScreen(), 'Add new Memory', []);
      case 2:
        return const Tuple3(FavoriteScreen(), 'Favorite Memories', []);
      default:
        List<Widget> homeActions = [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ];
        return Tuple3(const HomeScreen(), 'Memories', homeActions);
    }
  }
}

final tabScreenProvider = StateNotifierProvider<TabScreenNotifier, int>(
  (ref) => TabScreenNotifier(),
);
