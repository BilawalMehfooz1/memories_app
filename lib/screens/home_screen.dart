import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:memories_app/providers/selection_notifier.dart';
import 'package:memories_app/screens/memories_detail_screen.dart';
import 'package:connectivity/connectivity.dart';

enum MemoryFilter { all, oldest, monthYear }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MemoryFilter _selectedFilter = MemoryFilter.all;
  DateTime? _selectedMonthYear = DateTime.now();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _refreshData(); // Refresh when internet connectivity is restored
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

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
  Widget build(BuildContext context) {
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

    Stream<QuerySnapshot> getMemoriesStream() {
      final query = FirebaseFirestore.instance.collection('memories');
      switch (_selectedFilter) {
        case MemoryFilter.all:
          return query.orderBy('createdAt', descending: true).snapshots();
        case MemoryFilter.oldest:
          return query.orderBy('createdAt', descending: false).snapshots();
        case MemoryFilter.monthYear:
          final start =
              DateTime(_selectedMonthYear!.year, _selectedMonthYear!.month);
          final end =
              DateTime(_selectedMonthYear!.year, _selectedMonthYear!.month + 1);
          return query
              .where('createdAt', isGreaterThanOrEqualTo: start)
              .where('createdAt', isLessThan: end)
              .snapshots();
        default:
          return query.snapshots();
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton('All', MemoryFilter.all),
                _filterButton('Oldest', MemoryFilter.oldest),
                _filterButton('Choose', MemoryFilter.monthYear,
                    additionalLogic: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      setState(() {
                        _selectedMonthYear = pickedDate;
                        _selectedFilter = MemoryFilter.monthYear;
                      });
                    }
                  });
                }),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: StreamBuilder<QuerySnapshot>(
                stream: getMemoriesStream(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                selectionNotifier
                                    .toggleMemorySelection(memory.id);
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MemoryDetailsScreen(
                                        memoryId: memory.id),
                                  ),
                                );
                              }
                            },
                            onLongPress: () {
                              selectionNotifier
                                  .toggleMemorySelection(memory.id);
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
                                    CachedNetworkImage(
                                        imageUrl: memory['imageUrl'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        placeholder: (context, url) =>
                                            _buildShimmerItem(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error)),
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
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
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label, MemoryFilter filter,
      {VoidCallback? additionalLogic}) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor:
            _selectedFilter == filter ? Colors.white : Colors.transparent,
        foregroundColor: _selectedFilter == filter ? Colors.black : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
        if (additionalLogic != null) additionalLogic();
      },
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
