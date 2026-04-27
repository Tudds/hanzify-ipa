#!/usr/bin/env dart
// ignore_for_file: avoid_print
// build_graph.dart — Build Context Graph JSON artifacts
//
// Usage:
//   dart run tool/build_graph.dart
//
// Output (assets/data/graph/):
//   nodes.json               — all node IDs with type + label
//   edges.json               — all edges (type, from, to, weight)
//   meta.json                — stats
//   inverted/conv_to_vocab.json    — convId → [vocabId]
//   inverted/vocab_to_conv.json    — vocabId → [convId]
//   inverted/vocab_to_sentence.json — vocabId → [sentenceId]
//   inverted/conv_to_grammar.json  — convId → [grammarId]
//   inverted/grammar_to_sentence.json — grammarId → [] (placeholder, needs P1.2)

import 'dart:convert';
import 'dart:io';

// ── Paths ──────────────────────────────────────────────────────────────────

final dataDir = Directory('assets/data');
final graphDir = Directory('assets/data/graph');
final invertedDir = Directory('assets/data/graph/inverted');

// ── Main ───────────────────────────────────────────────────────────────────

void main() async {
  print('=== Build Context Graph ===\n');

  // Load all vocab (HSK1-4)
  final vocabMap = <String, Map<String, dynamic>>{};
  for (final level in [1, 2, 3, 4]) {
    final file = File('${dataDir.path}/hsk$level.json');
    if (!file.existsSync()) continue;
    final list = jsonDecode(file.readAsStringSync()) as List;
    for (final v in list) {
      vocabMap[v['id'] as String] = Map<String, dynamic>.from(v as Map);
    }
  }
  print('Loaded ${vocabMap.length} vocab entries');

  // Load all grammar
  final grammarMap = <String, Map<String, dynamic>>{};
  for (final level in [1, 2, 3, 4]) {
    final file = File('${dataDir.path}/grammar_hsk$level.json');
    if (!file.existsSync()) continue;
    final list = jsonDecode(file.readAsStringSync()) as List;
    for (final g in list) {
      grammarMap[g['id'] as String] = Map<String, dynamic>.from(g as Map);
    }
  }
  print('Loaded ${grammarMap.length} grammar entries');

  // Load conversations
  final convFile = File('${dataDir.path}/conversation.json');
  final conversations = (jsonDecode(convFile.readAsStringSync()) as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  print('Loaded ${conversations.length} conversations');

  // Build longest-match trie for tokenization
  final trie = _buildTrie(vocabMap);
  print('Trie built (${vocabMap.length} entries)\n');

  // ── Build inverted indexes ─────────────────────────────────────────────

  // convId → [vocabId]
  final convToVocab = <String, Set<String>>{};
  // vocabId → [convId]
  final vocabToConv = <String, Set<String>>{};
  // vocabId → [sentenceId]  sentenceId = "{convId}#L{lineIdx}"
  final vocabToSentence = <String, Set<String>>{};
  // convId → [grammarId]
  final convToGrammar = <String, Set<String>>{};
  // grammarId → [sentenceId] — placeholder, filled when P1.2 manual tags added
  final grammarToSentence = <String, Set<String>>{};

  int totalMatches = 0;
  int missedTokens = 0;

  for (final conv in conversations) {
    final convId = conv['id'] as String;
    convToVocab[convId] = {};
    convToGrammar[convId] = {};

    // Grammar: from relatedGrammar field
    final relGrammar = (conv['relatedGrammar'] as List? ?? []).cast<String>();
    for (final gId in relGrammar) {
      if (grammarMap.containsKey(gId)) {
        convToGrammar[convId]!.add(gId);
      }
    }

    // Vocab: tokenize each line.zh via longest-match
    final lines = (conv['lines'] as List? ?? []);
    for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      final line = lines[lineIdx] as Map;
      final zh = (line['zh'] as String? ?? '').replaceAll(RegExp(r'[！？。，、：；""''()（）]'), '');
      final sentenceId = '$convId#L$lineIdx';

      final tokens = _tokenize(zh, trie, vocabMap);
      for (final (vocabId, matched) in tokens) {
        if (matched) {
          convToVocab[convId]!.add(vocabId);
          vocabToConv.putIfAbsent(vocabId, () => {}).add(convId);
          vocabToSentence.putIfAbsent(vocabId, () => {}).add(sentenceId);
          totalMatches++;
        } else {
          missedTokens++;
        }
      }
    }

    // Also index vocab from conversation.vocabulary inline list (hanzi match)
    final inlineVocab = (conv['vocabulary'] as List? ?? []);
    for (final iv in inlineVocab) {
      final zh = iv['zh'] as String? ?? '';
      // Find matching vocab ID by hanzi
      final vocabId = _findVocabIdByHanzi(zh, vocabMap);
      if (vocabId != null) {
        convToVocab[convId]!.add(vocabId);
        vocabToConv.putIfAbsent(vocabId, () => {}).add(convId);
      }
    }
  }

  // Reverse grammar: grammarId → convIds (via convToGrammar)
  for (final entry in convToGrammar.entries) {
    for (final gId in entry.value) {
      grammarToSentence.putIfAbsent(gId, () => {});
      // sentenceId placeholder — will be filled via P1.2 manual tags
    }
  }

  print('Tokenization: $totalMatches matches, $missedTokens unmatched segments');
  print('convToVocab: ${convToVocab.length} convs');
  print('vocabToConv: ${vocabToConv.length} vocabs referenced');
  print('vocabToSentence: ${vocabToSentence.values.fold(0, (a, b) => a + b.length)} sentence-vocab pairs');
  print('convToGrammar: ${convToGrammar.values.fold(0, (a, b) => a + b.length)} conv-grammar pairs\n');

  // ── Build nodes + edges ─────────────────────────────────────────────────

  final nodes = <Map<String, dynamic>>[];
  final edges = <Map<String, dynamic>>[];

  // Vocab nodes
  for (final v in vocabMap.values) {
    nodes.add({'id': v['id'], 'type': 'vocab', 'label': v['hanzi'], 'level': v['level']});
  }
  // Grammar nodes
  for (final g in grammarMap.values) {
    nodes.add({'id': g['id'], 'type': 'grammar', 'label': g['title'] ?? g['id'], 'level': g['level'] ?? 1});
  }
  // Conversation nodes
  for (final c in conversations) {
    nodes.add({'id': c['id'], 'type': 'conversation', 'label': c['titleZh'] ?? c['id'], 'level': c['level'] ?? 1});
  }

  // Edges: vocab ↔ conversation
  for (final entry in convToVocab.entries) {
    final convId = entry.key;
    for (final vocabId in entry.value) {
      edges.add({'type': 'vocab_in_conv', 'from': vocabId, 'to': convId, 'weight': 1.0});
    }
  }

  // Edges: grammar ↔ conversation
  for (final entry in convToGrammar.entries) {
    final convId = entry.key;
    for (final gId in entry.value) {
      edges.add({'type': 'grammar_in_conv', 'from': gId, 'to': convId, 'weight': 1.0});
    }
  }

  print('Nodes: ${nodes.length} (vocab=${vocabMap.length} grammar=${grammarMap.length} conv=${conversations.length})');
  print('Edges: ${edges.length}');

  // ── Write output ────────────────────────────────────────────────────────

  graphDir.createSync(recursive: true);
  invertedDir.createSync(recursive: true);

  _writeJson('${graphDir.path}/nodes.json', nodes);
  _writeJson('${graphDir.path}/edges.json', edges);
  _writeJson('${graphDir.path}/meta.json', {
    'generatedAt': DateTime.now().toIso8601String(),
    'vocabCount': vocabMap.length,
    'grammarCount': grammarMap.length,
    'convCount': conversations.length,
    'nodeCount': nodes.length,
    'edgeCount': edges.length,
    'tokenMatches': totalMatches,
    'tokenMisses': missedTokens,
  });

  _writeJson('${invertedDir.path}/conv_to_vocab.json',
      convToVocab.map((k, v) => MapEntry(k, v.toList()..sort())));
  _writeJson('${invertedDir.path}/vocab_to_conv.json',
      vocabToConv.map((k, v) => MapEntry(k, v.toList()..sort())));
  _writeJson('${invertedDir.path}/vocab_to_sentence.json',
      vocabToSentence.map((k, v) => MapEntry(k, v.toList()..sort())));
  _writeJson('${invertedDir.path}/conv_to_grammar.json',
      convToGrammar.map((k, v) => MapEntry(k, v.toList()..sort())));
  _writeJson('${invertedDir.path}/grammar_to_sentence.json',
      grammarToSentence.map((k, v) => MapEntry(k, v.toList()..sort())));

  print('\n✓ Graph artifacts written to assets/data/graph/');
}

