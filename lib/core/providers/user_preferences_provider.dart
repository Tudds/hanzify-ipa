import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'async_prefs_notifier.dart';

part 'user_preferences_provider.g.dart';

/// Global pinyin visibility toggle — persisted across sessions.
@Riverpod(keepAlive: true)
class ShowPinyin extends _$ShowPinyin with AsyncPrefsNotifier<bool> {
  static const _prefKey = 'show_pinyin';

  @override
  String get prefsKey => _prefKey;

  @override
  bool get defaultValue => true;

  @override
  bool get currentValue => state;

  @override
  void updateState(bool value) => state = value;

  @override
  bool fromPrefs(SharedPreferences prefs) =>
      prefs.getBool(_prefKey) ?? true;

  @override
  Future<void> toPrefs(SharedPreferences prefs, bool value) =>
      prefs.setBool(_prefKey, value);

  @override
  bool build() {
    return initAsyncPrefs(
      key: _prefKey,
      defaultVal: true,
      from: (prefs) => prefs.getBool(_prefKey) ?? true,
      to: (prefs, value) => prefs.setBool(_prefKey, value),
    );
  }

  Future<void> toggle() async {
    state = !state;
    await persist();
  }
}
