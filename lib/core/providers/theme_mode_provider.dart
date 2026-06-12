import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_provider.dart';

/// Theme mode của app — dark-first theo skill flutter-ui.
///
/// Mặc định [ThemeMode.dark] (light theme đã build sẵn từ cùng seed nhưng
/// chưa audit từng màn hình); đổi sang `ThemeMode.system` sau khi light pass.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.dark,
    );
  }

  void set(ThemeMode mode) {
    state = mode;
    unawaited(ref.read(sharedPreferencesProvider).setString(_key, mode.name));
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
