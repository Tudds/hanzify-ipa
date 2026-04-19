import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
export 'colors.dart';
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
    final c = colors;
    final isDark = state == AppThemeMode.dark;

    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: isDark ? Brightness.dark : Brightness.light).textTheme,
    ).apply(
      bodyColor: c.text,
      displayColor: c.text,
      fontFamily: GoogleFonts.notoSansSc().fontFamily,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: c.primary,
        secondary: c.secondary,
        surface: c.surfaceLowest,
        error: c.error,
      ),
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme,
      fontFamily: GoogleFonts.notoSansSc().fontFamily,
      // No default card elevation — cards manage their own shadow
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      // Minimal dividers
      dividerTheme: DividerThemeData(color: c.outlineVariant, thickness: 0.5),
      // Cupertino-style slide transition for all routes
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: [
        AppThemeExtension(colors: c),
      ],
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

// Provider này giúp UI chỉ rebuild khi màu thực sự thay đổi
@riverpod
AppThemeColors themeColors(Ref ref) {
  // Watch notifier để rebuild đúng khi state thay đổi
  return ref.watch(themeProvider.notifier).colors;
}
