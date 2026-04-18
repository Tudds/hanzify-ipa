import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/theme/app_theme_helper.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/widgets/hanzify_app_bar.dart';
import 'package:hanzify/core/widgets/hanzify_empty_state.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/features/vocab/presentation/screens/flashcard/widgets/flashcard_setup_view.dart';
import 'package:hanzify/features/vocab/presentation/screens/flashcard/widgets/flashcard_study_view.dart';
import 'package:hanzify/features/vocab/presentation/screens/flashcard/widgets/flashcard_finished_view.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _reviewedCount = 0;
  bool _isFinished = false;
  bool? _scoreFeedback;
  bool _isConfiguring = true;

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
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
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

  Future<void> _handleScore(int score) async {
    if (_sessionCards == null) return;
    final vocab = _sessionCards![_currentIndex];

    // Cập nhật SRS logic
    ref.read(dueVocabProvider.notifier).review(vocab, score);

    setState(() {
      _scoreFeedback = score >= 4;
      if (!_reviewedCardsList.any((v) => v.id == vocab.id)) {
        _reviewedCount++;
        _reviewedCardsList.add(vocab);
      }
      if (score < 3) {
        _sessionCards!.add(vocab); // Học lại thẻ này cuối phiên
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
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _startSession() {
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
  }

  @override
  Widget build(BuildContext context) {
    final c = themeColorsOf(context);

    if (_isConfiguring) {
      return FlashcardSetupView(
        selectedHsk: _selectedHsk,
        onlyDue: _onlyDue,
        onlyBookmarked: _onlyBookmarked,
        limit: _limit,
        onHskChanged: (val) => setState(() => _selectedHsk = val),
        onModeChanged: (due, bookmarked) => setState(() {
          _onlyDue = due;
          _onlyBookmarked = bookmarked;
        }),
        onLimitChanged: (val) => setState(() => _limit = val),
        onStart: _startSession,
        header: _buildHeader(c, 0, 0),
      );
    }

    final sessionAsync = ref.watch(flashcardSessionProvider);

    return sessionAsync.when(
      loading: () => Scaffold(backgroundColor: c.background, body: const Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(backgroundColor: c.background, body: Center(child: Text('Lỗi: $err', style: TextStyle(color: c.error)))),
      data: (cards) {
        if (cards == null) return const SizedBox();
        _sessionCards ??= List.from(cards);
        final sessionCards = _sessionCards!;

        if (sessionCards.isEmpty && _reviewedCount == 0) {
          return _buildEmptyState(c);
        }
        if (_isFinished) {
          return FlashcardFinishedView(reviewedCount: _reviewedCount, reviewedCards: _reviewedCardsList);
        }

        return FlashcardStudyView(
          cards: sessionCards,
          currentIndex: _currentIndex,
          isFlipped: _isFlipped,
          scoreFeedback: _scoreFeedback,
          onFlip: _flipCard,
          onScore: _handleScore,
          pageController: _pageController,
          flipAnim: _flipAnim,
          header: _buildHeader(c, _currentIndex, sessionCards.length),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
              // Reset flip state khi vuốt sang card mới
              if (_isFlipped) {
                _flipCtrl.reverse();
                _isFlipped = false;
              }
            });
          },
        );
      },
    );
  }

  Widget _buildHeader(AppThemeColors c, int current, int total) {
    return HanzifyAppBar(
      backStyle: HanzifyBackButtonStyle.pill,
      backLabel: _isConfiguring ? '← Về' : '← Thoát',
      onBackTap: () {
        if (_isConfiguring) {
          ref.read(navigationProvider.notifier).navigate(AppRoutes.home);
        } else {
          setState(() => _isConfiguring = true);
        }
      },
      title: !_isConfiguring ? 'Thẻ ${current + 1} / $total' : null,
      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.placeholder),
      trailing: !_isConfiguring ? const SizedBox(width: 80) : null,
    );
  }

  Widget _buildEmptyState(AppThemeColors c) {
    return Scaffold(
      backgroundColor: c.background,
      body: HanzifyEmptyState.celebration(
        emojiText: '🎉',
        titleText: 'Không có từ nào cần ôn!',
        action: ElevatedButton(
          onPressed: () => setState(() => _isConfiguring = true),
          child: const Text('Quay lại'),
        ),
      ),
    );
  }
}
