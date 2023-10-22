import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:memories_app/providers/selection_notifier.dart';
import 'package:memories_app/screens/memories_detail_screen.dart';

enum MemoryFilter {
  All,
  Old,
  MonthYear,
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionNotifier = ref.watch(selectionNotifierProvider);
    final filterNotifier = useState<MemoryFilter>(MemoryFilter.All);
    final monthYearNotifier = useState<DateTime?>(null);

    void deleteSelectedMemories() async {
      for (String memoryId in selectionNotifier.selectedMemories) {
        await FirebaseFirestore.instance.collection('memories').doc(memoryId).delete();
      }
      selectionNotifier.clearSelection();
    }

    Stream<QuerySnapshot> getMemoriesStream() {
      final query = FirebaseFirestore.instance.collection('memories');

      switch (filterNotifier.value) {
        case MemoryFilter.All:
          return query.orderBy('createdAt', descending: true).snapshots();
        case MemoryFilter.Old:
          final lastYear = DateTime.now().subtract(Duration(days: 365));
          return query.where('createdAt', isLessThanOrEqualTo: lastYear).orderBy('createdAt').snapshots();
        case MemoryFilter.MonthYear:
          if (monthYearNotifier.value == null) {
            return query.snapshots(); // Default to all if no month/year is specified.
          }
          final start = DateTime(monthYearNotifier.value!.year, monthYearNotifier.value!.month);
          final end = DateTime(monthYearNotifier.value!.year, monthYearNotifier.value!.month + 1);
          return query.where('createdAt', isGreaterThanOrEqualTo: start).where('createdAt', isLessThan: end).orderBy('createdAt').snapshots();
        default:
          return query.snapshots();
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _filterOption('All', MemoryFilter.All, filterNotifier),
            _filterOption('Old', MemoryFilter.Old, filterNotifier),
            DropdownButton<MemoryFilter>(
              value: filterNotifier.value,
              onChanged: (MemoryFilter? newValue) {
                if (newValue == MemoryFilter.MonthYear) {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      monthYearNotifier.value = pickedDate;
                      filterNotifier.value = newValue!;
                    }
                  });
                } else {
                  filterNotifier.value = newValue!;
                }
              },
              items: <DropdownMenuItem<MemoryFilter>>[
                DropdownMenuItem<MemoryFilter>(
                  value: MemoryFilter.MonthYear,
                  child: Text('Select Month & Year'),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: getMemoriesStream(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => _buildShimmerItem(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No memories found.'));
              }

              final memories = snapshot.data!.docs;

              return Stack(
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      final isSelected = selectionNotifier.selectedMemories.contains(memory.id);
return InkWell(
                        onTap: () {
                          if (selectionNotifier.isSelecting) {
                            selectionNotifier.toggleMemorySelection(memory.id);
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    MemoryDetailsScreen(memoryId: memory.id),
                              ),
                            );
                          }
                        },
                        onLongPress: () {
                          selectionNotifier.toggleMemorySelection(memory.id);
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Image.network(
                                  memory['imageUrl'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green[700],
                                      size: 30.0,
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.black54,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      memory['title'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (selectionNotifier.isSelecting)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          color: Colors.white,
                          child: Center(
                            child: Container(
                              width: 100,
                              color: Colors.transparent,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                  size: 35,
                                ),
                                onPressed: deleteSelectedMemories,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterOption(String title, MemoryFilter option, ValueNotifier<MemoryFilter> notifier) {
    return GestureDetector(
      onTap: () {
        notifier.value = option;
      },
      child: Text(
        title,
        style: TextStyle(
          color: notifier.value == option ? Colors.blue : Colors.black,
          fontWeight: notifier.value == option ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
