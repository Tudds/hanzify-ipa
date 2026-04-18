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

String _$dueVocabNotifierHash() => r'f90ebba54c7bc446cf5a401f7f16c5270f7d5ddb';

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

String _$allVocabNotifierHash() => r'eeea6682abcd98207b557da0ffd984da90f753c5';

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

String _$flashcardSessionHash() => r'91e8c6fd9a369653c0588eb1053812e47a51da0b';

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
