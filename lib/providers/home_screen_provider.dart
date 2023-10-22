import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_app/screens/home_screen.dart';

final monthYearProvider = StateProvider<DateTime?>((ref) => null);
final memoryFilterProvider = StateNotifierProvider<MemoryFilterNotifier, MemoryFilter>(
  (ref) => MemoryFilterNotifier(),
);


class MemoryFilterNotifier extends StateNotifier<MemoryFilter> {
  MemoryFilterNotifier() : super(MemoryFilter.All);

  void setFilter(MemoryFilter newFilter) {
    state = newFilter;
  }
}
