import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
export 'colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hanzify/core/providers/async_prefs_notifier.dart';

part 'theme_state.g.dart';

enum AppThemeMode { light, dark, sepia }

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier with AsyncPrefsNotifier<AppThemeMode> {
  static const _prefKey = 'app_theme_mode';

  @override
  String get prefsKey => _prefKey;

  @override
  AppThemeMode get defaultValue => AppThemeMode.dark;

  @override
  AppThemeMode get currentValue => state;

  @override
  void updateState(AppThemeMode value) => state = value;

  @override
  AppThemeMode fromPrefs(SharedPreferences prefs) {
    final savedMode = prefs.getString(_prefKey);
    if (savedMode != null) {
      return AppThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => AppThemeMode.dark,
      );
    }
    return AppThemeMode.light;
  }

  @override
  Future<void> toPrefs(SharedPreferences prefs, AppThemeMode value) =>
      prefs.setString(_prefKey, value.name);

  @override
  AppThemeMode build() {
    return initAsyncPrefs(
      key: _prefKey,
      defaultVal: AppThemeMode.dark,
      from: (prefs) {
        final savedMode = prefs.getString(_prefKey);
        if (savedMode != null) {
          return AppThemeMode.values.firstWhere(
            (e) => e.name == savedMode,
            orElse: () => AppThemeMode.dark,
          );
        }
        return AppThemeMode.dark;
      },
      to: (prefs, value) => prefs.setString(_prefKey, value.name),
    );
  }

  Future<void> cycleTheme() async {
    final nextIndex = (state.index + 1) % AppThemeMode.values.length;
    state = AppThemeMode.values[nextIndex];
    await persist();
  }

  AppThemeColors get colors {
    switch (state) {
      case AppThemeMode.dark:
        return AppThemeColors.dark;
      case AppThemeMode.sepia:
        return AppThemeColors.sepia;
      case AppThemeMode.light:
        return AppThemeColors.light;
    }
  }

  ThemeData get themeData {
    final cs = switch (state) {
      AppThemeMode.dark => ColorScheme.fromSeed(seedColor: AppColors.darkPrimary, brightness: Brightness.dark),
      AppThemeMode.sepia => ColorScheme.fromSeed(seedColor: AppColors.sepiaPrimary, brightness: Brightness.light),
      AppThemeMode.light => ColorScheme.fromSeed(seedColor: AppColors.lightPrimary, brightness: Brightness.light),
    };

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: cs.brightness).textTheme),
      extensions: [AppThemeExtension(colors: colors)],
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final AppThemeColors colors;

  const AppThemeExtension({required this.colors});

  @override
  ThemeExtension<AppThemeExtension> copyWith({AppThemeColors? colors}) {
    return AppThemeExtension(colors: colors ?? this.colors);
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}

@riverpod
AppThemeColors themeColors(Ref ref) {
  return ref.watch(themeProvider.notifier).colors;
}
