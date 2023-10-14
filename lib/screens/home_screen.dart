import 'package:flutter/material.dart';
import 'package:memories_app/screens/memories_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialDataFetched = false;
  Set<String> _selectedMemoryIds = Set<String>();
  bool _showAppBar = true;

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

  void _deleteSelectedMemories() {
    for (String id in _selectedMemoryIds) {
      FirebaseFirestore.instance.collection('memories').doc(id).delete();
    }
    setState(() {
      _selectedMemoryIds.clear();
      _showAppBar = true;
    });
  }

  void _toggleMemorySelection(String memoryId) {
    setState(() {
      if (_selectedMemoryIds.contains(memoryId)) {
        _selectedMemoryIds.remove(memoryId);
      } else {
        _selectedMemoryIds.add(memoryId);
      }
      _showAppBar = _selectedMemoryIds.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              title: const Text('Memories'),
            )
          : AppBar(
              title: Text('${_selectedMemoryIds.length} selected'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedMemoryIds.clear();
                    _showAppBar = true;
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _selectedMemoryIds.isEmpty
                      ? null
                      : () => _deleteSelectedMemories(),
                ),
              ],
            ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('memories')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (!_initialDataFetched &&
              snapshot.connectionState != ConnectionState.waiting) {
            _initialDataFetched = true;
          }

          if (!_initialDataFetched ||
              snapshot.connectionState == ConnectionState.waiting) {
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
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () {
                  _toggleMemorySelection(memories[index].id);
                },
                onTap: () {
                  if (_selectedMemoryIds.isNotEmpty) {
                    _toggleMemorySelection(memories[index].id);
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            MemoryDetailsScreen(memoryId: memories[index].id),
                      ),
                    );
                  }
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
                          memories[index]['imageUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              memories[index]['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black87,
                                    offset: Offset(0.0, 1.0),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}
