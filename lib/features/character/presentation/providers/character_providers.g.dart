// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(characterLocalDataSource)
final characterLocalDataSourceProvider = CharacterLocalDataSourceProvider._();

final class CharacterLocalDataSourceProvider
    extends
        $FunctionalProvider<
          CharacterLocalDataSource,
          CharacterLocalDataSource,
          CharacterLocalDataSource
        >
    with $Provider<CharacterLocalDataSource> {
  CharacterLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'characterLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$characterLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<CharacterLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CharacterLocalDataSource create(Ref ref) {
    return characterLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CharacterLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CharacterLocalDataSource>(value),
    );
  }
}

String _$characterLocalDataSourceHash() =>
    r'18ef76522db4b4276b85d540cf7c93b2e2a4bad3';

@ProviderFor(characterRepository)
final characterRepositoryProvider = CharacterRepositoryProvider._();

final class CharacterRepositoryProvider
    extends
        $FunctionalProvider<
          CharacterRepository,
          CharacterRepository,
          CharacterRepository
        >
    with $Provider<CharacterRepository> {
  CharacterRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'characterRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$characterRepositoryHash();

  @$internal
  @override
  $ProviderElement<CharacterRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CharacterRepository create(Ref ref) {
    return characterRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CharacterRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CharacterRepository>(value),
    );
  }
}

String _$characterRepositoryHash() =>
    r'e4e76fc3ab8e6cf7b14f01314b52ab8e1eb854d9';

@ProviderFor(characterDetail)
final characterDetailProvider = CharacterDetailFamily._();

final class CharacterDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<Character?>,
          Character?,
          FutureOr<Character?>
        >
    with $FutureModifier<Character?>, $FutureProvider<Character?> {
  CharacterDetailProvider._({
    required CharacterDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'characterDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$characterDetailHash();

  @override
  String toString() {
    return r'characterDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Character?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Character?> create(Ref ref) {
    final argument = this.argument as String;
    return characterDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CharacterDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$characterDetailHash() => r'ee3c45f76ce95b1cc714c1e3623e83a1025ff261';

final class CharacterDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Character?>, String> {
  CharacterDetailFamily._()
    : super(
        retry: null,
        name: r'characterDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CharacterDetailProvider call(String char) =>
      CharacterDetailProvider._(argument: char, from: this);

  @override
  String toString() => r'characterDetailProvider';
}

@ProviderFor(vocabContainingChar)
final vocabContainingCharProvider = VocabContainingCharFamily._();

final class VocabContainingCharProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Vocab>>,
          List<Vocab>,
          FutureOr<List<Vocab>>
        >
    with $FutureModifier<List<Vocab>>, $FutureProvider<List<Vocab>> {
  VocabContainingCharProvider._({
    required VocabContainingCharFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vocabContainingCharProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vocabContainingCharHash();

  @override
  String toString() {
    return r'vocabContainingCharProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Vocab>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Vocab>> create(Ref ref) {
    final argument = this.argument as String;
    return vocabContainingChar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VocabContainingCharProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vocabContainingCharHash() =>
    r'add13e40b2a205349881bec37cd8e3a75afe2708';

final class VocabContainingCharFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Vocab>>, String> {
  VocabContainingCharFamily._()
    : super(
        retry: null,
        name: r'vocabContainingCharProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VocabContainingCharProvider call(String char) =>
      VocabContainingCharProvider._(argument: char, from: this);

  @override
  String toString() => r'vocabContainingCharProvider';
}
