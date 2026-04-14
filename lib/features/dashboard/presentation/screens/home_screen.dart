import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final c = ref.watch(themeColorsProvider);

    final totalVocabAsync = ref.watch(allVocabProvider);
    final dueVocabAsync = ref.watch(dueVocabProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: () =>
                      ref.read(themeProvider.notifier).cycleTheme(),
                  icon: Icon(
                    themeMode == AppThemeMode.light
                        ? Icons.wb_sunny_outlined
                        : themeMode == AppThemeMode.dark
                        ? Icons.nightlight_round_outlined
                        : Icons.auto_stories_outlined,
                    color: Colors.white,
                  ),
                  tooltip: 'Change Theme',
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'HANZIFY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.primary.withValues(alpha: 
                            themeMode == AppThemeMode.dark ? 0.6 : 0.4,
                          ),
                          c.accent.withValues(alpha: 
                            themeMode == AppThemeMode.dark ? 0.3 : 0.2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: 20,
                    child: Text(
                      '禅',
                      style: TextStyle(
                        fontSize: 180,
                        color: Colors.white.withValues(alpha: 0.05),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats row as SliverGrid
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildListDelegate([
                _StatCard(
                  value: totalVocabAsync.when(
                    data: (list) => '${list.length}',
                    loading: () => '...',
                    error: (_, _) => '?',
                  ),
                  label: 'Total Words',
                  valueColor: c.primary,
                  colors: c,
                ),
                _StatCard(
                  value: dueVocabAsync.when(
                    data: (list) => '${list.length}',
                    loading: () => '...',
                    error: (_, _) => '?',
                  ),
                  label: 'Due Today',
                  valueColor: c.accent,
                  colors: c,
                ),
              ]),
            ),
          ),

          // Action cards
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  'Continue Learning',
                  style: TextStyle(
                    fontSize: AppFontSizes.titleLg,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Hero(
                tag: 'flashcard_hero',
                child: GestureDetector(
                  onTap: () => ref
                      .read(navigationProvider.notifier)
                      .navigate('flashcard'),
                  child: _FlashcardCTA(
                    colors: c,
                    dueCount: dueVocabAsync.value?.length ?? 0,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ActionCard(
                emoji: '🧠',
                heroTag: 'quiz_hero',
                title: 'Quiz Challenge',
                desc: 'Test your knowledge with multiple choice',
                colors: c,
                onTap: () => ref
                    .read(navigationProvider.notifier)
                    .navigate('quiz'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionCard(
                emoji: '📖',
                heroTag: 'vocab_list_hero',
                title: 'Word Library',
                desc: 'Browse & search vocabulary words',
                colors: c,
                onTap: () => ref
                    .read(navigationProvider.notifier)
                    .navigate('vocabList'),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ]),
          ),
        ],
      ),
    );
  }
}

class _FlashcardCTA extends StatelessWidget {
  final AppThemeColors colors;
  final int dueCount;
  const _FlashcardCTA({required this.colors, required this.dueCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      child: Row(
        children: [
          const Text('🧘', style: TextStyle(fontSize: 36)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flashcard Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dueCount > 0
                      ? '$dueCount cards waiting'
                      : 'Practice all cards',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xBFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '→',
            style: TextStyle(fontSize: 24, color: Color(0x99FFFFFF)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final AppThemeColors colors;
  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: AppFontSizes.headlineLg,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFontSizes.labelSm,
              fontWeight: FontWeight.w500,
              color: colors.placeholder,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final AppThemeColors colors;
  final VoidCallback onTap;
  final String? heroTag;
  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.colors,
    required this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget emojiContent = Text(emoji, style: const TextStyle(fontSize: 28));
    if (heroTag != null) {
      emojiContent = Hero(
        tag: heroTag!,
        child: Material(color: Colors.transparent, child: emojiContent),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surfaceLowest,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          children: [
            emojiContent,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSizes.titleMd,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySm,
                      color: colors.placeholder,
                    ),
                  ),
                ],
              ),
            ),
            Text('›', style: TextStyle(fontSize: 24, color: colors.disabled)),
          ],
        ),
      ),
    );
  }
}
