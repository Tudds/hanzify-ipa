// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuizNotifier)
final quizProvider = QuizNotifierProvider._();

final class QuizNotifierProvider
    extends $NotifierProvider<QuizNotifier, QuizState> {
  QuizNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quizNotifierHash();

  @$internal
  @override
  QuizNotifier create() => QuizNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuizState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuizState>(value),
    );
  }
}

String _$quizNotifierHash() => r'81c4eb04caf4083c9f9f86712ac7a8f606a8aea7';

abstract class _$QuizNotifier extends $Notifier<QuizState> {
  QuizState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<QuizState, QuizState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<QuizState, QuizState>,
              QuizState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
