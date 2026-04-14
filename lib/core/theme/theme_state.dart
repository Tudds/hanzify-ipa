import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

part 'theme_state.g.dart';

enum AppThemeMode { light, dark, sepia }

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  static const _prefKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    Future.microtask(_loadTheme);
    return AppThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_prefKey);
    if (savedMode != null) {
      state = AppThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => AppThemeMode.light,
      );
    }
  }

  Future<void> cycleTheme() async {
    final nextIndex = (state.index + 1) % AppThemeMode.values.length;
    state = AppThemeMode.values[nextIndex];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, state.name);
  }

  AppThemeColors get colors {
    switch (state) {
      case AppThemeMode.dark: return AppThemeColors.dark;
      case AppThemeMode.sepia: return AppThemeColors.sepia;
      case AppThemeMode.light: 
        return AppThemeColors.light;
    }
  }

  ThemeData get themeData {
    final c = colors;
    final isDark = state == AppThemeMode.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: c.primary,
        secondary: c.secondary,
        surface: c.surface,
        error: c.error,
      ),
      scaffoldBackgroundColor: c.background,
    );
  }
}

// Provider này giúp UI chỉ rebuild khi màu thực sự thay đổi
@riverpod
AppThemeColors themeColors(Ref ref) {
  // Watch the state directly to trigger rebuilds
  ref.watch(themeProvider);
  return ref.read(themeProvider.notifier).colors;
}

