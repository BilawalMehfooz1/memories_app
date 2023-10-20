import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectionNotifierProvider =
    ChangeNotifierProvider((ref) => SelectionNotifier());

final memoryIdsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('memories')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
});

class SelectionNotifier extends ChangeNotifier {
  final Set<String> _selectedMemories = {};

  Set<String> get selectedMemories => _selectedMemories;

  bool _forceSelecting = false; // A flag to force the selection mode
  bool get isSelecting => _selectedMemories.isNotEmpty || _forceSelecting;

  void toggleMemorySelection(String memoryId) {
    if (_selectedMemories.contains(memoryId)) {
      _selectedMemories.remove(memoryId);
    } else {
      _selectedMemories.add(memoryId);
    }
    _forceSelecting = true; // Stay in selection mode
    notifyListeners();
  }

  void clearSelection() {
    _selectedMemories.clear();
    _forceSelecting = true; // Stay in selection mode
    notifyListeners();
  }

  void deSelectAll() {
    _selectedMemories.clear();
    _forceSelecting = false;
    notifyListeners();
  }

  void selectAll(List<String> memoryIds) {
    _selectedMemories.addAll(memoryIds);
    _forceSelecting = false; // Resetting the flag since all items are selected
    notifyListeners();
  }

  void toggleSelectAll(List<String> memoryIds) {
    if (_selectedMemories.length == memoryIds.length) {
      clearSelection();
    } else {
      selectAll(memoryIds);
    }
  }
}
