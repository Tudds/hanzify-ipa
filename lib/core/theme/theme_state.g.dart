// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, AppThemeMode> {
  ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeMode>(value),
    );
  }
}

String _$themeNotifierHash() => r'f62fb3cb52f36017823673cf2690e23f8a73d26c';

abstract class _$ThemeNotifier extends $Notifier<AppThemeMode> {
  AppThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppThemeMode, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppThemeMode, AppThemeMode>,
              AppThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(themeColors)
final themeColorsProvider = ThemeColorsProvider._();

final class ThemeColorsProvider
    extends $FunctionalProvider<AppThemeColors, AppThemeColors, AppThemeColors>
    with $Provider<AppThemeColors> {
  ThemeColorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeColorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeColorsHash();

  @$internal
  @override
  $ProviderElement<AppThemeColors> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppThemeColors create(Ref ref) {
    return themeColors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeColors value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeColors>(value),
    );
  }
}

String _$themeColorsHash() => r'a241f97389f8d8016134f8540c74e9256b2b996f';
