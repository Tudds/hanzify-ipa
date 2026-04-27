import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/vocab/domain/entities/vocab.dart';
import '../../features/grammar/domain/entities/grammar_point.dart';
import '../../features/conversation/domain/entities/conversation_context.dart';
import '../../features/vocab/presentation/providers/vocab_providers.dart';
import '../../features/grammar/presentation/providers/grammar_providers.dart';
import '../../features/conversation/presentation/providers/conversation_providers.dart';
import 'graph_models.dart';
import 'graph_repository.dart';
import 'graph_repository_asset_impl.dart';

part 'graph_providers.g.dart';

// ── Graph Repository ──────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Future<GraphRepository> graphRepository(Ref ref) async {
  return GraphRepositoryAssetImpl.load();
}

// ── Conversation Context ──────────────────────────────────────────────────────

/// Vocab + grammar context cho một conversation, ranked.
/// keepAlive=false (family) — GC khi screen dispose.
@riverpod
Future<ConversationGraphContext> conversationContext(
  Ref ref,
  String convId,
) async {
  final repoAsync = await ref.watch(graphRepositoryProvider.future);
  return repoAsync.getConversationContext(convId);
}

/// Vocab entities (đầy đủ) từ ranked IDs của conversationContextProvider.
@riverpod
Future<List<Vocab>> conversationContextVocabs(
  Ref ref,
  String convId,
) async {
  final ctx = await ref.watch(conversationContextProvider(convId).future);
  if (ctx.rankedVocabs.isEmpty) return [];

  final ids = ctx.rankedVocabs.map((r) => r.vocabId).toList();
  final repo = ref.read(vocabRepositoryProvider);
  final vocabs = await repo.getByIds(ids);

  // Giữ thứ tự rank
  final map = {for (final v in vocabs) v.id: v};
  return ids.map((id) => map[id]).whereType<Vocab>().toList();
}

/// Grammar entities từ grammar refs của conversation.
@riverpod
Future<List<GrammarPoint>> conversationContextGrammars(
  Ref ref,
  String convId,
) async {
  final ctx = await ref.watch(conversationContextProvider(convId).future);
  if (ctx.grammarRefs.isEmpty) return [];

  final ids = ctx.grammarRefs.map((r) => r.grammarId).toList();
  final repo = ref.read(grammarRepositoryProvider);
  return repo.getByIds(ids);
}

// ── Vocab reverse lookup ──────────────────────────────────────────────────────

/// Sentence IDs minh hoạ grammar này (từ grammar_to_sentence.json).
@riverpod
Future<List<String>> grammarSentenceRefs(Ref ref, String grammarId) async {
  final repo = await ref.watch(graphRepositoryProvider.future);
  return repo.getSentencesForGrammar(grammarId);
}

/// Conversations chứa vocab này (cho VocabDetailSheet Phase 2).
@riverpod
Future<List<VocabConvRef>> vocabConvRefs(Ref ref, String vocabId) async {
  final repoAsync = await ref.watch(graphRepositoryProvider.future);
  return repoAsync.getConvsForVocab(vocabId);
}

/// Conversation entities từ vocabConvRefs.
@riverpod
Future<List<ConversationContext>> vocabRelatedConversations(
  Ref ref,
  String vocabId,
) async {
  final refs = await ref.watch(vocabConvRefsProvider(vocabId).future);
  if (refs.isEmpty) return [];

  final ids = refs.map((r) => r.convId).toList();
  final repo = ref.read(conversationRepositoryProvider);
  return repo.getByIds(ids);
}
