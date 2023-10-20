import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionNotifier extends ChangeNotifier {
  final Set<String> _selectedMemories = {};

  Set<String> get selectedMemories => _selectedMemories;

  bool get isSelecting => _selectedMemories.isNotEmpty;

  void toggleMemorySelection(String memoryId) {
    if (_selectedMemories.contains(memoryId)) {
      _selectedMemories.remove(memoryId);
    } else {
      _selectedMemories.add(memoryId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedMemories.clear();
    notifyListeners();
  }

  void selectAll(List<String> memoryIds) {
    _selectedMemories.addAll(memoryIds);
    notifyListeners();
  }
}

final selectionNotifierProvider = ChangeNotifierProvider((ref) => SelectionNotifier());
