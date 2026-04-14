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
    r'7986c269eba55a12e63ef7a685c820a512e62921';

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

@ProviderFor(filteredVocab)
final filteredVocabProvider = FilteredVocabProvider._();

final class FilteredVocabProvider
    extends $FunctionalProvider<List<Vocab>, List<Vocab>, List<Vocab>>
    with $Provider<List<Vocab>> {
  FilteredVocabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredVocabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredVocabHash();

  @$internal
  @override
  $ProviderElement<List<Vocab>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Vocab> create(Ref ref) {
    return filteredVocab(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Vocab> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Vocab>>(value),
    );
  }
}

String _$filteredVocabHash() => r'607f2b8ed2a5eb9f4c2b9d3ebc3f92e0169dab58';
