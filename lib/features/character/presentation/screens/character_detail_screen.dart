import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/screens/vocab_detail_screen.dart';
import 'package:hanzify/core/widgets/hanzify_detail_frame.dart';
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import '../providers/character_providers.dart';
import '../widgets/stroke_animation_widget.dart';

class CharacterDetailScreen extends ConsumerWidget {
  final String char;

  const CharacterDetailScreen({super.key, required this.char});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final c = themeColorsOfRef(ref);
    final charAsync = ref.watch(characterDetailProvider(char));
    final vocabAsync = ref.watch(vocabContainingCharProvider(char));

    return charAsync.when(
      loading: () => HanzifyDetailFrame(
        title: 'Chi tiết chữ',
        hero: _buildLoadingHero(cs),
        slivers: const [],
      ),
      error: (e, _) => HanzifyDetailFrame(
        title: 'Chi tiết chữ',
        hero: const SizedBox.shrink(),
        slivers: [
          SliverFillRemaining(
            child: HanzifyEmptyState.errorState(errorText: 'Lỗi tải dữ liệu "$char"'),
          ),
        ],
      ),
      data: (character) {
        if (character == null) {
          return HanzifyDetailFrame(
            title: 'Chi tiết chữ',
            hero: const SizedBox.shrink(),
            slivers: [
              SliverFillRemaining(
                child: HanzifyEmptyState.noCharacterData(character: char),
              ),
            ],
          );
        }

        return HanzifyDetailFrame(
          title: 'Chi tiết chữ',
          hero: _StrokeSection(strokes: character.strokes, colors: c, cs: cs),
          slivers: [
            SliverToBoxAdapter(
              child: _InfoSection(
                char: char,
                pinyin: character.pinyin,
                radical: character.radical,
                strokeCount: character.strokeCount,
                hskLevel: character.hskLevel,
                definitionVi: character.definitionVi,
                colors: c,
                cs: cs,
                theme: theme,
              ),
            ),
            SliverToBoxAdapter(
              child: vocabAsync.maybeWhen(
                data: (vocabList) => vocabList.isEmpty
                    ? const SizedBox.shrink()
                    : _VocabSection(char: char, vocabList: vocabList, colors: c, cs: cs, theme: theme),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingHero(ColorScheme cs) {
    return SizedBox(
      height: 320,
      child: Center(child: CircularProgressIndicator(color: cs.primary)),
    );
  }
}

class _StrokeSection extends StatelessWidget {
  final List<String> strokes;
  final AppThemeColors colors;
  final ColorScheme cs;

  const _StrokeSection({required this.strokes, required this.colors, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const HanzifySectionHeader(title: 'Thứ tự nét', icon: Icons.draw_rounded),
          const SizedBox(height: 16),
          Center(
            child: strokes.isEmpty
                ? _NoStrokeData(colors: colors, cs: cs)
                : Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: StrokeAnimationWidget(
                        svgStrokes: strokes,
                        colors: colors,
                        size: 260,
                        autoPlay: true,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NoStrokeData extends StatelessWidget {
  final AppThemeColors colors;
  final ColorScheme cs;
  const _NoStrokeData({required this.colors, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.draw_outlined, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'Chưa có dữ liệu nét',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String char;
  final String? pinyin;
  final String? radical;
  final int strokeCount;
  final int? hskLevel;
  final String? definitionVi;
  final AppThemeColors colors;
  final ColorScheme cs;
  final ThemeData theme;

  const _InfoSection({
    required this.char,
    this.pinyin,
    this.radical,
    required this.strokeCount,
    this.hskLevel,
    this.definitionVi,
    required this.colors,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Card.filled(
        color: cs.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'char_$char',
                    child: Text(
                      char,
                      style: AppTypography.hanziDisplay(fontSize: 72, color: cs.primary, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pinyin != null && pinyin!.isNotEmpty)
                          Text(
                            pinyin!,
                            style: AppTypography.pinyin(fontSize: 24, color: cs.secondary, fontWeight: FontWeight.bold),
                          ),
                        if (hskLevel != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'HSK $hskLevel',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.onPrimaryContainer),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (definitionVi != null && definitionVi!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  definitionVi!,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(label: 'Số nét', value: '$strokeCount', icon: Icons.edit_outlined, cs: cs, theme: theme),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(label: 'Bộ thủ', value: radical ?? '—', icon: Icons.category_outlined, cs: cs, theme: theme),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme cs;
  final ThemeData theme;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VocabSection extends StatelessWidget {
  final String char;
  final List<Vocab> vocabList;
  final AppThemeColors colors;
  final ColorScheme cs;
  final ThemeData theme;

  const _VocabSection({
    required this.char,
    required this.vocabList,
    required this.colors,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final display = vocabList.take(10).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HanzifySectionHeader(
            title: 'Từ chứa "$char"',
            icon: Icons.menu_book_rounded,
            trailing: Text('${vocabList.length}', style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          ),
          ...display.map((v) => _VocabRow(vocab: v, char: char, colors: colors, cs: cs, theme: theme)),
          if (vocabList.length > 10) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                '... và ${vocabList.length - 10} từ khác',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _VocabRow extends StatelessWidget {
  final Vocab vocab;
  final String char;
  final AppThemeColors colors;
  final ColorScheme cs;
  final ThemeData theme;

  const _VocabRow({
    required this.vocab,
    required this.char,
    required this.colors,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => VocabDetailScreen(vocab: vocab)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _HighlightedHanzi(hanzi: vocab.hanzi, targetChar: char, cs: cs),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vocab.pinyin, style: TextStyle(fontSize: 14, color: cs.secondary, fontWeight: FontWeight.bold)),
                    Text(
                      vocab.primaryMeaningVi,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
                child: Text('H${vocab.level}', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedHanzi extends StatelessWidget {
  final String hanzi;
  final String targetChar;
  final ColorScheme cs;

  const _HighlightedHanzi({required this.hanzi, required this.targetChar, required this.cs});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    for (final ch in hanzi.split('')) {
      spans.add(
        TextSpan(
          text: ch,
          style: AppTypography.hanziUi(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: ch == targetChar ? cs.primary : cs.onSurface,
          ),
        ),
      );
    }
    return RichText(text: TextSpan(children: spans));
  }
}
