import 'package:memories_app/screens/setting_screen.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memories_app/screens/home_screen.dart';
import 'package:memories_app/screens/favorites_screen.dart';
import 'package:memories_app/screens/add_memory_screen.dart';

enum MenuOptions { setting }

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
          PopupMenuButton<MenuOptions>(
            offset: const Offset(0, 50),
            elevation: 3.2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            icon: const Icon(Icons.more_vert),
            onSelected: (MenuOptions result) {
              switch (result) {
                case MenuOptions.setting:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<MenuOptions>>[
              const PopupMenuItem<MenuOptions>(
                value: MenuOptions.setting,
                child: Text('Settings'),
              ),
            ],
          )
        ];
        return Tuple3(const HomeScreen(), 'Memories', homeActions);
    }
  }
}

final tabScreenProvider = StateNotifierProvider<TabScreenNotifier, int>(
  (ref) => TabScreenNotifier(),
);
