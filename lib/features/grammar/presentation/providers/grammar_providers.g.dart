// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(grammarLocalDataSource)
final grammarLocalDataSourceProvider = GrammarLocalDataSourceProvider._();

final class GrammarLocalDataSourceProvider
    extends
        $FunctionalProvider<
          GrammarLocalDataSource,
          GrammarLocalDataSource,
          GrammarLocalDataSource
        >
    with $Provider<GrammarLocalDataSource> {
  GrammarLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grammarLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grammarLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<GrammarLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GrammarLocalDataSource create(Ref ref) {
    return grammarLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GrammarLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GrammarLocalDataSource>(value),
    );
  }
}

String _$grammarLocalDataSourceHash() =>
    r'575ec440ce6b38c6e39e9d69dc546d06b2e4e8a7';

@ProviderFor(grammarRepository)
final grammarRepositoryProvider = GrammarRepositoryProvider._();

final class GrammarRepositoryProvider
    extends
        $FunctionalProvider<
          GrammarRepository,
          GrammarRepository,
          GrammarRepository
        >
    with $Provider<GrammarRepository> {
  GrammarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grammarRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grammarRepositoryHash();

  @$internal
  @override
  $ProviderElement<GrammarRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GrammarRepository create(Ref ref) {
    return grammarRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GrammarRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GrammarRepository>(value),
    );
  }
}

String _$grammarRepositoryHash() => r'7bfc7638ff853488d67008ceab9a1de667767dbe';

@ProviderFor(GrammarList)
final grammarListProvider = GrammarListProvider._();

final class GrammarListProvider
    extends $AsyncNotifierProvider<GrammarList, List<GrammarPoint>> {
  GrammarListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grammarListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grammarListHash();

  @$internal
  @override
  GrammarList create() => GrammarList();
}

String _$grammarListHash() => r'e9c47bf8640ecf7c1f789cff8a73a997b73989f8';

abstract class _$GrammarList extends $AsyncNotifier<List<GrammarPoint>> {
  FutureOr<List<GrammarPoint>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<GrammarPoint>>, List<GrammarPoint>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<GrammarPoint>>, List<GrammarPoint>>,
              AsyncValue<List<GrammarPoint>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(grammarByLevel)
final grammarByLevelProvider = GrammarByLevelFamily._();

final class GrammarByLevelProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GrammarPoint>>,
          List<GrammarPoint>,
          FutureOr<List<GrammarPoint>>
        >
    with
        $FutureModifier<List<GrammarPoint>>,
        $FutureProvider<List<GrammarPoint>> {
  GrammarByLevelProvider._({
    required GrammarByLevelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'grammarByLevelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$grammarByLevelHash();

  @override
  String toString() {
    return r'grammarByLevelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GrammarPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GrammarPoint>> create(Ref ref) {
    final argument = this.argument as int;
    return grammarByLevel(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GrammarByLevelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$grammarByLevelHash() => r'a3eb7dff330f26923e7157e2d641dc796d98f8f7';

final class GrammarByLevelFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<GrammarPoint>>, int> {
  GrammarByLevelFamily._()
    : super(
        retry: null,
        name: r'grammarByLevelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GrammarByLevelProvider call(int level) =>
      GrammarByLevelProvider._(argument: level, from: this);

  @override
  String toString() => r'grammarByLevelProvider';
}

@ProviderFor(grammarByCategory)
final grammarByCategoryProvider = GrammarByCategoryFamily._();

final class GrammarByCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GrammarPoint>>,
          List<GrammarPoint>,
          FutureOr<List<GrammarPoint>>
        >
    with
        $FutureModifier<List<GrammarPoint>>,
        $FutureProvider<List<GrammarPoint>> {
  GrammarByCategoryProvider._({
    required GrammarByCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'grammarByCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$grammarByCategoryHash();

  @override
  String toString() {
    return r'grammarByCategoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GrammarPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GrammarPoint>> create(Ref ref) {
    final argument = this.argument as String;
    return grammarByCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GrammarByCategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$grammarByCategoryHash() => r'7ddb4debf27798a7c358a8d6af69ccfec368fff9';

final class GrammarByCategoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<GrammarPoint>>, String> {
  GrammarByCategoryFamily._()
    : super(
        retry: null,
        name: r'grammarByCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GrammarByCategoryProvider call(String category) =>
      GrammarByCategoryProvider._(argument: category, from: this);

  @override
  String toString() => r'grammarByCategoryProvider';
}

@ProviderFor(grammarDetail)
final grammarDetailProvider = GrammarDetailFamily._();

final class GrammarDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<GrammarPoint?>,
          GrammarPoint?,
          FutureOr<GrammarPoint?>
        >
    with $FutureModifier<GrammarPoint?>, $FutureProvider<GrammarPoint?> {
  GrammarDetailProvider._({
    required GrammarDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'grammarDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$grammarDetailHash();

  @override
  String toString() {
    return r'grammarDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GrammarPoint?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GrammarPoint?> create(Ref ref) {
    final argument = this.argument as String;
    return grammarDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GrammarDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$grammarDetailHash() => r'd51d35747450d1738f078d2969c8f8680ffc1f55';

final class GrammarDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GrammarPoint?>, String> {
  GrammarDetailFamily._()
    : super(
        retry: null,
        name: r'grammarDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GrammarDetailProvider call(String id) =>
      GrammarDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'grammarDetailProvider';
}

@ProviderFor(GrammarSearchQuery)
final grammarSearchQueryProvider = GrammarSearchQueryProvider._();

final class GrammarSearchQueryProvider
    extends $NotifierProvider<GrammarSearchQuery, String> {
  GrammarSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grammarSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grammarSearchQueryHash();

  @$internal
  @override
  GrammarSearchQuery create() => GrammarSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$grammarSearchQueryHash() =>
    r'3bf8d1a16f392146d8b24327afc2229548764616';

abstract class _$GrammarSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(grammarStats)
final grammarStatsProvider = GrammarStatsProvider._();

final class GrammarStatsProvider
    extends $FunctionalProvider<GrammarStats, GrammarStats, GrammarStats>
    with $Provider<GrammarStats> {
  GrammarStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grammarStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grammarStatsHash();

  @$internal
  @override
  $ProviderElement<GrammarStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GrammarStats create(Ref ref) {
    return grammarStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GrammarStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GrammarStats>(value),
    );
  }
}

String _$grammarStatsHash() => r'1d43aa1a74b9422db46fb99073ff460bf6f50b97';
