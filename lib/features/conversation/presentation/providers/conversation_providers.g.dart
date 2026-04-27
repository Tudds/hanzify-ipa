// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(conversationLocalDataSource)
final conversationLocalDataSourceProvider =
    ConversationLocalDataSourceProvider._();

final class ConversationLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ConversationLocalDataSource,
          ConversationLocalDataSource,
          ConversationLocalDataSource
        >
    with $Provider<ConversationLocalDataSource> {
  ConversationLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ConversationLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationLocalDataSource create(Ref ref) {
    return conversationLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationLocalDataSource>(value),
    );
  }
}

String _$conversationLocalDataSourceHash() =>
    r'0c9e15b7cfb03bcd9e3f1fb4285a796e260caad7';

@ProviderFor(conversationRepository)
final conversationRepositoryProvider = ConversationRepositoryProvider._();

final class ConversationRepositoryProvider
    extends
        $FunctionalProvider<
          ConversationRepository,
          ConversationRepository,
          ConversationRepository
        >
    with $Provider<ConversationRepository> {
  ConversationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConversationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationRepository create(Ref ref) {
    return conversationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationRepository>(value),
    );
  }
}

String _$conversationRepositoryHash() =>
    r'ac0ff1d392d5f3d2f9ed5d3a4f16232f2f2b3026';

@ProviderFor(ConversationList)
final conversationListProvider = ConversationListProvider._();

final class ConversationListProvider
    extends
        $AsyncNotifierProvider<ConversationList, List<ConversationContext>> {
  ConversationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationListHash();

  @$internal
  @override
  ConversationList create() => ConversationList();
}

String _$conversationListHash() => r'1bbc728226ea4911d5bb8a88ae3f250c6ffd2fef';

abstract class _$ConversationList
    extends $AsyncNotifier<List<ConversationContext>> {
  FutureOr<List<ConversationContext>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ConversationContext>>,
              List<ConversationContext>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ConversationContext>>,
                List<ConversationContext>
              >,
              AsyncValue<List<ConversationContext>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(conversationByLevel)
final conversationByLevelProvider = ConversationByLevelFamily._();

final class ConversationByLevelProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConversationContext>>,
          List<ConversationContext>,
          FutureOr<List<ConversationContext>>
        >
    with
        $FutureModifier<List<ConversationContext>>,
        $FutureProvider<List<ConversationContext>> {
  ConversationByLevelProvider._({
    required ConversationByLevelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'conversationByLevelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationByLevelHash();

  @override
  String toString() {
    return r'conversationByLevelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ConversationContext>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConversationContext>> create(Ref ref) {
    final argument = this.argument as int;
    return conversationByLevel(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationByLevelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationByLevelHash() =>
    r'4740193df706c04e6f2e028f4e96c04ffe0a4ddb';

final class ConversationByLevelFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ConversationContext>>, int> {
  ConversationByLevelFamily._()
    : super(
        retry: null,
        name: r'conversationByLevelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConversationByLevelProvider call(int level) =>
      ConversationByLevelProvider._(argument: level, from: this);

  @override
  String toString() => r'conversationByLevelProvider';
}

@ProviderFor(conversationByCategory)
final conversationByCategoryProvider = ConversationByCategoryFamily._();

final class ConversationByCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConversationContext>>,
          List<ConversationContext>,
          FutureOr<List<ConversationContext>>
        >
    with
        $FutureModifier<List<ConversationContext>>,
        $FutureProvider<List<ConversationContext>> {
  ConversationByCategoryProvider._({
    required ConversationByCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationByCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationByCategoryHash();

  @override
  String toString() {
    return r'conversationByCategoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ConversationContext>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConversationContext>> create(Ref ref) {
    final argument = this.argument as String;
    return conversationByCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationByCategoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationByCategoryHash() =>
    r'987af6d7b30f3ef6807b64f7b5dce760ba04c376';

final class ConversationByCategoryFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<ConversationContext>>, String> {
  ConversationByCategoryFamily._()
    : super(
        retry: null,
        name: r'conversationByCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConversationByCategoryProvider call(String category) =>
      ConversationByCategoryProvider._(argument: category, from: this);

  @override
  String toString() => r'conversationByCategoryProvider';
}

@ProviderFor(conversationDetail)
final conversationDetailProvider = ConversationDetailFamily._();

final class ConversationDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConversationContext?>,
          ConversationContext?,
          FutureOr<ConversationContext?>
        >
    with
        $FutureModifier<ConversationContext?>,
        $FutureProvider<ConversationContext?> {
  ConversationDetailProvider._({
    required ConversationDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationDetailHash();

  @override
  String toString() {
    return r'conversationDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ConversationContext?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ConversationContext?> create(Ref ref) {
    final argument = this.argument as String;
    return conversationDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationDetailHash() =>
    r'05cc6722fc7c69ac27f528d04aa144e59da8415b';

final class ConversationDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ConversationContext?>, String> {
  ConversationDetailFamily._()
    : super(
        retry: null,
        name: r'conversationDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConversationDetailProvider call(String id) =>
      ConversationDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'conversationDetailProvider';
}

@ProviderFor(ConversationSearchQuery)
final conversationSearchQueryProvider = ConversationSearchQueryProvider._();

final class ConversationSearchQueryProvider
    extends $NotifierProvider<ConversationSearchQuery, String> {
  ConversationSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationSearchQueryHash();

  @$internal
  @override
  ConversationSearchQuery create() => ConversationSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$conversationSearchQueryHash() =>
    r'ed696590bd9d6abba448497dc548d7a19501dba3';

abstract class _$ConversationSearchQuery extends $Notifier<String> {
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

@ProviderFor(conversationStats)
final conversationStatsProvider = ConversationStatsProvider._();

final class ConversationStatsProvider
    extends
        $FunctionalProvider<
          ConversationStats,
          ConversationStats,
          ConversationStats
        >
    with $Provider<ConversationStats> {
  ConversationStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationStatsHash();

  @$internal
  @override
  $ProviderElement<ConversationStats> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationStats create(Ref ref) {
    return conversationStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationStats>(value),
    );
  }
}

String _$conversationStatsHash() => r'52fd95ab3f4fa179ded96882c1f7751f409834cb';
