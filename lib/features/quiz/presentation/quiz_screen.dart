import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hsk_levels.dart';
import '../../../core/providers/performance_provider.dart';
import '../../../core/widgets/hanzify_haptic.dart';
import '../../../core/widgets/sliver_page_scaffold.dart';
import '../application/quiz_pool.dart';
import 'drills/cloze_drill_screen.dart';
import 'drills/flashcard_drill_screen.dart';
import 'drills/multiple_choice_drill_screen.dart';
import 'drills/sentence_arrange_drill_screen.dart';
import 'drills/word_match_drill_screen.dart';

enum _QuizMode { multipleChoice, flashcard, cloze, wordMatch, sentenceArrange }

class _QuizModeSpec {
  const _QuizModeSpec({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.thumbnailAssetPath,
  });

  final _QuizMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final String thumbnailAssetPath;
}

const _modes = [
  _QuizModeSpec(
    mode: _QuizMode.multipleChoice,
    title: 'Chọn từ',
    subtitle: 'Chọn nghĩa đúng cho Hanzi hoặc cụm từ.',
    icon: Icons.checklist_rtl_rounded,
    thumbnailAssetPath: 'assets/images/gen_quiz_choice.svg',
  ),
  _QuizModeSpec(
    mode: _QuizMode.flashcard,
    title: 'Flashcard',
    subtitle: 'Lật thẻ và tự chấm mức nhớ.',
    icon: Icons.style_rounded,
    thumbnailAssetPath: 'assets/images/gen_quiz_flashcard.svg',
  ),
  _QuizModeSpec(
    mode: _QuizMode.cloze,
    title: 'Điền từ',
    subtitle: 'Chọn từ còn thiếu trong câu.',
    icon: Icons.edit_note_rounded,
    thumbnailAssetPath: 'assets/images/gen_quiz_cloze.svg',
  ),
  _QuizModeSpec(
    mode: _QuizMode.wordMatch,
    title: 'Nối từ',
    subtitle: 'Nối Hanzi với nghĩa tiếng Việt.',
    icon: Icons.compare_arrows_rounded,
    thumbnailAssetPath: 'assets/images/gen_quiz_match.svg',
  ),
  _QuizModeSpec(
    mode: _QuizMode.sentenceArrange,
    title: 'Sắp xếp',
    subtitle: 'Sắp xếp chữ thành câu đúng.',
    icon: Icons.reorder_rounded,
    thumbnailAssetPath: 'assets/images/gen_quiz_arrange.svg',
  ),
];

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(quizLevelProvider);
    final performance = readPerformance(ref);
    final cards = [
      for (var index = 0; index < _modes.length; index++)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child:
              ActionCard(
                    icon: _modes[index].icon,
                    title: _modes[index].title,
                    subtitle: _modes[index].subtitle,
                    thumbnailAssetPath: _modes[index].thumbnailAssetPath,
                    onTap: () => _openMode(context, _modes[index].mode, level),
                    trailing: Text(
                      'HSK $level',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  )
                  .animate(autoPlay: !performance)
                  .fadeIn(duration: 180.ms, delay: (index * 45).ms)
                  .slideY(begin: 0.05, end: 0, duration: 220.ms),
        ),
    ];

    return SliverPageScaffold(
      title: 'Quiz',
      subtitle: 'Chọn từ, flashcard, điền từ, nối từ và sắp xếp câu.',
      headerAssetPath: 'assets/images/gen_header_quiz.svg',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _LevelDropdown(level: level),
        ),
      ],
      slivers: [
        const SliverSectionHeader(
          title: 'Chế độ luyện tập',
          subtitle: 'Mỗi mode dùng dữ liệu HSK local và chạy offline.',
        ),
        SliverList.list(children: cards),
      ],
    );
  }

  void _openMode(BuildContext context, _QuizMode mode, int level) {
    HanzifyHaptic.selection();
    final screen = switch (mode) {
      _QuizMode.multipleChoice => MultipleChoiceDrillScreen(level: level),
      _QuizMode.flashcard => FlashcardDrillScreen(level: level),
      _QuizMode.cloze => ClozeDrillScreen(level: level),
      _QuizMode.wordMatch => WordMatchDrillScreen(level: level),
      _QuizMode.sentenceArrange => SentenceArrangeDrillScreen(level: level),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _LevelDropdown extends ConsumerWidget {
  const _LevelDropdown({required this.level});

  final int level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: level,
        borderRadius: BorderRadius.circular(12),
        items: [
          for (final lv in kHskLevels)
            DropdownMenuItem(value: lv, child: Text('HSK $lv')),
        ],
        onChanged: (lv) {
          if (lv == null) return;
          HanzifyHaptic.selection();
          ref.read(quizLevelProvider.notifier).set(lv);
        },
      ),
    );
  }
}
