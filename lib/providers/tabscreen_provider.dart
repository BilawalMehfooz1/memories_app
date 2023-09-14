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

  Tuple2<Widget, String> currentScreenData(BuildContext context) {
    switch (state) {
      case 1:
        return const Tuple2(AddNewMemoryScreen(), 'Add new Memory');
      case 2:
        return const Tuple2(FavoriteScreen(), 'Favorite Memories');
      default:
        return const Tuple2(HomeScreen(), 'Memories');
    }
  }
}

final tabScreenProvider = StateNotifierProvider<TabScreenNotifier, int>(
  (ref) => TabScreenNotifier(),
);
