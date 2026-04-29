import 'package:flutter/material.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_urls.dart';
import '../../../../core/learning/collocation.dart';
import '../../../../core/learning/learning_asset_repository.dart';
import '../../../../core/learning/lesson_context.dart';

class LessonDetailCard extends StatelessWidget {
  const LessonDetailCard({
    super.key,
    required this.session,
    required this.lessonContext,
  });

  final HskLearningSessionSeed session;
  final LessonContext? lessonContext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final conversationItems = _conversationItems;
    final sampleItems =
        (conversationItems.isEmpty ? session.collocations : conversationItems)
            .take(8)
            .toList(growable: false);
    final vocab = _keyVocab(sampleItems);
    final grammar = _keyGrammar(sampleItems);

    return Card(
      color: colorScheme.surface.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _LessonHeader(title: _title, goal: _goal),
            _LessonSection(
              icon: Icons.forum_outlined,
              title: '1. Hội thoại đầy đủ',
              child: conversationItems.isEmpty
                  ? _TokenWrap(values: _conversationTokens)
                  : _ConversationPreview(items: conversationItems),
            ),
            _LessonSection(
              icon: Icons.translate_outlined,
              title: '2. Từ khóa cần nhớ',
              child: vocab.isEmpty
                  ? const Text('Từ vựng sẽ xuất hiện trong quiz.')
                  : _VocabTokenWrap(items: vocab),
            ),
            _LessonSection(
              icon: Icons.account_tree_outlined,
              title: '3. Mẫu câu trọng tâm',
              child: grammar.isEmpty
                  ? const Text('Pattern được chọn từ câu luyện tập.')
                  : _GrammarTokenWrap(values: grammar),
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    if (lessonContext == null) return 'Today\'s lesson';
    return '${lessonContext!.moduleId} · ${lessonContext!.lessonUnitId}';
  }

  String get _goal {
    if (session.activeLevel <= 1) {
      return 'Review foundation words and sentence patterns before moving on.';
    }
    if (session.activeLevel == 2) {
      return 'Build HSK2 recognition, recall, pinyin, and cloze accuracy.';
    }
    return 'Practice unlocked HSK${session.activeLevel} content with controlled examples.';
  }

  List<String> get _conversationTokens {
    final conversations = lessonContext?.conversationIds ?? const [];
    if (conversations.isEmpty) return const ['Generated frames'];
    return conversations;
  }

  List<CollocationItem> get _conversationItems {
    final conversations =
        lessonContext?.conversationIds.toSet() ?? const <String>{};
    final items = session.collocations
        .where((item) {
          return item.source == 'conversation_line' &&
              item.conversationIds.any(conversations.contains);
        })
        .toList(growable: false);
    return [...items]..sort((a, b) {
      final convCompare = _conversationId(a).compareTo(_conversationId(b));
      if (convCompare != 0) return convCompare;
      return _lineIndex(a).compareTo(_lineIndex(b));
    });
  }

  List<({String id, String label})> _keyVocab(List<CollocationItem> items) {
    final values = <({String id, String label})>[];
    final seen = <String>{};
    for (final item in items) {
      for (final id in item.targetVocabIds) {
        if (!id.startsWith('hsk${session.activeLevel}_')) continue;
        final text = _idTail(id);
        if (text.isEmpty || seen.contains(text)) continue;
        seen.add(text);
        values.add((id: id, label: text));
      }
    }
    if (values.isNotEmpty) return values.take(10).toList(growable: false);

    for (final item in items) {
      for (final id in item.targetVocabIds) {
        final text = _idTail(id);
        if (text.isEmpty || seen.contains(text)) continue;
        seen.add(text);
        values.add((id: id, label: text));
      }
    }
    return values.take(10).toList(growable: false);
  }

  List<String> _keyGrammar(List<CollocationItem> items) {
    final values = <String>[];
    for (final id in [
      ...?lessonContext?.grammarIds,
      for (final item in items) ...item.targetGrammarIds,
    ]) {
      if (id.isNotEmpty && !values.contains(id)) values.add(id);
    }
    return values.take(8).toList(growable: false);
  }

  String _idTail(String id) {
    final separator = id.indexOf('_');
    if (separator == -1 || separator == id.length - 1) return id;
    return id.substring(separator + 1);
  }

  String _conversationId(CollocationItem item) {
    return item.conversationIds.isEmpty ? '' : item.conversationIds.first;
  }

  int _lineIndex(CollocationItem item) {
    final audioUrl = item.audioUrl;
    if (audioUrl == null) return 999;
    final match = RegExp(r'_L(\d+)\.mp3$').firstMatch(audioUrl);
    return int.tryParse(match?.group(1) ?? '') ?? 999;
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.title, required this.goal});

  final String title;
  final String goal;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.route_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(goal, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenWrap extends StatelessWidget {
  const _TokenWrap({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final value in values)
          Chip(visualDensity: VisualDensity.compact, label: Text(value)),
      ],
    );
  }
}

class _ConversationPreview extends StatelessWidget {
  const _ConversationPreview({required this.items});

  final List<CollocationItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items.take(12))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.audioUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 6),
                    child: AudioPlayButton(
                      url: item.audioUrl!,
                      size: 18,
                      tooltip: 'Nghe dòng hội thoại',
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.textCn, style: textTheme.bodyMedium),
                      if (item.pinyin.isNotEmpty)
                        Text(item.pinyin, style: textTheme.bodySmall),
                      if (item.textVi.isNotEmpty)
                        Text(item.textVi, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GrammarTokenWrap extends StatelessWidget {
  const _GrammarTokenWrap({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final value in values)
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(_grammarLabel(value)),
          ),
      ],
    );
  }

  String _grammarLabel(String id) {
    return switch (id) {
      'g_zěnmeyàng' => '怎么样 — thế nào?',
      'g_youdianr' => '有点儿 — hơi...',
      'g_bi' => '比 — so sánh hơn',
      'g_geng' => '更 — hơn nữa',
      'g_zui' => '最 — nhất',
      'g_mei_you' => '没有 — không bằng',
      'g_you_you' => '又...又... — vừa...vừa...',
      'g_de_attr' => '的 — bổ nghĩa danh từ',
      'g_ma' => '吗 — câu hỏi yes/no',
      'g_you' => '有 — có',
      'g_neg_bu' => '不 — phủ định',
      _ => id,
    };
  }
}

class _VocabTokenWrap extends StatelessWidget {
  const _VocabTokenWrap({required this.items});

  final List<({String id, String label})> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final item in items)
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text(item.label),
            avatar: AudioPlayButton(
              url: AudioUrls.forVocab(item.id),
              size: 16,
              tooltip: 'Phát âm ${item.label}',
            ),
          ),
      ],
    );
  }
}