// ── Helpers ─────────────────────────────────────────────────────────────────

// Trie node
class TrieNode {
  final Map<String, TrieNode> children = {};
  String? vocabId; // non-null = terminal
}

Map<String, TrieNode> _buildTrie(Map<String, Map<String, dynamic>> vocabMap) {
  // root maps first char → TrieNode
  final root = <String, TrieNode>{};
  for (final entry in vocabMap.entries) {
    final hanzi = entry.value['hanzi'] as String;
    if (hanzi.isEmpty) continue;
    final first = hanzi[0];
    root.putIfAbsent(first, () => TrieNode());
    TrieNode node = root[first]!;
    for (int i = 1; i < hanzi.length; i++) {
      final ch = hanzi[i];
      node.children.putIfAbsent(ch, () => TrieNode());
      node = node.children[ch]!;
    }
    node.vocabId = entry.key;
  }
  return root;
}

/// Longest-match tokenization. Returns list of (vocabId, matched).
/// matched=false means unrecognized character (counted as miss).
List<(String, bool)> _tokenize(
    String text, Map<String, TrieNode> trie, Map<String, Map<String, dynamic>> vocabMap) {
  final result = <(String, bool)>[];
  int i = 0;
  final chars = text.runes.map(String.fromCharCode).toList();

  while (i < chars.length) {
    final ch = chars[i];
    if (!trie.containsKey(ch)) {
      // Not a known first char — skip punctuation/spaces silently, count CJK as miss
      final codeUnit = ch.codeUnitAt(0);
      final isCjk = codeUnit >= 0x4E00 && codeUnit <= 0x9FFF;
      if (isCjk) result.add((ch, false));
      i++;
      continue;
    }

    // Try longest match
    TrieNode node = trie[ch]!;
    int matchEnd = i;
    String? matchedId = node.vocabId;

    int j = i + 1;
    while (j < chars.length && node.children.containsKey(chars[j])) {
      node = node.children[chars[j]]!;
      j++;
      if (node.vocabId != null) {
        matchedId = node.vocabId;
        matchEnd = j - 1;
      }
    }

    if (matchedId != null) {
      result.add((matchedId, true));
      i = matchEnd + 1;
    } else {
      // First char is a trie key but no match found
      final codeUnit = ch.codeUnitAt(0);
      final isCjk = codeUnit >= 0x4E00 && codeUnit <= 0x9FFF;
      if (isCjk) result.add((ch, false));
      i++;
    }
  }

  return result;
}

String? _findVocabIdByHanzi(String hanzi, Map<String, Map<String, dynamic>> vocabMap) {
  for (final entry in vocabMap.entries) {
    if (entry.value['hanzi'] == hanzi) return entry.key;
  }
  return null;
}

void _writeJson(String path, dynamic data) {
  File(path).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(data),
  );
  final size = File(path).lengthSync();
  print('  ✓ $path (${(size / 1024).toStringAsFixed(1)} KB)');
}
