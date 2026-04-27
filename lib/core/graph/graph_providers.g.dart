// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(graphRepository)
final graphRepositoryProvider = GraphRepositoryProvider._();

final class GraphRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<GraphRepository>,
          GraphRepository,
          FutureOr<GraphRepository>
        >
    with $FutureModifier<GraphRepository>, $FutureProvider<GraphRepository> {
  GraphRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'graphRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$graphRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<GraphRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GraphRepository> create(Ref ref) {
    return graphRepository(ref);
  }
}

String _$graphRepositoryHash() => r'845353dae84ccc089eac56ee1493dd83896256c4';

/// Vocab + grammar context cho một conversation, ranked.
/// keepAlive=false (family) — GC khi screen dispose.

@ProviderFor(conversationContext)
final conversationContextProvider = ConversationContextFamily._();

/// Vocab + grammar context cho một conversation, ranked.
/// keepAlive=false (family) — GC khi screen dispose.

final class ConversationContextProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConversationGraphContext>,
          ConversationGraphContext,
          FutureOr<ConversationGraphContext>
        >
    with
        $FutureModifier<ConversationGraphContext>,
        $FutureProvider<ConversationGraphContext> {
  /// Vocab + grammar context cho một conversation, ranked.
  /// keepAlive=false (family) — GC khi screen dispose.
  ConversationContextProvider._({
    required ConversationContextFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationContextProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationContextHash();

  @override
  String toString() {
    return r'conversationContextProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ConversationGraphContext> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ConversationGraphContext> create(Ref ref) {
    final argument = this.argument as String;
    return conversationContext(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationContextProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationContextHash() =>
    r'af3e825c7f6c0f818a26ef41967f7ea52dc5fffb';

/// Vocab + grammar context cho một conversation, ranked.
/// keepAlive=false (family) — GC khi screen dispose.

final class ConversationContextFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ConversationGraphContext>, String> {
  ConversationContextFamily._()
    : super(
        retry: null,
        name: r'conversationContextProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Vocab + grammar context cho một conversation, ranked.
  /// keepAlive=false (family) — GC khi screen dispose.

  ConversationContextProvider call(String convId) =>
      ConversationContextProvider._(argument: convId, from: this);

  @override
  String toString() => r'conversationContextProvider';
}

/// Vocab entities (đầy đủ) từ ranked IDs của conversationContextProvider.

@ProviderFor(conversationContextVocabs)
final conversationContextVocabsProvider = ConversationContextVocabsFamily._();

/// Vocab entities (đầy đủ) từ ranked IDs của conversationContextProvider.

final class ConversationContextVocabsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Vocab>>,
          List<Vocab>,
          FutureOr<List<Vocab>>
        >
    with $FutureModifier<List<Vocab>>, $FutureProvider<List<Vocab>> {
  /// Vocab entities (đầy đủ) từ ranked IDs của conversationContextProvider.
  ConversationContextVocabsProvider._({
    required ConversationContextVocabsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationContextVocabsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationContextVocabsHash();

  @override
  String toString() {
    return r'conversationContextVocabsProvider'
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
    return conversationContextVocabs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationContextVocabsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationContextVocabsHash() =>
    r'173ff55c72bf1d56f3b54c1f69ad307d1c1f5f43';

/// Vocab entities (đầy đủ) từ ranked IDs của conversationContextProvider.

final class ConversationContextVocabsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Vocab>>, String> {
  ConversationContextVocabsFamily._()
    : super(
        retry: null,
        name: r'conversationContextVocabsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Vocab entities (đầy đủ) từ ranked IDs của conversationContextProvider.

  ConversationContextVocabsProvider call(String convId) =>
      ConversationContextVocabsProvider._(argument: convId, from: this);

  @override
  String toString() => r'conversationContextVocabsProvider';
}

/// Grammar entities từ grammar refs của conversation.

@ProviderFor(conversationContextGrammars)
final conversationContextGrammarsProvider =
    ConversationContextGrammarsFamily._();

/// Grammar entities từ grammar refs của conversation.

final class ConversationContextGrammarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GrammarPoint>>,
          List<GrammarPoint>,
          FutureOr<List<GrammarPoint>>
        >
    with
        $FutureModifier<List<GrammarPoint>>,
        $FutureProvider<List<GrammarPoint>> {
  /// Grammar entities từ grammar refs của conversation.
  ConversationContextGrammarsProvider._({
    required ConversationContextGrammarsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationContextGrammarsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationContextGrammarsHash();

  @override
  String toString() {
    return r'conversationContextGrammarsProvider'
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
    return conversationContextGrammars(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationContextGrammarsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationContextGrammarsHash() =>
    r'd41f73bf93ff50b8ced80d6396b840d6623d0d1b';

/// Grammar entities từ grammar refs của conversation.

final class ConversationContextGrammarsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<GrammarPoint>>, String> {
  ConversationContextGrammarsFamily._()
    : super(
        retry: null,
        name: r'conversationContextGrammarsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Grammar entities từ grammar refs của conversation.

  ConversationContextGrammarsProvider call(String convId) =>
      ConversationContextGrammarsProvider._(argument: convId, from: this);

  @override
  String toString() => r'conversationContextGrammarsProvider';
}

/// Sentence IDs minh hoạ grammar này (từ grammar_to_sentence.json).

@ProviderFor(grammarSentenceRefs)
final grammarSentenceRefsProvider = GrammarSentenceRefsFamily._();

/// Sentence IDs minh hoạ grammar này (từ grammar_to_sentence.json).

final class GrammarSentenceRefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Sentence IDs minh hoạ grammar này (từ grammar_to_sentence.json).
  GrammarSentenceRefsProvider._({
    required GrammarSentenceRefsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'grammarSentenceRefsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$grammarSentenceRefsHash();

  @override
  String toString() {
    return r'grammarSentenceRefsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return grammarSentenceRefs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GrammarSentenceRefsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$grammarSentenceRefsHash() =>
    r'f3168fbf00b4e069f111baee026045a2faa693a8';

/// Sentence IDs minh hoạ grammar này (từ grammar_to_sentence.json).

final class GrammarSentenceRefsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  GrammarSentenceRefsFamily._()
    : super(
        retry: null,
        name: r'grammarSentenceRefsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Sentence IDs minh hoạ grammar này (từ grammar_to_sentence.json).

  GrammarSentenceRefsProvider call(String grammarId) =>
      GrammarSentenceRefsProvider._(argument: grammarId, from: this);

  @override
  String toString() => r'grammarSentenceRefsProvider';
}

/// Conversations chứa vocab này (cho VocabDetailSheet Phase 2).

@ProviderFor(vocabConvRefs)
final vocabConvRefsProvider = VocabConvRefsFamily._();

/// Conversations chứa vocab này (cho VocabDetailSheet Phase 2).

final class VocabConvRefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VocabConvRef>>,
          List<VocabConvRef>,
          FutureOr<List<VocabConvRef>>
        >
    with
        $FutureModifier<List<VocabConvRef>>,
        $FutureProvider<List<VocabConvRef>> {
  /// Conversations chứa vocab này (cho VocabDetailSheet Phase 2).
  VocabConvRefsProvider._({
    required VocabConvRefsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vocabConvRefsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vocabConvRefsHash();

  @override
  String toString() {
    return r'vocabConvRefsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VocabConvRef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VocabConvRef>> create(Ref ref) {
    final argument = this.argument as String;
    return vocabConvRefs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VocabConvRefsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vocabConvRefsHash() => r'60840965799ab4f86c76883e80bf13401efd7734';

/// Conversations chứa vocab này (cho VocabDetailSheet Phase 2).

final class VocabConvRefsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VocabConvRef>>, String> {
  VocabConvRefsFamily._()
    : super(
        retry: null,
        name: r'vocabConvRefsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Conversations chứa vocab này (cho VocabDetailSheet Phase 2).

  VocabConvRefsProvider call(String vocabId) =>
      VocabConvRefsProvider._(argument: vocabId, from: this);

  @override
  String toString() => r'vocabConvRefsProvider';
}

/// Conversation entities từ vocabConvRefs.

@ProviderFor(vocabRelatedConversations)
final vocabRelatedConversationsProvider = VocabRelatedConversationsFamily._();

/// Conversation entities từ vocabConvRefs.

final class VocabRelatedConversationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConversationContext>>,
          List<ConversationContext>,
          FutureOr<List<ConversationContext>>
        >
    with
        $FutureModifier<List<ConversationContext>>,
        $FutureProvider<List<ConversationContext>> {
  /// Conversation entities từ vocabConvRefs.
  VocabRelatedConversationsProvider._({
    required VocabRelatedConversationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vocabRelatedConversationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vocabRelatedConversationsHash();

  @override
  String toString() {
    return r'vocabRelatedConversationsProvider'
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
    return vocabRelatedConversations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VocabRelatedConversationsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vocabRelatedConversationsHash() =>
    r'eb472e44f01248c163427409875d601dfc0fefdb';

/// Conversation entities từ vocabConvRefs.

final class VocabRelatedConversationsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<ConversationContext>>, String> {
  VocabRelatedConversationsFamily._()
    : super(
        retry: null,
        name: r'vocabRelatedConversationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Conversation entities từ vocabConvRefs.

  VocabRelatedConversationsProvider call(String vocabId) =>
      VocabRelatedConversationsProvider._(argument: vocabId, from: this);

  @override
  String toString() => r'vocabRelatedConversationsProvider';
}
