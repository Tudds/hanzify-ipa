// lib/core/providers/async_prefs_notifier.dart
// Base notifier cho các setting lưu bằng SharedPreferences.
// Loại bỏ code trùng lặp giữa ShowPinyin và ThemeNotifier.

import 'package:shared_preferences/shared_preferences.dart';

/// Base class cho các Riverpod Notifier cần persist state vào SharedPreferences.
///
/// Usage:
/// ```dart
/// @Riverpod(keepAlive: true)
/// class MySetting extends _$MySetting {
///   @override
///   bool build() => initAsyncPrefs(
///     prefsKey: 'my_setting',
///     defaultValue: true,
///     fromPrefs: (prefs) => prefs.getBool('my_setting') ?? true,
///     toPrefs: (prefs, value) => prefs.setBool('my_setting', value),
///   );
/// }
/// ```
mixin AsyncPrefsNotifier<T> {
  /// SharedPreferences instance — lazy-loaded và cached.
  SharedPreferences? _cachedPrefs;

  /// Lấy SharedPreferences instance (cached).
  Future<SharedPreferences> get _prefs async {
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }

  /// Key dùng để lưu trữ giá trị trong SharedPreferences.
  String get prefsKey;

  /// Giá trị mặc định khi chưa có dữ liệu.
  T get defaultValue;

  /// Đọc giá trị từ SharedPreferences.
  T fromPrefs(SharedPreferences prefs);

  /// Ghi giá trị vào SharedPreferences.
  Future<void> toPrefs(SharedPreferences prefs, T value);

  /// Helper: khởi tạo async prefs.
  /// Gọi trong build() — trả về defaultValue ngay, sau đó load async.
  ///
  /// Returns the default value to use immediately.
  T initAsyncPrefs({
    required String key,
    required T defaultVal,
    required T Function(SharedPreferences prefs) from,
    required Future<void> Function(SharedPreferences prefs, T value) to,
  }) {
    Future.microtask(() async {
      final prefs = await _prefs;
      // Note: this calls the notifier's setter which updates state
      updateState(from(prefs));
    });
    return defaultVal;
  }

  /// Update state — override trong concrete class để gán `state = value`.
  void updateState(T value);

  /// Persist giá trị hiện tại vào SharedPreferences.
  Future<void> persist() async {
    final prefs = await _prefs;
    // Lấy giá trị hiện tại từ concrete class
    await toPrefs(prefs, currentValue);
  }

  /// Giá trị hiện tại — override trong concrete class.
  T get currentValue;
}
