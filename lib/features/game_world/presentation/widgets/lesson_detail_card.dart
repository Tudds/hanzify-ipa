import 'package:flutter/material.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/audio/audio_urls.dart';
import '../../../../core/learning/collocation.dart';
import '../../../../core/learning/learning_asset_repository.dart';
import '../../../../core/learning/lesson_context.dart';
import '../../../../core/learning/quiz_generator.dart';

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
    final sampleItems = session.collocations.take(5).toList(growable: false);
    final vocab = _keyVocab(sampleItems);
    final grammar = _keyGrammar(sampleItems);
    final sampleQuiz = session.quizzes.isEmpty ? null : session.quizzes.first;

    return Card(
      color: colorScheme.surface.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _LessonHeader(title: _title, goal: _goal),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LessonChip(
                  icon: Icons.flag_outlined,
                  label: 'HSK${session.activeLevel}',
                ),
                if (lessonContext != null)
                  _LessonChip(
                    icon: Icons.bookmark_outline,
                    label: lessonContext!.lessonUnitId,
                  ),
                _LessonChip(
                  icon: Icons.quiz_outlined,
                  label: '${session.quizzes.length} quiz',
                ),
                _LessonChip(
                  icon: Icons.library_books_outlined,
                  label: '${session.collocations.length} examples',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _LessonSection(
              icon: Icons.track_changes_outlined,
              title: 'Goal / Can-do',
              child: Text(_canDo, style: Theme.of(context).textTheme.bodySmall),
            ),
            _LessonSection(
              icon: Icons.forum_outlined,
              title: 'Conversation context',
              child: _TokenWrap(values: _conversationTokens),
            ),
            _LessonSection(
              icon: Icons.translate_outlined,
              title: 'Key vocab',
              child: vocab.isEmpty
                  ? const Text('Từ vựng sẽ xuất hiện trong quiz.')
                  : _VocabTokenWrap(items: vocab),
            ),
            _LessonSection(
              icon: Icons.account_tree_outlined,
              title: 'Key grammar',
              child: grammar.isEmpty
                  ? const Text('Pattern được chọn từ câu luyện tập.')
                  : _TokenWrap(values: grammar),
            ),
            if (sampleQuiz != null)
              _LessonSection(
                icon: Icons.psychology_alt_outlined,
                title: 'Practice quiz',
                child: _PracticePreview(quiz: sampleQuiz),
              ),
            _LessonSection(
              icon: Icons.summarize_outlined,
              title: 'Summary',
              child: Text(
                'Hoàn thành bài với điểm từ 70% để mở khóa bước tiếp theo. Câu sai sẽ được gom vào phần luyện lại.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
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

  String get _canDo {
    if (lessonContext == null) {
      return 'Luyện nhận diện nghĩa, pinyin và điền từ trong câu theo dữ liệu đã kiểm định.';
    }
    return 'Học trong ${lessonContext!.moduleId}, tập trung ${_conversationTokens.join(', ')} và dùng đúng mẫu câu mục tiêu.';
  }

  List<String> get _conversationTokens {
    final conversations = lessonContext?.conversationIds ?? const [];
    if (conversations.isEmpty) return const ['Generated frames'];
    return conversations;
  }

  List<({String id, String label})> _keyVocab(List<CollocationItem> items) {
    final values = <({String id, String label})>[];
    final seen = <String>{};
    for (final item in items) {
      for (final id in item.targetVocabIds) {
        final text = _idTail(id);
        if (text.isEmpty || seen.contains(text)) continue;
        seen.add(text);
        values.add((id: id, label: text));
      }
    }
    return values.take(8).toList(growable: false);
  }

  List<String> _keyGrammar(List<CollocationItem> items) {
    final values = <String>[];
    for (final id in [
      ...?lessonContext?.grammarIds,
      for (final item in items) ...item.targetGrammarIds,
    ]) {
      if (id.isNotEmpty && !values.contains(id)) values.add(id);
    }
    return values.take(6).toList(growable: false);
  }

  String _idTail(String id) {
    final separator = id.indexOf('_');
    if (separator == -1 || separator == id.length - 1) return id;
    return id.substring(separator + 1);
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

class _LessonChip extends StatelessWidget {
  const _LessonChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16),
      label: Text(label),
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

class _PracticePreview extends StatelessWidget {
  const _PracticePreview({required this.quiz});

  final LearningQuiz quiz;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _quizTypeLabel(quiz.type),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Ví dụ: ${quiz.prompt}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Đáp án mục tiêu: ${quiz.answer}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _quizTypeLabel(QuizType type) {
    switch (type) {
      case QuizType.vocabRecognition:
        return 'Nhận diện nghĩa';
      case QuizType.vocabRecall:
        return 'Gợi nhớ từ';
      case QuizType.pinyinChoice:
        return 'Chọn pinyin';
      case QuizType.grammarChoice:
        return 'Chọn ngữ pháp';
      case QuizType.sentenceOrder:
        return 'Sắp xếp câu';
      case QuizType.clozeCollocation:
        return 'Điền từ vào câu';
    }
  }
}
