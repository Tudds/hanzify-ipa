// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
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

@ProviderFor(vocabLocalDataSource)
final vocabLocalDataSourceProvider = VocabLocalDataSourceProvider._();

final class VocabLocalDataSourceProvider
    extends
        $FunctionalProvider<
          VocabLocalDataSource,
          VocabLocalDataSource,
          VocabLocalDataSource
        >
    with $Provider<VocabLocalDataSource> {
  VocabLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<VocabLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VocabLocalDataSource create(Ref ref) {
    return vocabLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VocabLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VocabLocalDataSource>(value),
    );
  }
}

String _$vocabLocalDataSourceHash() =>
    r'9a7690ea57b123968d4f8102edef93c58bae9efd';

@ProviderFor(vocabRepository)
final vocabRepositoryProvider = VocabRepositoryProvider._();

final class VocabRepositoryProvider
    extends
        $FunctionalProvider<VocabRepository, VocabRepository, VocabRepository>
    with $Provider<VocabRepository> {
  VocabRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabRepositoryHash();

  @$internal
  @override
  $ProviderElement<VocabRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VocabRepository create(Ref ref) {
    return vocabRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VocabRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VocabRepository>(value),
    );
  }
}

String _$vocabRepositoryHash() => r'9516de3be452e6db691b18a5943aad5a989d2888';
