import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceNotifier extends AsyncNotifier<bool> {
  static const _key = 'performance_mode';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !(state.value ?? false);
    await prefs.setBool(_key, next);
    state = AsyncValue.data(next);
  }
}

final performanceProvider =
    AsyncNotifierProvider<PerformanceNotifier, bool>(PerformanceNotifier.new);

bool readPerformance(WidgetRef ref) {
  return ref.watch(performanceProvider).value ?? false;
}
