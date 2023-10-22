import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_app/screens/home_screen.dart';

final memoryFilterProvider = StateProvider<MemoryFilter>((ref) => MemoryFilter.All);
final monthYearProvider = StateProvider<DateTime?>((ref) => null);
