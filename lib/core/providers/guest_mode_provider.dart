import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanzify/core/providers/async_prefs_notifier.dart';

part 'guest_mode_provider.g.dart';

/// Bật khi user chọn "Dùng thử không đăng nhập".
/// Cho phép auth gate ở main.dart cho qua mà không cần Supabase session.
@Riverpod(keepAlive: true)
class GuestMode extends _$GuestMode with AsyncPrefsNotifier<bool> {
  static const _prefKey = 'guest_mode';

  @override
  String get prefsKey => _prefKey;

  @override
  bool get defaultValue => false;

  @override
  bool get currentValue => state;

  @override
  void updateState(bool value) => state = value;

  @override
  bool fromPrefs(SharedPreferences prefs) =>
      prefs.getBool(_prefKey) ?? false;

  @override
  Future<void> toPrefs(SharedPreferences prefs, bool value) =>
      prefs.setBool(_prefKey, value);

  @override
  bool build() => initAsyncPrefs(
        key: _prefKey,
        defaultVal: false,
        from: (prefs) => prefs.getBool(_prefKey) ?? false,
        to: (prefs, value) => prefs.setBool(_prefKey, value),
      );

  Future<void> enable() async {
    state = true;
    await persist();
  }

  Future<void> disable() async {
    state = false;
    await persist();
  }
}
