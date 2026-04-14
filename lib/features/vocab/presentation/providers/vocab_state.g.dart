// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DueVocabNotifier)
final dueVocabProvider = DueVocabNotifierProvider._();

final class DueVocabNotifierProvider
    extends $AsyncNotifierProvider<DueVocabNotifier, List<Vocab>> {
  DueVocabNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dueVocabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dueVocabNotifierHash();

  @$internal
  @override
  DueVocabNotifier create() => DueVocabNotifier();
}

String _$dueVocabNotifierHash() => r'1e95e24d9c89eca5628099e008a129a1493c00d6';

abstract class _$DueVocabNotifier extends $AsyncNotifier<List<Vocab>> {
  FutureOr<List<Vocab>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Vocab>>, List<Vocab>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Vocab>>, List<Vocab>>,
              AsyncValue<List<Vocab>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AllVocabNotifier)
final allVocabProvider = AllVocabNotifierProvider._();

final class AllVocabNotifierProvider
    extends $AsyncNotifierProvider<AllVocabNotifier, List<Vocab>> {
  AllVocabNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allVocabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allVocabNotifierHash();

  @$internal
  @override
  AllVocabNotifier create() => AllVocabNotifier();
}

String _$allVocabNotifierHash() => r'41bfd66163fd8f6562a7a07b85c8dc6be53f76a9';

abstract class _$AllVocabNotifier extends $AsyncNotifier<List<Vocab>> {
  FutureOr<List<Vocab>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Vocab>>, List<Vocab>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Vocab>>, List<Vocab>>,
              AsyncValue<List<Vocab>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(FlashcardSession)
final flashcardSessionProvider = FlashcardSessionProvider._();

final class FlashcardSessionProvider
    extends $AsyncNotifierProvider<FlashcardSession, List<Vocab>?> {
  FlashcardSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flashcardSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flashcardSessionHash();

  @$internal
  @override
  FlashcardSession create() => FlashcardSession();
}

String _$flashcardSessionHash() => r'bbe35bd064de1a8b7f71ff05c119b2638c1b4316';

abstract class _$FlashcardSession extends $AsyncNotifier<List<Vocab>?> {
  FutureOr<List<Vocab>?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Vocab>?>, List<Vocab>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Vocab>?>, List<Vocab>?>,
              AsyncValue<List<Vocab>?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
