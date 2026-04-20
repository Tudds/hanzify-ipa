// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VocabFilterNotifier)
final vocabFilterProvider = VocabFilterNotifierProvider._();

final class VocabFilterNotifierProvider
    extends $NotifierProvider<VocabFilterNotifier, VocabFilter> {
  VocabFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabFilterNotifierHash();

  @$internal
  @override
  VocabFilterNotifier create() => VocabFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VocabFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VocabFilter>(value),
    );
  }
}

String _$vocabFilterNotifierHash() =>
    r'ab0f14cf008a4cdaa7037a4b201f647b2c4c8cc6';

abstract class _$VocabFilterNotifier extends $Notifier<VocabFilter> {
  VocabFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VocabFilter, VocabFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VocabFilter, VocabFilter>,
              VocabFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(vocabSearch)
final vocabSearchProvider = VocabSearchProvider._();

final class VocabSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Vocab>>,
          List<Vocab>,
          FutureOr<List<Vocab>>
        >
    with $FutureModifier<List<Vocab>>, $FutureProvider<List<Vocab>> {
  VocabSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabSearchHash();

  @$internal
  @override
  $FutureProviderElement<List<Vocab>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Vocab>> create(Ref ref) {
    return vocabSearch(ref);
  }
}

String _$vocabSearchHash() => r'92f2fa946b297338d93653cbed34f76f310c7e40';

@ProviderFor(filteredVocabList)
final filteredVocabListProvider = FilteredVocabListProvider._();

final class FilteredVocabListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Vocab>>,
          List<Vocab>,
          FutureOr<List<Vocab>>
        >
    with $FutureModifier<List<Vocab>>, $FutureProvider<List<Vocab>> {
  FilteredVocabListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredVocabListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredVocabListHash();

  @$internal
  @override
  $FutureProviderElement<List<Vocab>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Vocab>> create(Ref ref) {
    return filteredVocabList(ref);
  }
}

String _$filteredVocabListHash() => r'c5c4c725d28e6fcc0467083e01c88dc26fe57b5d';
