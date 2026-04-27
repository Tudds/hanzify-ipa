import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/providers/user_preferences_provider.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/core/widgets/highlighted_text.dart';
import 'package:hanzify/core/widgets/hanzify_loading_indicator.dart';
import 'package:hanzify/core/widgets/hanzify_tabbed_frame.dart';
import 'package:hanzify/core/utils/pos_labels.dart' show posLabelFull;
import 'package:hanzify/core/widgets/hanzify_bookmark_button.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/character/presentation/providers/character_providers.dart';
import 'package:hanzify/features/character/presentation/widgets/stroke_animation_widget.dart';
import 'package:hanzify/features/conversation/presentation/screens/conversation_detail_screen.dart';
import 'package:hanzify/core/graph/graph_providers.dart';
import 'package:hanzify/features/character/presentation/screens/character_detail_screen.dart';

class VocabDetailScreen extends ConsumerStatefulWidget {
  final Vocab vocab;

  const VocabDetailScreen({super.key, required this.vocab});

  @override
  ConsumerState<VocabDetailScreen> createState() => _VocabDetailScreenState();
}

class _VocabDetailScreenState extends ConsumerState<VocabDetailScreen> {
  int? _activeCharIndex;

  Vocab get vocab => widget.vocab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final c = themeColorsOf(context);
    final showPinyin = ref.watch(showPinyinProvider);

