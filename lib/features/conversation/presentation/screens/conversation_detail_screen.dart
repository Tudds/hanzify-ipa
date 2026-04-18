import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/typography.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/providers/user_preferences_provider.dart';
import 'package:hanzify/core/widgets/hanzify_card.dart';
import 'package:hanzify/core/widgets/hanzify_badge.dart';
import 'package:hanzify/core/widgets/hanzify_section_header.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';
import 'package:hanzify/features/conversation/domain/entities/conversation_context.dart';
import 'package:hanzify/features/conversation/presentation/providers/conversation_providers.dart';

import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';
import 'package:hanzify/features/grammar/presentation/screens/grammar_detail_screen.dart';

class ConversationDetailScreen extends ConsumerStatefulWidget {
  final ConversationContext conversation;

  const ConversationDetailScreen({super.key, required this.conversation});

  @override
  ConsumerState<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState
    extends ConsumerState<ConversationDetailScreen> {
  /// Chế độ hiển thị: đọc (full) hoặc luyện tập (hide Vietnamese)
  bool _isPracticeMode = false;

  /// Chỉ số dòng hiện tại trong chế độ luyện tập
  int _practiceIndex = 0;

  /// Có hiển thị dịch nghĩa ở dòng hiện tại không
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);
    final showPinyin = ref.watch(showPinyinProvider);
    final conv = widget.conversation;

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        MediaQuery.of(context).padding.top + AppSpacing.sm),
              ),
              // ── Header
              SliverToBoxAdapter(child: _buildHeader(context, c)),

              // ── Hero card
              SliverToBoxAdapter(child: _buildHeroCard(c, conv)),

              // ── Mode toggle
              SliverToBoxAdapter(child: _buildModeToggle(c)),

              // ── Dialogue lines
              if (_isPracticeMode)
                SliverToBoxAdapter(child: _buildPracticeView(c, conv))
              else
                SliverToBoxAdapter(
                    child: _buildDialogueView(c, conv, showPinyin)),

              // ── Vocabulary
              if (conv.vocabulary.isNotEmpty)
                SliverToBoxAdapter(child: _buildVocabulary(c, conv)),

              // ── Culture tip
              if (conv.cultureTip.isNotEmpty)
                SliverToBoxAdapter(child: _buildCultureTip(c, conv)),

              // ── Related Grammar
              if (conv.relatedGrammar.isNotEmpty)
                SliverToBoxAdapter(
                    child: _buildRelatedGrammar(c, ref, context, conv)),

              // ── Bottom CTA
              SliverToBoxAdapter(child: _buildCTA(c)),

              SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom +
                            AppSpacing.xxl),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Header
  Widget _buildHeader(BuildContext context, AppThemeColors c) {
    return HanzifyAppBar(
      backStyle: HanzifyBackButtonStyle.rounded,
      backBoxShadow: c.cardShadow,
      title: 'Chi tiết hội thoại',
    );
  }

  // ── Hero card
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
              color: c.primary.withValues(alpha: 0.3),
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
                fontSize: AppFontSizes.bodyMd,
                color: c.onPrimarySoft,
              ),
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
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mode toggle
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
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _isPracticeMode = false;
                  _practiceIndex = 0;
                  _showTranslation = false;
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: !_isPracticeMode ? c.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Đọc hội thoại',
                    style: AppTypography.label(
                      fontSize: AppFontSizes.labelMd,
                      fontWeight: FontWeight.w700,
                      color: !_isPracticeMode
                          ? Colors.white
                          : c.placeholder,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _isPracticeMode = true;
                  _practiceIndex = 0;
                  _showTranslation = false;
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _isPracticeMode ? c.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Luyện tập',
                    style: AppTypography.label(
                      fontSize: AppFontSizes.labelMd,
                      fontWeight: FontWeight.w700,
                      color: _isPracticeMode
                          ? Colors.white
                          : c.placeholder,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Full dialogue view
  Widget _buildDialogueView(
      AppThemeColors c, ConversationContext conv, bool showPinyin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        HanzifySectionHeader(
            title: 'Hội thoại', icon: Icons.chat_bubble_outline_rounded),
        ...conv.lines.map((line) {
          final speakerInfo = conv.speakers
              .where((s) => s.code == line.speaker)
              .firstOrNull;
          final isSpeakerA = line.speaker == 'A';

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSpeakerA)
                  _buildSpeakerAvatar(c, speakerInfo, line.speaker),
                if (isSpeakerA) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isSpeakerA
                          ? c.surfaceLowest
                          : c.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            isSpeakerA ? AppRadii.xs : AppRadii.xxl),
                        topRight: Radius.circular(
                            isSpeakerA ? AppRadii.xxl : AppRadii.xs),
                        bottomLeft: const Radius.circular(AppRadii.xxl),
                        bottomRight: const Radius.circular(AppRadii.xxl),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Speaker name
                        Text(
                          speakerInfo?.nameVi ?? 'Người ${line.speaker}',
                          style: AppTypography.label(
                            fontSize: AppFontSizes.labelSm,
                            color: c.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Chinese
                        Text(
                          line.zh,
                          style: AppTypography.hanziUi(
                            fontSize: AppFontSizes.headlineSm,
                            fontWeight: FontWeight.w600,
                            color: c.text,
                          ),
                        ),
                        if (showPinyin && line.pinyin.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            line.pinyin,
                            style: AppTypography.pinyin(
                              fontSize: AppFontSizes.bodyMd,
                              color: c.primary,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        // Vietnamese
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3,
                              height: 16,
                              margin: const EdgeInsets.only(
                                  right: AppSpacing.sm, top: 3),
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
                      ],
                    ),
                  ),
                ),
                if (!isSpeakerA) const SizedBox(width: AppSpacing.md),
                if (!isSpeakerA)
                  _buildSpeakerAvatar(c, speakerInfo, line.speaker),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Practice view (line by line, hide translation by default)
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
            title:
                'Luyện tập (${_practiceIndex + 1}/${conv.lines.length})',
            icon: Icons.school_outlined),
        const SizedBox(height: AppSpacing.lg),
        Padding(
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
                // Speaker
                Text(
                  '${speakerInfo?.nameVi ?? 'Người ${line.speaker}'}${speakerInfo != null ? ' (${speakerInfo.role})' : ''}',
                  style: AppTypography.label(
                    fontSize: AppFontSizes.labelLg,
                    color: c.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Chinese
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
                // Pinyin (always shown in practice)
                Text(
                  line.pinyin,
                  textAlign: TextAlign.center,
                  style: AppTypography.pinyin(
                    fontSize: AppFontSizes.bodyLg,
                    color: c.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Translation (show/hide)
                GestureDetector(
                  onTap: () =>
                      setState(() => _showTranslation = !_showTranslation),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: _showTranslation
                          ? c.primary.withValues(alpha: 0.06)
                          : c.surfaceLow,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: _showTranslation
                            ? c.primary.withValues(alpha: 0.2)
                            : c.disabled.withValues(alpha: 0.2),
                      ),
                    ),
                    child: _showTranslation
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
                              Text(
                                'Nhấn để xem dịch nghĩa',
                                style: AppTypography.body(
                                  fontSize: AppFontSizes.bodyMd,
                                  color: c.placeholder,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              if (_practiceIndex > 0)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _practiceIndex--;
                      _showTranslation = false;
                    }),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: c.surfaceLow,
                        borderRadius: BorderRadius.circular(AppRadii.xxl),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_rounded,
                              size: 18, color: c.text),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Trước',
                            style: AppTypography.label(
                              fontSize: AppFontSizes.labelLg,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_practiceIndex > 0) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isLast) {
                      // Mark as mastered
                      ref
                          .read(conversationListProvider.notifier)
                          .toggleMastered(widget.conversation);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Chúc mừng! Bạn đã hoàn thành bài hội thoại "${widget.conversation.title}"'),
                        ),
                      );
                    } else {
                      setState(() {
                        _practiceIndex++;
                        _showTranslation = false;
                      });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: c.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadii.xxl),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast ? 'Hoàn thành' : 'Tiếp theo',
                          style: AppTypography.label(
                            fontSize: AppFontSizes.labelLg,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (!isLast) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Icon(Icons.arrow_forward_rounded,
                              size: 18, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Speaker avatar
  Widget _buildSpeakerAvatar(
      AppThemeColors c, SpeakerInfo? speakerInfo, String code) {
    final colorHex = speakerInfo?.avatarColor ?? '#6C63FF';
    final color = _parseColor(colorHex);

    return Container(
      width: 36,
      height: 36,
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

  Color _parseColor(String hex) {
    try {
      final hexStr = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexStr', radix: 16));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }

  // ── Vocabulary section
  Widget _buildVocabulary(AppThemeColors c, ConversationContext conv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const HanzifySectionHeader(
            title: 'Từ vựng trong bài', icon: Icons.menu_book_rounded),
        ...conv.vocabulary.map((vocab) => Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
              child: HanzifyCard(
                color: c.surfaceLowest,
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
                        vocab.zh,
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
                              Text(
                                vocab.pinyin,
                                style: AppTypography.pinyin(
                                  fontSize: AppFontSizes.bodySm,
                                  color: c.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              if (vocab.pos.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2),
                                  decoration: BoxDecoration(
                                    color: c.surfaceLow,
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.full),
                                  ),
                                  child: Text(
                                    vocab.pos,
                                    style: AppTypography.label(
                                      fontSize: AppFontSizes.labelSm,
                                      color: c.placeholder,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            vocab.vi,
                            style: AppTypography.body(
                              fontSize: AppFontSizes.bodyMd,
                              color: c.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ── Culture tip
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
                  child: Text(
                    conv.cultureTip,
                    style: AppTypography.body(
                      fontSize: AppFontSizes.bodyMd,
                      color: c.text,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Related Grammar
  Widget _buildRelatedGrammar(AppThemeColors c, WidgetRef ref,
      BuildContext context, ConversationContext conv) {
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
              color: c.surfaceLowest,
              padding: const EdgeInsets.all(AppSpacing.lg),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GrammarDetailScreen(grammar: related),
                  ),
                );
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
                      related.structure.length > 1
                          ? related.structure.substring(0, 1)
                          : related.structure,
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
                        Text(
                          related.title,
                          style: AppTypography.label(
                            fontSize: AppFontSizes.titleSm,
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          related.structure,
                          style: AppTypography.body(
                            fontSize: AppFontSizes.bodySm,
                            color: c.placeholder,
                          ),
                        ),
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

  // ── CTA button
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
                color: c.primary.withValues(alpha: 0.3),
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
