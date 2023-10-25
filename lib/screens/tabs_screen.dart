import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memories_app/providers/tabscreen_provider.dart';
import 'package:memories_app/providers/selection_notifier.dart';

class TabsScreen extends ConsumerWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMemoryIds = ref.watch(memoryIdsProvider);
    final currentTabIndex = ref.watch(tabScreenProvider);
    final selectionNotifier = ref.watch(selectionNotifierProvider);
    final currentScreenData =
        ref.read(tabScreenProvider.notifier).currentScreenData(context);

    return Scaffold(
      appBar: selectionNotifier.isSelecting
          ? AppBar(
              title:
                  Text('${selectionNotifier.selectedMemories.length} selected'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // Resetting the selection mode by clearing selected items
                  selectionNotifier.deSelectAll();
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.checklist),
                  onPressed: () {
                    allMemoryIds.when(
                      data: (dataList) {
                        selectionNotifier.toggleSelectAll(dataList);
                      },
                      loading: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Fetching data... Please wait.')),
                        );
                      },
                      error: (error, stack) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('An error occurred: $error')),
                        );
                      },
                    );
                  },
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
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              currentIndex: currentTabIndex,
              selectedItemColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              unselectedItemColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[500]
                      : Colors.grey[600],
              onTap: (value) {
                ref.read(tabScreenProvider.notifier).changeScreen(value);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTabIndex == 0 ? Icons.home : Icons.home_outlined,
                    size: 25,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTabIndex == 1
                        ? Icons.add_circle
                        : Icons.add_circle_outline,
                    size: 30,
                  ),
                  label: 'Add',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    currentTabIndex == 2
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 25,
                  ),
                  label: 'Favorites',
                ),
              ],
            ),
    );
  }
}