    return HanzifyTabbedFrame(
      appBarTrailing: _buildBookmarkButton(c),
      hero: _buildHero(cs, c, showPinyin),
      tabLabels: const ['Tổng quan', 'Ứng dụng'],
      tabSlivers: [
        // Tab 1: Tổng quan
        [
          SliverToBoxAdapter(child: _buildMeanings(theme, cs, c)),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildWritingGuide(context, ref, c, cs)),
        ],
        // Tab 2: Ứng dụng
        [
          SliverToBoxAdapter(child: _buildExamples(theme, cs, c, showPinyin)),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildRelatedConversations(theme, cs, c, context)),
        ],
      ],
    );
  }

  Widget _buildBookmarkButton(AppThemeColors c) {
    return HanzifyBookmarkButton(
      isBookmarked: vocab.isBookmarked,
      colors: c,
      onTap: () {
        ref.read(allVocabProvider.notifier).toggleBookmark(vocab);
      },
    );
  }

  // Section divider removed since we use tabs now

  Widget _buildHero(ColorScheme cs, AppThemeColors c, bool showPinyin) {
    final fontSize = vocab.hanzi.length > 3 ? 64.0 : 96.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.6),
            cs.primaryContainer.withValues(alpha: 0.15),
            cs.surface,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: vocab.hanzi.split('').map((char) {
              return Hero(
                tag: 'char_$char',
                child: Text(
                  char,
                  style: AppTypography.hanziDisplay(
                    fontSize: fontSize,
                    color: cs.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            vocab.pinyin,
            style: AppTypography.pinyin(
              fontSize: 24,
              color: cs.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWritingGuide(BuildContext context, WidgetRef ref, AppThemeColors c, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HanzifySectionHeader(title: 'Chi tiết từng chữ', icon: Icons.draw_rounded),
        if (vocab.characters.isNotEmpty)
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vocab.characters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                return _CharacterStrokeCard(
                  char: vocab.characters[index],
                  colors: c,
                  isSelected: _activeCharIndex == index,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    if (_activeCharIndex == index) {
                      // Chạm lần 2: Chuyển sang chi tiết
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CharacterDetailScreen(char: vocab.characters[index]),
                        ),
                      );
                    } else {
                      // Chạm lần 1: Mở preview
                      setState(() {
                        _activeCharIndex = index;
                      });
                    }
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMeanings(ThemeData theme, ColorScheme cs, AppThemeColors c) {
    final groupedMeanings = vocab.groupedByPos;
    final posKeys = groupedMeanings.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HanzifySectionHeader(title: 'Nghĩa & từ loại', icon: Icons.menu_book_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HanzifyBadge.hsk(level: vocab.level, colors: c),
        ),
        const SizedBox(height: 16),
        ...posKeys.map((pos) {
          final meanings = groupedMeanings[pos]!;
          final posLabel = posLabelFull(pos);
          final posColor = c.posColors[pos] ?? cs.primary;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: posColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        posLabel,
                        style: TextStyle(fontSize: 12, color: posColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Divider(color: posColor.withValues(alpha: 0.1))),
                  ],
                ),
                const SizedBox(height: 12),
                Card.filled(
                  color: cs.surfaceContainerLow,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < meanings.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          _buildMeaningRow(meanings[i], theme, cs, posColor),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMeaningRow(Meaning m, ThemeData theme, ColorScheme cs, Color posColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(width: 6, height: 6, decoration: BoxDecoration(color: posColor, shape: BoxShape.circle)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            m.vi,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildExamples(ThemeData theme, ColorScheme cs, AppThemeColors c, bool showPinyin) {
    if (vocab.exampleSentences.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HanzifySectionHeader(title: 'Câu ví dụ', icon: Icons.format_quote_rounded),
        ...vocab.exampleSentences.map(
          (ex) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Card.filled(
              color: cs.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HanzifyHighlightedText(
                      text: ex.cn,
                      highlight: vocab.hanzi,
                      baseStyle: AppTypography.hanziUi(fontSize: 20, color: cs.onSurface),
                      colors: c,
                    ),
                    const SizedBox(height: 4),
                    Text(ex.pinyin, style: TextStyle(fontSize: 14, color: cs.secondary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(border: Border(left: BorderSide(color: cs.primaryContainer, width: 4))),
                      child: Text(ex.vi, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedConversations(ThemeData theme, ColorScheme cs, AppThemeColors c, BuildContext context) {
    final convsAsync = ref.watch(vocabRelatedConversationsProvider(vocab.id));

    return convsAsync.when(
      data: (convs) {
        if (convs.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Card.filled(
              color: cs.surfaceContainerLow,
              margin: EdgeInsets.zero,
              child: ExpansionTile(
                title: const Text('Hội thoại liên quan', style: TextStyle(fontWeight: FontWeight.bold)),
                leading: const Icon(Icons.chat_bubble_outline_rounded),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                children: convs.map((conv) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Card.filled(
                    color: cs.surfaceContainerHigh,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConversationDetailScreen(conversation: conv)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(conv.icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(conv.titleZh, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(conv.title, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _CharacterStrokeCard extends ConsumerWidget {
  final String char;
  final AppThemeColors colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterStrokeCard({
    required this.char,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final charAsync = ref.watch(characterDetailProvider(char));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        width: isSelected ? 180 : 100,
        child: Card.filled(
          color: isSelected ? cs.primaryContainer : cs.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isSelected) ...[
                  Text(char, style: AppTypography.hanziDisplay(fontSize: 32, color: cs.onSurface)),
                  charAsync.maybeWhen(
                    data: (character) => character?.pinyin != null
                        ? Text(character!.pinyin!, style: TextStyle(fontSize: 12, color: cs.primary))
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.open_in_new_rounded, size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                ] else
                  charAsync.when(
                    loading: () => const HanzifyLoadingIndicator(size: 32),
                    error: (e, _) => Text(char, style: AppTypography.hanziDisplay(fontSize: 32, color: cs.onSurface)),
                    data: (character) {
                      if (character == null || character.strokes.isEmpty) {
                        return Text(char, style: AppTypography.hanziDisplay(fontSize: 32, color: cs.onSurface));
                      }
                      return Column(
                        children: [
                          Text(char, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          StrokeAnimationWidget(
                            svgStrokes: character.strokes,
                            colors: colors,
                            size: 100,
                            autoPlay: true,
                            showControls: false,
                            loop: true,
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
