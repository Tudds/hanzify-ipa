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

String _$themeNotifierHash() => r'afc9bedf86e89cde7079851ea228566a78fd5b9a';

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

String _$themeColorsHash() => r'66aaeef40238f2addb74dcb8a1e2c76bd56e40e4';
