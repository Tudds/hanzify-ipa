// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared AppDatabase provider — singleton, keepAlive.
/// Overridden in platform_native.dart with real AppDatabase instance.
/// All features (vocab, grammar, conversation, character) use this provider
/// instead of creating their own DB instances.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// Shared AppDatabase provider — singleton, keepAlive.
/// Overridden in platform_native.dart with real AppDatabase instance.
/// All features (vocab, grammar, conversation, character) use this provider
/// instead of creating their own DB instances.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Shared AppDatabase provider — singleton, keepAlive.
  /// Overridden in platform_native.dart with real AppDatabase instance.
  /// All features (vocab, grammar, conversation, character) use this provider
  /// instead of creating their own DB instances.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'f3c1d08a41a86f1081960dbf42af6fcd78d83ced';
