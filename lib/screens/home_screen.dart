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
  final Set<String> _selectedMemories = Set<String>();
  bool _isSelecting = false;

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

  void _toggleSelectMemory(String memoryId) {
    setState(() {
      if (_selectedMemories.contains(memoryId)) {
        _selectedMemories.remove(memoryId);
      } else {
        _selectedMemories.add(memoryId);
      }
      _isSelecting = _selectedMemories.isNotEmpty;
    });
  }

  void _selectAll(List<DocumentSnapshot> memories) {
    setState(() {
      _selectedMemories.addAll(memories.map((e) => e.id));
    });
  }

  void _unselectAll() {
    setState(() {
      _selectedMemories.clear();
    });
  }

  void _deleteSelectedMemories() {
    for (String memoryId in _selectedMemories) {
      FirebaseFirestore.instance.collection('memories').doc(memoryId).delete();
    }
    setState(() {
      _selectedMemories.clear();
      _isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('memories')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (!_initialDataFetched &&
            snapshot.connectionState != ConnectionState.waiting) {
          _initialDataFetched = true;
        }

        final memories = snapshot.data?.docs ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(_isSelecting
                ? '${_selectedMemories.length} selected'
                : 'Memories'),
            actions: _isSelecting
                ? [
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () {
                        if (_selectedMemories.length == memories.length) {
                          _unselectAll();
                        } else {
                          _selectAll(memories);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _deleteSelectedMemories,
                    ),
                  ]
                : [],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => _buildShimmerItem(),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onLongPress: () {
                        _toggleSelectMemory(memories[index].id);
                      },
                      onTap: () {
                        if (_isSelecting) {
                          _toggleSelectMemory(memories[index].id);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MemoryDetailsScreen(
                                  memoryId: memories[index].id),
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
                              if (_selectedMemories
                                  .contains(memories[index].id))
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
                                    memories[index]['title'],
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
        );
      },
    );
  }
}
