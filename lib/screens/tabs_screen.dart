import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_app/providers/tabscreen_provider.dart';
import 'package:memories_app/providers/selection_notifier.dart';

class TabsScreen extends ConsumerWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionNotifier = ref.watch(selectionNotifierProvider);
    final currentTabIndex = ref.watch(tabScreenProvider);
    final currentScreenData =
        ref.read(tabScreenProvider.notifier).currentScreenData(context);

    return Scaffold(
      appBar: selectionNotifier.isSelecting
          ? AppBar(
              title:
                  Text('${selectionNotifier.selectedMemories.length} selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () => selectionNotifier.clearSelection(),
                ),
              ],
            )
          : AppBar(
              title: Text(currentScreenData.item2),
              actions: currentScreenData.item3,
            ),
      body: currentScreenData.item1,
      bottomNavigationBar: selectionNotifier.isSelecting
          ? null
          : BottomNavigationBar(
              currentIndex: currentTabIndex,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black,
              onTap: (value) {
                ref.read(tabScreenProvider.notifier).changeScreen(value);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTabIndex == 0 ? Icons.home : Icons.home_outlined,
                    size: 28,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTabIndex == 1
                        ? Icons.add_circle
                        : Icons.add_circle_outline,
                    size: 35,
                  ),
                  label: 'Add',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTabIndex == 2
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 28,
                  ),
                  label: 'Favorites',
                ),
              ],
            ),
    );
  }
}
