import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_curves.dart';
import 'package:hanzify/core/theme/app_durations.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/providers/user_preferences_provider.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_tabbed_frame.dart';
import 'package:hanzify/features/conversation/domain/entities/conversation_context.dart';
import 'package:hanzify/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';
import 'package:hanzify/features/grammar/presentation/screens/grammar_detail_screen.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/screens/vocab_detail_screen.dart';
import 'package:hanzify/features/grammar/domain/entities/grammar_point.dart';
import 'package:hanzify/core/graph/graph_providers.dart';

class ConversationDetailScreen extends ConsumerStatefulWidget {
  final ConversationContext conversation;

  const ConversationDetailScreen({super.key, required this.conversation});

  @override
  ConsumerState<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState
    extends ConsumerState<ConversationDetailScreen> {
  bool _isPracticeMode = false;
  int _practiceIndex = 0;
  bool _showTranslation = false;

  int? _playingIndex;
  Timer? _playTimer;

  final Set<int> _viShown = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _playTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleAutoPlay(List<DialogueLine> lines) {
    if (_playingIndex != null) {
      _playTimer?.cancel();
      setState(() => _playingIndex = null);
      return;
    }
    _startAutoPlay(lines, 0);
  }

  void _startAutoPlay(List<DialogueLine> lines, int index) {
    setState(() => _playingIndex = index);
    _playTimer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final next = index + 1;
      if (next < lines.length) {
        _startAutoPlay(lines, next);
      } else {
        setState(() => _playingIndex = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final showPinyin = ref.watch(showPinyinProvider);
    final conv = widget.conversation;

    return HanzifyTabbedFrame(
      title: 'Chi tiết hội thoại',
      hero: _buildHeroCard(c, conv),
      tabLabels: const ['Hội thoại', 'Học thuật'],
      tabSlivers: [
        // Tab 1: Hội thoại
        [
          SliverToBoxAdapter(child: _buildModeToggle(c)),
          if (_isPracticeMode)
            SliverToBoxAdapter(child: _buildPracticeView(c, conv))
          else
            SliverToBoxAdapter(
                child: _buildDialogueView(c, conv, showPinyin)),
          if (conv.cultureTip.isNotEmpty)
            SliverToBoxAdapter(child: _buildCultureTip(c, conv)),
          SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xl)),
          SliverToBoxAdapter(child: _buildCTA(c)),
        ],
        // Tab 2: Từ vựng & Ngữ pháp (Học thuật)
        [
          SliverToBoxAdapter(child: _buildContextVocabs(c, conv)),
          SliverToBoxAdapter(child: _buildContextGrammars(c, context, conv)),
        ],
      ],
    );
  }

  // ── Hero card ────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(AppThemeColors c, ConversationContext conv) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: c.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadii.xxxl),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(conv.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: AppSpacing.md),
                HanzifyBadge.hsk(level: conv.level, colors: c, filled: false),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              conv.titleZh,
              style: AppTypography.hanziDisplay(
                fontSize: AppFontSizes.displayMd,
                fontWeight: FontWeight.w700,
                color: c.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              conv.titlePinyin,
              style: AppTypography.pinyin(
                  fontSize: AppFontSizes.bodyMd, color: c.onPrimarySoft),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              conv.title,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                fontSize: AppFontSizes.bodyLg,
                color: c.onPrimarySoft,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              conv.description,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                fontSize: AppFontSizes.bodyMd,
                color: Colors.white.withValues(alpha: 0.70),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mode toggle ──────────────────────────────────────────────────────────────
  Widget _buildModeToggle(AppThemeColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        child: Row(
          children: [
            _ModeTab(
              label: 'Đọc hội thoại',
              selected: !_isPracticeMode,
              color: c.primary,
              unselectedColor: c.onSurfaceVariant,
              onTap: () => setState(() {
                _isPracticeMode = false;
                _practiceIndex = 0;
                _showTranslation = false;
                _playTimer?.cancel();
                _playingIndex = null;
              }),
            ),
            _ModeTab(
              label: 'Luyện tập',
              selected: _isPracticeMode,
              color: c.primary,
              unselectedColor: c.onSurfaceVariant,
              onTap: () => setState(() {
                _isPracticeMode = true;
                _practiceIndex = 0;
                _showTranslation = false;
                _playTimer?.cancel();
                _playingIndex = null;
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogue view ────────────────────────────────────────────────────────────
  Widget _buildDialogueView(
      AppThemeColors c, ConversationContext conv, bool showPinyin) {
    final isPlaying = _playingIndex != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 18, color: c.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Text('Hội thoại', style: AppTypography.sectionTitle()),
              const Spacer(),
              _PlayButton(
                isPlaying: isPlaying,
                onTap: () => _toggleAutoPlay(conv.lines),
                color: c.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...conv.lines.mapIndexed((index, line) {
          final speakerInfo =
              conv.speakers.where((s) => s.code == line.speaker).firstOrNull;
          final isA = line.speaker == 'A';
          final isPlayingThis = _playingIndex == index;

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            child: _ConversationBubble(
              line: line,
              speakerInfo: speakerInfo,
              isA: isA,
              showPinyin: showPinyin,
              isPlaying: isPlayingThis,
              viShown: _viShown.contains(index),
              onToggleVi: () => setState(() {
                if (_viShown.contains(index)) {
                  _viShown.remove(index);
                } else {
                  _viShown.add(index);
                }
              }),
              colors: c,
            ),
          );
        }),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  // ── Practice view ────────────────────────────────────────────────────────────
  Widget _buildPracticeView(AppThemeColors c, ConversationContext conv) {
    if (conv.lines.isEmpty) return const SizedBox.shrink();

    final line = conv.lines[_practiceIndex];
    final speakerInfo =
        conv.speakers.where((s) => s.code == line.speaker).firstOrNull;
    final isLast = _practiceIndex >= conv.lines.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        HanzifySectionHeader(
          title: 'Luyện tập (${_practiceIndex + 1}/${conv.lines.length})',
          icon: Icons.school_outlined,
        ),
        const SizedBox(height: AppSpacing.lg),
        AnimatedSwitcher(
          duration: AppDurations.normal,
          switchInCurve: AppCurves.enter,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _PracticeCard(
            key: ValueKey(_practiceIndex),
            line: line,
            speakerInfo: speakerInfo,
            showTranslation: _showTranslation,
            onToggleTranslation: () =>
                setState(() => _showTranslation = !_showTranslation),
            colors: c,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              if (_practiceIndex > 0) ...[
                Expanded(
                  child: _NavButton(
                    label: 'Trước',
                    icon: Icons.arrow_back_rounded,
                    isPrimary: false,
                    colors: c,
                    onTap: () => setState(() {
                      _practiceIndex--;
                      _showTranslation = false;
                    }),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: _NavButton(
                  label: isLast ? 'Hoàn thành' : 'Tiếp theo',
                  icon: isLast ? null : Icons.arrow_forward_rounded,
                  isPrimary: true,
                  colors: c,
                  onTap: () {
                    if (isLast) {
                      ref
                          .read(conversationListProvider.notifier)
                          .toggleMastered(widget.conversation);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Chúc mừng! Đã hoàn thành "${widget.conversation.title}"'),
                        ),
                      );
                    } else {
                      setState(() {
                        _practiceIndex++;
                        _showTranslation = false;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Context Vocabs (graph-powered, fallback sang inline) ──────────────────────
  Widget _buildContextVocabs(AppThemeColors c, ConversationContext conv) {
    final graphAsync = ref.watch(conversationContextVocabsProvider(conv.id));

    Widget buildContent(List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Card.filled(
            color: c.surfaceLow,
            margin: EdgeInsets.zero,
            child: ExpansionTile(
              title: const Text('Từ vựng trong bài', style: TextStyle(fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.menu_book_rounded),
              childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
              children: children,
            ),
          ),
        ),
      );
    }

    Widget buildFallback() {
      if (conv.vocabulary.isEmpty) return const SizedBox.shrink();
      final children = conv.vocabulary.map((v) => _InlineVocabCard(vocab: v, colors: c)).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          buildContent(children),
        ],
      );
    }

    return graphAsync.when(
      data: (vocabs) {
        if (vocabs.isEmpty && conv.vocabulary.isEmpty) return const SizedBox.shrink();
        if (vocabs.isEmpty) return buildFallback();
        
        final children = vocabs.map((v) => _VocabContextCard(vocab: v, colors: c)).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            buildContent(children),
          ],
        );
      },
      loading: buildFallback,
      error: (_, _) => buildFallback(),
    );
  }

  // ── Context Grammars (graph-powered, fallback sang relatedGrammar) ─────────────
  Widget _buildContextGrammars(
      AppThemeColors c, BuildContext context, ConversationContext conv) {
    final graphAsync = ref.watch(conversationContextGrammarsProvider(conv.id));

    return graphAsync.when(
      data: (grammars) {
        if (grammars.isEmpty && conv.relatedGrammar.isEmpty) {
          return const SizedBox.shrink();
        }
        final items = grammars.isNotEmpty ? grammars : null;
        return _buildGrammarSection(c, context, conv, items);
      },
      loading: () => _buildRelatedGrammar(c, context, conv),
      error: (_, _) => _buildRelatedGrammar(c, context, conv),
    );
  }

  // ── Culture tip ───────────────────────────────────────────────────────────────
  Widget _buildCultureTip(AppThemeColors c, ConversationContext conv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const HanzifySectionHeader(
            title: 'Gợi ý văn hóa', icon: Icons.lightbulb_outline_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: HanzifyCard(
            color: c.warning.withValues(alpha: 0.06),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.tips_and_updates_rounded,
                      size: 22, color: c.warning),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(conv.cultureTip,
                      style: AppTypography.body(
                          fontSize: AppFontSizes.bodyMd,
                          color: c.text,
                          height: 1.6)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Grammar section — graph-powered ──────────────────────────────────────────
  Widget _buildGrammarSection(AppThemeColors c, BuildContext context,
      ConversationContext conv, List<GrammarPoint>? grammars) {
    if (grammars != null && grammars.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          const HanzifySectionHeader(
              title: 'Ngữ pháp liên quan', icon: Icons.link_rounded),
          ...grammars.map((g) => _GrammarCard(grammar: g, colors: c, context: context)),
        ],
      );
    }
    return _buildRelatedGrammar(c, context, conv);
  }

  // ── Related grammar — fallback (dùng grammarListProvider) ─────────────────────
  Widget _buildRelatedGrammar(
      AppThemeColors c, BuildContext context, ConversationContext conv) {
    if (conv.relatedGrammar.isEmpty) return const SizedBox.shrink();
    final allGrammarAsync = ref.watch(grammarListProvider);
    final allGrammar = allGrammarAsync.asData?.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const HanzifySectionHeader(
            title: 'Ngữ pháp liên quan', icon: Icons.link_rounded),
        ...conv.relatedGrammar.map((relatedId) {
          final related =
              allGrammar.where((g) => g.id == relatedId).firstOrNull;
          if (related == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
            child: HanzifyCard(
              variant: HanzifyCardVariant.glass,
              padding: const EdgeInsets.all(AppSpacing.lg),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        GrammarDetailScreen(grammar: related)));
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      related.structure.isNotEmpty
                          ? related.structure.substring(0, 1)
                          : '文',
                      style: AppTypography.hanziUi(
                        fontSize: AppFontSizes.headlineSm,
                        fontWeight: FontWeight.w700,
                        color: c.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(related.title,
                            style: AppTypography.label(
                                fontSize: AppFontSizes.titleSm,
                                fontWeight: FontWeight.w700,
                                color: c.text)),
                        const SizedBox(height: 2),
                        Text(related.structure,
                            style: AppTypography.body(
                                fontSize: AppFontSizes.bodySm,
                                color: c.placeholder)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: c.disabled),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── CTA ───────────────────────────────────────────────────────────────────────
  Widget _buildCTA(AppThemeColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _isPracticeMode = true;
            _practiceIndex = 0;
            _showTranslation = false;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: c.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadii.xxxl),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Bắt đầu luyện tập',
                style: AppTypography.label(
                  fontSize: AppFontSizes.titleMd,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Vocab card — graph Vocab entity ──────────────────────────────────────────

class _VocabContextCard extends StatelessWidget {
  final Vocab vocab;
  final AppThemeColors colors;

  const _VocabContextCard({required this.vocab, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final vi = vocab.meanings.isNotEmpty ? vocab.meanings.first.vi : '';
    final pos = vocab.meanings.isNotEmpty ? vocab.meanings.first.pos : '';
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
      child: HanzifyCard(
        variant: HanzifyCardVariant.glass,
        padding: const EdgeInsets.all(AppSpacing.lg),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VocabDetailScreen(vocab: vocab)));
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              alignment: Alignment.center,
              child: Text(
                vocab.hanzi,
                style: AppTypography.hanziUi(
                  fontSize: AppFontSizes.headlineSm,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(vocab.pinyin,
                          style: AppTypography.pinyin(
                              fontSize: AppFontSizes.bodySm, color: c.primary)),
                      if (pos.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.surfaceLow,
                            borderRadius: BorderRadius.circular(AppRadii.full),
                          ),
                          child: Text(pos,
                              style: AppTypography.label(
                                  fontSize: AppFontSizes.labelSm,
                                  color: c.placeholder)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(vi,
                      style: AppTypography.body(
                          fontSize: AppFontSizes.bodyMd,
                          color: c.text,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: c.disabled),
          ],
        ),
      ),
    );
  }
}

// ── Vocab card — inline (từ conversation.vocabulary) ─────────────────────────

class _InlineVocabCard extends StatelessWidget {
  final dynamic vocab; // VocabularyEntry from ConversationContext
  final AppThemeColors colors;

  const _InlineVocabCard({required this.vocab, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
      child: HanzifyCard(
        variant: HanzifyCardVariant.glass,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              alignment: Alignment.center,
              child: Text(
                vocab.zh as String,
                style: AppTypography.hanziUi(
                  fontSize: AppFontSizes.headlineSm,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(vocab.pinyin as String,
                          style: AppTypography.pinyin(
                              fontSize: AppFontSizes.bodySm, color: c.primary)),
                      if ((vocab.pos as String).isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.surfaceLow,
                            borderRadius: BorderRadius.circular(AppRadii.full),
                          ),
                          child: Text(vocab.pos as String,
                              style: AppTypography.label(
                                  fontSize: AppFontSizes.labelSm,
                                  color: c.placeholder)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(vocab.vi as String,
                      style: AppTypography.body(
                          fontSize: AppFontSizes.bodyMd,
                          color: c.text,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grammar card ──────────────────────────────────────────────────────────────

class _GrammarCard extends StatelessWidget {
  final GrammarPoint grammar;
  final AppThemeColors colors;
  final BuildContext context;

  const _GrammarCard(
      {required this.grammar, required this.colors, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final c = colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
      child: HanzifyCard(
        variant: HanzifyCardVariant.glass,
        padding: const EdgeInsets.all(AppSpacing.lg),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GrammarDetailScreen(grammar: grammar)));
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                grammar.structure.isNotEmpty
                    ? grammar.structure.substring(0, 1)
                    : '文',
                style: AppTypography.hanziUi(
                  fontSize: AppFontSizes.headlineSm,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(grammar.title,
                      style: AppTypography.label(
                          fontSize: AppFontSizes.titleSm,
                          fontWeight: FontWeight.w700,
                          color: c.text)),
                  const SizedBox(height: 2),
                  Text(grammar.structure,
                      style: AppTypography.body(
                          fontSize: AppFontSizes.bodySm,
                          color: c.placeholder)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: c.disabled),
          ],
        ),
      ),
    );
  }
}

// ── Chat bubble widget ────────────────────────────────────────────────────────

class _ConversationBubble extends StatelessWidget {
  final DialogueLine line;
  final SpeakerInfo? speakerInfo;
  final bool isA;
  final bool showPinyin;
  final bool isPlaying;
  final bool viShown;
  final VoidCallback onToggleVi;
  final AppThemeColors colors;

  const _ConversationBubble({
    required this.line,
    required this.speakerInfo,
    required this.isA,
    required this.showPinyin,
    required this.isPlaying,
    required this.viShown,
    required this.onToggleVi,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final bubbleColor = isA ? c.primaryContainer : c.surfaceLow;
    final speakerColor = _parseColor(speakerInfo?.avatarColor ?? '#6C63FF');

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadii.xxl),
      topRight: const Radius.circular(AppRadii.xxl),
      bottomLeft: Radius.circular(isA ? AppRadii.xs : AppRadii.xxl),
      bottomRight: Radius.circular(isA ? AppRadii.xxl : AppRadii.xs),
    );

    final bubble = AnimatedContainer(
      duration: AppDurations.normal,
      curve: AppCurves.transform,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: radius,
        border: isPlaying
            ? Border.all(color: c.primary, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            speakerInfo?.nameVi ?? 'Người ${line.speaker}',
            style: AppTypography.label(
              fontSize: AppFontSizes.labelSm,
              fontWeight: FontWeight.w700,
              color: isA ? c.primary : c.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            line.zh,
            style: AppTypography.hanziUi(
              fontSize: AppFontSizes.headlineSm,
              fontWeight: FontWeight.w600,
              color: c.text,
            ),
          ),
          if (showPinyin && line.pinyin.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              line.pinyin,
              style: AppTypography.pinyin(
                fontSize: AppFontSizes.bodyMd,
                color: c.primary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: onToggleVi,
            child: AnimatedCrossFade(
              duration: AppDurations.fast,
              crossFadeState: viShown
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.translate_rounded,
                      size: 14, color: c.placeholder),
                  const SizedBox(width: 4),
                  Text(
                    'Nhấn để dịch',
                    style: AppTypography.label(
                      fontSize: AppFontSizes.labelSm,
                      color: c.placeholder,
                    ),
                  ),
                ],
              ),
              secondChild: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    margin:
                        const EdgeInsets.only(right: AppSpacing.sm, top: 3),
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      line.vi,
                      style: AppTypography.body(
                        fontSize: AppFontSizes.bodyMd,
                        color: c.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final avatar = _SpeakerAvatar(code: line.speaker, color: speakerColor);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: isA
          ? [
              avatar,
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: bubble),
              const SizedBox(width: AppSpacing.xxxl),
            ]
          : [
              const SizedBox(width: AppSpacing.xxxl),
              Expanded(child: bubble),
              const SizedBox(width: AppSpacing.sm),
              avatar,
            ],
    );
  }

  static Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }
}

class _SpeakerAvatar extends StatelessWidget {
  final String code;
  final Color color;

  const _SpeakerAvatar({required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        style: AppTypography.label(
          fontSize: AppFontSizes.labelMd,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

// ── Play button ───────────────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final Color color;

  const _PlayButton({
    required this.isPlaying,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isPlaying
              ? color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(
            color: isPlaying ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              isPlaying ? 'Dừng' : 'Tự động',
              style: AppTypography.label(
                fontSize: AppFontSizes.labelSm,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Practice card ─────────────────────────────────────────────────────────────

class _PracticeCard extends StatelessWidget {
  final DialogueLine line;
  final SpeakerInfo? speakerInfo;
  final bool showTranslation;
  final VoidCallback onToggleTranslation;
  final AppThemeColors colors;

  const _PracticeCard({
    super.key,
    required this.line,
    required this.speakerInfo,
    required this.showTranslation,
    required this.onToggleTranslation,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: c.surfaceLowest,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          boxShadow: c.cardShadow,
        ),
        child: Column(
          children: [
            Text(
              '${speakerInfo?.nameVi ?? 'Người ${line.speaker}'}'
              '${speakerInfo?.role.isNotEmpty == true ? ' (${speakerInfo!.role})' : ''}',
              style: AppTypography.label(
                fontSize: AppFontSizes.labelLg,
                color: c.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              line.zh,
              textAlign: TextAlign.center,
              style: AppTypography.hanziDisplay(
                fontSize: AppFontSizes.displayMd,
                fontWeight: FontWeight.w700,
                color: c.text,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              line.pinyin,
              textAlign: TextAlign.center,
              style: AppTypography.pinyin(
                  fontSize: AppFontSizes.bodyLg, color: c.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: onToggleTranslation,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: showTranslation
                      ? c.primary.withValues(alpha: 0.06)
                      : c.surfaceLow,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                    color: showTranslation
                        ? c.primary.withValues(alpha: 0.2)
                        : c.disabled.withValues(alpha: 0.2),
                  ),
                ),
                child: showTranslation
                    ? Text(
                        line.vi,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          fontSize: AppFontSizes.bodyLg,
                          color: c.text,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 18, color: c.placeholder),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Nhấn để xem dịch nghĩa',
                              style: AppTypography.body(
                                  fontSize: AppFontSizes.bodyMd,
                                  color: c.placeholder)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav button ────────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPrimary;
  final AppThemeColors colors;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isPrimary ? c.primaryGradient : null,
          color: isPrimary ? null : c.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isPrimary)
              Icon(Icons.arrow_back_rounded,
                  size: 18, color: isPrimary ? Colors.white : c.text),
            if (!isPrimary) const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.label(
                fontSize: AppFontSizes.labelLg,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : c.text,
              ),
            ),
            if (isPrimary && icon != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(icon, size: 18, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Mode tab ──────────────────────────────────────────────────────────────────

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.color,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.label(
              fontSize: AppFontSizes.labelMd,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : unselectedColor,
            ),
          ),
        ),
      ),
    );
  }
}
