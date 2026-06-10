import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/learning/data/dialogue_scene_repository.dart';
import '../domain/grammar_item.dart';
import '../domain/vocab_item.dart';

typedef Hsk3ConversationPathEntry = ({
  String stageId,
  String moduleId,
  String conversationId,
  String title,
  String npcName,
  String npcRole,
  String description,
});

class LibraryRepository {
  LibraryRepository({AssetBundle? bundle}) : _bundle = bundle;

  static const nextHsk3ConversationEntry = (
    stageId: 'HSK3',
    moduleId: 'H3-M4',
    conversationId: DialogueSceneRepository.nextHsk3ConversationSceneId,
    title: 'Lập kế hoạch ôn thi',
    npcName: 'Cô Mai',
    npcRole: 'Cố vấn HSK3',
    description: 'Điều kiện, điều kiện duy nhất và nhượng bộ',
  );

  static const _nextHsk3ConversationGrammarIds = {
    'g_suiran_danshi',
    'g_zhiyao_jiu',
    'g_zhiyou_cai',
  };

  static const _vocabAssetByLevel = <int, String>{
    1: 'assets/data/hsk1.json',
    2: 'assets/data/hsk2.json',
    3: 'assets/data/hsk3.json',
    4: 'assets/data/hsk4.json',
  };
  static const _grammarAssetByLevel = <int, String>{
    1: 'assets/data/grammar_hsk1.json',
    2: 'assets/data/grammar_hsk2.json',
    3: 'assets/data/grammar_hsk3.json',
    4: 'assets/data/grammar_hsk4.json',
  };

  final AssetBundle? _bundle;
  List<VocabItem>? _vocabCache;
  List<GrammarItem>? _grammarCache;
  Future<List<VocabItem>>? _vocabLoading;
  Future<List<GrammarItem>>? _grammarLoading;
  final Map<int, List<VocabItem>> _vocabByLevel = {};
  final Map<int, List<GrammarItem>> _grammarByLevel = {};
  final Map<int, Future<List<VocabItem>>> _vocabLevelLoading = {};
  final Map<int, Future<List<GrammarItem>>> _grammarLevelLoading = {};

  /// Loads vocab for a single HSK [level] only — parses just that level's JSON
  /// file (~300–740 KB) instead of all four, so the dictionary's level filter
  /// doesn't decode the whole library on the main thread. Result is cached and
  /// reused by [loadVocab].
  Future<List<VocabItem>> loadVocabLevel(int level) {
    final cached = _vocabByLevel[level];
    if (cached != null) return Future.value(cached);
    return _vocabLevelLoading[level] ??= _doLoadVocabLevel(level);
  }

  /// Loads grammar for a single HSK [level] only. See [loadVocabLevel].
  Future<List<GrammarItem>> loadGrammarLevel(int level) {
    final cached = _grammarByLevel[level];
    if (cached != null) return Future.value(cached);
    return _grammarLevelLoading[level] ??= _doLoadGrammarLevel(level);
  }

  Future<List<VocabItem>> loadVocab() {
    final cached = _vocabCache;
    if (cached != null) return Future.value(cached);
    return _vocabLoading ??= _doLoadVocab();
  }

  Future<List<GrammarItem>> loadGrammar() {
    final cached = _grammarCache;
    if (cached != null) return Future.value(cached);
    return _grammarLoading ??= _doLoadGrammar();
  }

  List<String> conversationIdsForLesson({
    required String stageId,
    required String moduleId,
    required List<String> conversationIds,
    required List<String> focusGrammarIds,
  }) {
    if (!isNextHsk3ConversationLesson(
      stageId: stageId,
      moduleId: moduleId,
      focusGrammarIds: focusGrammarIds,
    )) {
      return conversationIds;
    }
    final id = nextHsk3ConversationEntry.conversationId;
    if (conversationIds.contains(id)) return conversationIds;
    return [id, ...conversationIds];
  }

  bool isNextHsk3ConversationLesson({
    required String stageId,
    required String moduleId,
    required List<String> focusGrammarIds,
  }) {
    final entry = nextHsk3ConversationEntry;
    return stageId == entry.stageId &&
        moduleId == entry.moduleId &&
        focusGrammarIds.any(_nextHsk3ConversationGrammarIds.contains);
  }

  Future<List<VocabItem>> _doLoadVocabLevel(int level) async {
    final bundle = _bundle ?? rootBundle;
    final path = _vocabAssetByLevel[level];
    final items = <VocabItem>[];
    if (path != null) {
      try {
        final raw = await bundle.loadString(path);
        final list = (jsonDecode(raw) as List<dynamic>)
            .cast<Map<String, dynamic>>();
        items.addAll(list.map(VocabItem.fromJson));
      } catch (_) {
        // missing asset for this HSK level — skip silently
      }
    }
    items.sort((a, b) => a.pinyinNormalized.compareTo(b.pinyinNormalized));
    final result = List<VocabItem>.unmodifiable(items);
    _vocabByLevel[level] = result;
    _vocabLevelLoading.remove(level);
    return result;
  }

  Future<List<GrammarItem>> _doLoadGrammarLevel(int level) async {
    final bundle = _bundle ?? rootBundle;
    final path = _grammarAssetByLevel[level];
    final items = <GrammarItem>[];
    if (path != null) {
      try {
        final raw = await bundle.loadString(path);
        final list = (jsonDecode(raw) as List<dynamic>)
            .cast<Map<String, dynamic>>();
        items.addAll(list.map(GrammarItem.fromJson));
      } catch (_) {
        // missing asset — skip
      }
    }
    items.sort((a, b) => a.title.compareTo(b.title));
    final result = List<GrammarItem>.unmodifiable(items);
    _grammarByLevel[level] = result;
    _grammarLevelLoading.remove(level);
    return result;
  }

  Future<List<VocabItem>> _doLoadVocab() async {
    final items = <VocabItem>[];
    // Reuse the per-level caches; `await` per level yields to the event loop
    // between files so the whole library never decodes in one blocking task.
    for (final level in _vocabAssetByLevel.keys) {
      items.addAll(await loadVocabLevel(level));
    }
    items.sort((a, b) {
      final byLevel = a.level.compareTo(b.level);
      if (byLevel != 0) return byLevel;
      return a.pinyinNormalized.compareTo(b.pinyinNormalized);
    });
    _vocabCache = List.unmodifiable(items);
    _vocabLoading = null;
    return _vocabCache!;
  }

  Future<List<GrammarItem>> _doLoadGrammar() async {
    final items = <GrammarItem>[];
    for (final level in _grammarAssetByLevel.keys) {
      items.addAll(await loadGrammarLevel(level));
    }
    items.sort((a, b) {
      final byLevel = a.level.compareTo(b.level);
      if (byLevel != 0) return byLevel;
      return a.title.compareTo(b.title);
    });
    _grammarCache = List.unmodifiable(items);
    _grammarLoading = null;
    return _grammarCache!;
  }
}

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});
