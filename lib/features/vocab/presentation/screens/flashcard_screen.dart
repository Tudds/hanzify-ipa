import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/vocab/presentation/widgets/vocab_card.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _reviewedCount = 0;
  bool _isFinished = false;
  bool? _scoreFeedback;
  bool _isConfiguring = true; // Bắt đầu bằng màn hình cấu hình

  // Các tùy chọn cấu hình
  int _selectedHsk = 0;
  bool _onlyDue = false;
  bool _onlyBookmarked = false;
  int _limit = 20;

  List<Vocab>? _sessionCards;
  final List<Vocab> _reviewedCardsList = [];

  late PageController _pageController;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flipCtrl.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  Future<void> _handleScore(
    List<Vocab> cards, // Legacy argument, no longer functionally used for the whole list
    int score,
    AppThemeColors c,
  ) async {
    if (_sessionCards == null) return;
    final vocab = _sessionCards![_currentIndex];

    // Non-blocking update to state
    ref.read(dueVocabProvider.notifier).review(vocab, score);

    setState(() {
      _scoreFeedback = score >= 4;
      
      if (!_reviewedCardsList.any((v) => v.id == vocab.id)) {
        _reviewedCount++;
        _reviewedCardsList.add(vocab);
      }

      if (score < 3) {
        _sessionCards!.add(vocab); // Add to end for re-review
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _scoreFeedback = null);
    });

    if (_currentIndex + 1 >= _sessionCards!.length) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _isFinished = true);
      return;
    }

    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(themeColorsProvider);
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW - 48;

    if (_isConfiguring) {
      return _buildSetup(c);
    }

    final sessionAsync = ref.watch(flashcardSessionProvider);

    return sessionAsync.when(
      loading: () => Scaffold(
        backgroundColor: c.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: c.background,
        body: Center(child: Text('Lỗi: $err', style: TextStyle(color: c.error))),
      ),
      data: (cards) {
        if (cards == null) return const SizedBox(); // Chưa bắt đầu session

        _sessionCards ??= List.from(cards);

        final sessionCards = _sessionCards!;
        if (sessionCards.isEmpty && _reviewedCount == 0) return _buildEmptyState(c);
        if (_isFinished) return _buildFinished(c);
        return _buildMain(sessionCards, c, cardW);
      },
    );
  }

  Widget _buildSetup(AppThemeColors c) {
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(c, 0, 0),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cấu hình bộ thẻ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tùy chỉnh để bắt đầu phiên học hiệu quả nhất.',
                      style: TextStyle(fontSize: 15, color: c.placeholder),
                    ),
                    const SizedBox(height: 32),

                    // ── HSK Levels ───────────────────────────────────────────
                    _sectionTitle('Cấp độ HSK', c),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [0, 1, 2, 3, 4, 5, 6].map((lvl) {
                        final isSelected = _selectedHsk == lvl;
                        return ChoiceChip(
                          label: Text(lvl == 0 ? 'Tất cả' : 'HSK $lvl'),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedHsk = lvl),
                          selectedColor: c.primary.withValues(alpha: 0.2),
                          checkmarkColor: c.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? c.primary : c.text,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // ── Study Modes ──────────────────────────────────────────
                    _sectionTitle('Chế độ học', c),
                    const SizedBox(height: 12),
                    () {
                      final dueCount = ref.watch(dueVocabProvider).value?.length ?? 0;
                      final isEnabled = dueCount > 0;
                      
                      // Nếu không có từ đến hạn, không thể chọn OnlyDue
                      if (!isEnabled && _onlyDue) {
                        _onlyDue = false;
                      }

                      return _buildModeTile(
                        title: 'Ôn luyện định kỳ',
                        subtitle: isEnabled 
                            ? 'Có $dueCount từ đã đến hạn ôn tập.' 
                            : 'Chưa có từ nào đến hạn ôn tập.',
                        icon: Icons.history_rounded,
                        isSelected: _onlyDue && !_onlyBookmarked,
                        c: c,
                        enabled: isEnabled,
                        onTap: () => setState(() {
                          _onlyDue = true;
                          _onlyBookmarked = false;
                        }),
                      );
                    }(),
                    _buildModeTile(
                      title: 'Học mọi từ',
                      subtitle: 'Bao gồm cả từ mới chưa học.',
                      icon: Icons.auto_awesome_rounded,
                      isSelected: !_onlyDue && !_onlyBookmarked,
                      c: c,
                      onTap: () => setState(() {
                        _onlyDue = false;
                        _onlyBookmarked = false;
                      }),
                    ),
                    _buildModeTile(
                      title: 'Chỉ mục Yêu thích',
                      subtitle: 'Ôn tập các từ bạn đã đánh dấu ⭐.',
                      icon: Icons.star_rounded,
                      isSelected: _onlyBookmarked,
                      c: c,
                      onTap: () => setState(() {
                        _onlyBookmarked = true;
                        _onlyDue = false;
                      }),
                    ),
                    const SizedBox(height: 32),

                    // ── Limit ────────────────────────────────────────────────
                    _sectionTitle('Số lượng từ vựng', c),
                    const SizedBox(height: 12),
                    Row(
                      children: [10, 20, 50, -1].map((limitVal) {
                        final isSelected = _limit == limitVal;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _limit = limitVal),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? c.primary : c.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? c.primary : c.disabled.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                limitVal == -1 ? 'Tất cả' : '$limitVal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : c.text,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            
            // ── Footer Action ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Reset cache
                    _sessionCards = null;
                    _reviewedCount = 0;
                    _currentIndex = 0;
                    _isFinished = false;
                    _reviewedCardsList.clear();

                    ref.read(flashcardSessionProvider.notifier).startSession(
                      hskLevel: _selectedHsk,
                      onlyBookmarked: _onlyBookmarked,
                      onlyDue: _onlyDue,
                      limit: _limit,
                    );
                    setState(() => _isConfiguring = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Bắt đầu học ngay',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, AppThemeColors c) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: c.accent,
      ),
    );
  }

  Widget _buildModeTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required AppThemeColors c,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? c.primary.withValues(alpha: 0.08) : c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? c.primary : c.disabled.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? c.primary : c.disabled.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : c.placeholder,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? c.primary : c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: c.placeholder),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: c.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors c) {
    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          _buildHeader(c, 0, 0),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            c.accent.withValues(alpha: 0.15),
                            c.primary.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🎉', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Không có từ nào cần ôn!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy quay lại sau hoặc thêm từ vựng mới.',
                      style: TextStyle(
                        fontSize: 15,
                        color: c.placeholder,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(navigationProvider.notifier)
                          .navigate('home'),
                      child: const Text('Về Trang Chủ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinished(AppThemeColors c) {
    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 60, 32, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.primary.withValues(alpha: 0.2),
                          c.accent.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🏆', style: TextStyle(fontSize: 56)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hoàn thành!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn đã ôn tập $_reviewedCount từ vựng',
                    style: TextStyle(fontSize: 16, color: c.placeholder),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () =>
                        ref.read(navigationProvider.notifier).navigate('home'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 40,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [c.primary, c.accent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: c.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Về Trang Chủ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: VocabCardWidget(item: _reviewedCardsList[index], colors: c),
                );
              },
              childCount: _reviewedCardsList.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildMain(List<Vocab> cards, AppThemeColors c, double cardW) {
    final progress = (_currentIndex + 1) / cards.length;

    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          _buildHeader(c, _currentIndex, cards.length),
          Container(
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: c.disabled.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c.primary, c.accent]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: _isFlipped
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _isFlipped = false;
                });
                _flipCtrl.value = 0;
              },
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }

                    return Center(
                      child: Transform.scale(
                        scale: Curves.easeOut.transform(value),
                        child: Opacity(
                          opacity: value,
                          child: _buildDismissibleCard(
                            cards[index],
                            c,
                            cardW,
                            index,
                            cards,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _buildMiddleScoreButtons(cards, c),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleCard(
    Vocab vocab,
    AppThemeColors c,
    double cardW,
    int index,
    List<Vocab> allCards,
  ) {
    if (!_isFlipped) {
      return GestureDetector(
        onTap: _flipCard,
        child: Hero(
          tag: index == 0 ? 'flashcard_hero' : 'flashcard_hero_${vocab.id}',
          child: Material(
            color: Colors.transparent,
            child: _buildFront(vocab, c, cardW),
          ),
        ),
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _flipAnim,
            builder: (_, child) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnim.value * pi),
              child: _flipAnim.value < 0.5
                  ? _buildFront(vocab, c, cardW)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildBack(vocab, c, cardW),
                    ),
            ),
          ),
        ),
        _buildScoreFeedbackOverlay(c),
      ],
    );
  }

  Widget _buildScoreFeedbackOverlay(AppThemeColors c) {
    if (_scoreFeedback == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _scoreFeedback!
                ? c.success.withValues(alpha: 0.15)
                : c.danger.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: Icon(
              _scoreFeedback!
                  ? Icons.check_circle_rounded
                  : Icons.replay_rounded,
              size: 80,
              color: (_scoreFeedback! ? c.success : c.danger).withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildMiddleScoreButtons(List<Vocab> cards, AppThemeColors c) {
    final vocab = cards[_currentIndex];
    
    // Simple mock calculation for next interval preview
    String getHint(int score) {
      if (score == 0) return 'Học lại';
      int currentInterval = vocab.interval;
      if (currentInterval == 0) return '1 ngày';
      if (score == 3) return '${max(1, (currentInterval * 1.2).round())} ngày';
      if (score == 4) return '${max(2, (currentInterval * 1.5).round())} ngày';
      return '${max(4, (currentInterval * 2.2).round())} ngày';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGradeBtn(cards, 0, 'Quên', '😵', c.danger, c, getHint(0)),
          const SizedBox(width: 8),
          _buildGradeBtn(cards, 3, 'Khó', '😰', c.warning, c, getHint(3)),
          const SizedBox(width: 8),
          _buildGradeBtn(cards, 4, 'Tốt', '😊', const Color(0xFF3B82F6), c, getHint(4)),
          const SizedBox(width: 8),
          _buildGradeBtn(cards, 5, 'Dễ', '🤩', c.success, c, getHint(5)),
        ],
      ),
    );
  }

  Widget _buildGradeBtn(
    List<Vocab> cards,
    int score,
    String label,
    String emoji,
    Color color,
    AppThemeColors c,
    String hint,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleScore(cards, score, c),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                hint,
                style: TextStyle(
                  color: c.placeholder,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors c, int current, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => ref.read(navigationProvider.notifier).navigate('home'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '← Về',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: c.primary,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: c.surfaceLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${total > 0 ? current + 1 : 0} / $total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFront(Vocab vocab, AppThemeColors c, double cardW) {
    return Container(
      width: cardW,
      height: cardW * 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.surface, c.surfaceLow],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: c.disabled.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c.accent.withValues(alpha: 0.2),
                    c.accent.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'HSK ${vocab.level}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _getLevelColor(vocab.level),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vocab.hanzi,
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c.primary, c.accent]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flip_rounded, size: 16, color: c.disabled),
                const SizedBox(width: 6),
                Text(
                  'Chạm để lật thẻ',
                  style: TextStyle(fontSize: 13, color: c.disabled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(Vocab vocab, AppThemeColors c, double cardW) {
    return Container(
      width: cardW,
      height: cardW * 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.surfaceLow, c.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: c.disabled.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            const SizedBox(height: 8),
            Text(
              vocab.hanzi,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: c.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              vocab.pinyin,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: c.primary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 1,
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c.disabled.withValues(alpha: 0.0),
                    c.disabled.withValues(alpha: 0.4),
                    c.disabled.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Meanings (structured, max 3) ─────────────────────────────────
            if (vocab.meanings.isNotEmpty)
              ..._buildBackMeanings(vocab, c)
            else
              Text(
                vocab.meaning,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: c.text,
                ),
                textAlign: TextAlign.center,
              ),

            // ── First example sentence ────────────────────────────────────────
            if (vocab.exampleSentences.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.primary.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vocab.exampleSentences.first.cn.isNotEmpty)
                      Text(
                        vocab.exampleSentences.first.cn,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.text,
                          height: 1.5,
                        ),
                      ),
                    if (vocab.exampleSentences.first.pinyin.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        vocab.exampleSentences.first.pinyin,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.primary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (vocab.exampleSentences.first.vi.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        vocab.exampleSentences.first.vi,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.placeholder,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}

  List<Widget> _buildBackMeanings(Vocab vocab, AppThemeColors c) {
    const posColorMap = <String, Color>{
      'v': Color(0xFF3B82F6),
      'n': Color(0xFF10B981),
      'adj': Color(0xFFF59E0B),
      'adv': Color(0xFF8B5CF6),
      'prep': Color(0xFFEF4444),
      'conj': Color(0xFFEC4899),
      'pron': Color(0xFF06B6D4),
      'num': Color(0xFF84CC16),
      'mw': Color(0xFF6366F1),
      'aux': Color(0xFFF97316),
      'interj': Color(0xFF14B8A6),
    };
    const posLabelMap = <String, String>{
      'v': 'Động từ (动词)',
      'n': 'Danh từ (名词)',
      'adj': 'Tính từ (形容词)',
      'adv': 'Trạng từ (副词)',
      'prep': 'Giới từ (介词)',
      'conj': 'Liên từ (连词)',
      'pron': 'Đại từ (代词)',
      'num': 'Số từ (数词)',
      'mw': 'Lượng từ (量词)',
      'aux': 'Trợ từ (助词)',
      'interj': 'Thán từ (叹词)',
      'other': 'Khác (其他)',
    };
    return vocab.meanings.take(3).map((m) {
      final color = posColorMap[m.pos] ?? const Color(0xFF9CA3AF);
      final label = posLabelMap[m.pos] ?? m.pos;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              m.vi,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: c.text,
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getLevelColor(int level) {
    const colors = {
      1: Color(0xFF10B981),
      2: Color(0xFF3B82F6),
      3: Color(0xFFF59E0B),
      4: Color(0xFFEF4444),
      5: Color(0xFF8B5CF6),
      6: Color(0xFFEC4899),
    };
    return colors[level] ?? const Color(0xFF6B7280);
  }
}
