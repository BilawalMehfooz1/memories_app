import 'package:flutter/material.dart';
import 'package:memories_app/screens/memories_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_app/providers/selection_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

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

    void deleteSelectedMemories() async {
      for (String memoryId in selectionNotifier.selectedMemories) {
        await FirebaseFirestore.instance
            .collection('memories')
            .doc(memoryId)
            .delete();
      }
      selectionNotifier.clearSelection();
    }

    void selectAllMemories(List<DocumentSnapshot> memories) {
      memories.forEach((memory) {
        selectionNotifier.toggleMemorySelection(memory.id);
      });
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('memories')
                .orderBy('createdAt', descending: true)
                .snapshots(),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      final isSelected = selectionNotifier.selectedMemories
                          .contains(memory.id);

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
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.checklist,
                                  color: Colors.white),
                              onPressed: () {
                                if (snapshot.data != null) {
                                  selectAllMemories(snapshot.data!.docs);
                                }
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                              onPressed: deleteSelectedMemories,
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.clear, color: Colors.white),
                              onPressed: selectionNotifier.clearSelection,
                            ),
                          ],
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
}
