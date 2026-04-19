import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'async_prefs_notifier.dart';

/// Notifier quản lý trạng thái hiệu ứng đồ họa (Blur, Animations).
/// Sử dụng Notifier thay cho StateNotifier để tương thích tốt nhất với Riverpod 2.x.
class PerformanceNotifier extends Notifier<bool> with AsyncPrefsNotifier<bool> {
  @override
  bool build() {
    return initAsyncPrefs(
      key: prefsKey,
      defaultVal: false,
      from: (prefs) => prefs.getBool(prefsKey) ?? false,
      to: (prefs, value) => prefs.setBool(prefsKey, value),
    );
  }

  @override
  String get prefsKey => 'performance_mode';

  @override
  bool get defaultValue => false;

  @override
  bool fromPrefs(SharedPreferences prefs) => prefs.getBool(prefsKey) ?? false;

  @override
  Future<void> toPrefs(SharedPreferences prefs, bool value) => prefs.setBool(prefsKey, value);

  @override
  void updateState(bool value) => state = value;

  @override
  bool get currentValue => state;

  /// Toggle trạng thái tiết kiệm (true = tắt bớt hiệu ứng).
  void toggle() {
    state = !state;
    persist();
  }
}

/// Provider cho Performance Mode (true = Reduced Effects).
final performanceProvider = NotifierProvider<PerformanceNotifier, bool>(() {
  return PerformanceNotifier();
});
