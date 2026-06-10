import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hsk_levels.dart';
import '../../../core/providers/performance_provider.dart';
import '../../../core/widgets/learning/learning_widgets.dart';
import '../../dictionary/data/library_repository.dart';
import '../../dictionary/domain/grammar_item.dart';
import '../../dictionary/domain/vocab_item.dart';
import '../../dictionary/presentation/widgets/grammar_detail_sheet.dart';
import '../../dictionary/presentation/widgets/vocab_detail_sheet.dart';
import '../application/shorts_session_controller.dart';
import '../data/shorts_feed_repository.dart';
import '../domain/shorts_session.dart';
import 'widgets/short_card.dart';

final shortsSessionLoaderProvider = FutureProvider<ShortsSession>((ref) async {
  const activeLevel = 2;
  final feed = await const ShortsFeedRepository().loadHskFeed(
    levels: [activeLevel],
    activeLevel: activeLevel,
    options: ShortsFeedLoadOptions.startup,
  );
  return const ShortsSessionBuilder(
    activeLevel: activeLevel,
    initialContentCount: 12,
    sourceItemLimit: 72,
  ).build(feed.items, remediationItems: feed.remediationItems);
});

final shortsHydratedSessionLoaderProvider = FutureProvider<ShortsSession>((
  ref,
) async {
  const activeLevel = 2;
  final feed = await const ShortsFeedRepository().loadHskFeed(
    levels: kHskLevels,
    activeLevel: activeLevel,
  );
  return const ShortsSessionBuilder(
    activeLevel: activeLevel,
  ).build(feed.items, remediationItems: feed.remediationItems);
});

final _shortsSessionControllerProvider =
    NotifierProvider<ShortsSessionController, ShortsSessionState>(
      ShortsSessionController.new,
    );

class ShortsFeedScreen extends ConsumerStatefulWidget {
  const ShortsFeedScreen({super.key});

  @override
  ConsumerState<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}

class _ShortsFeedScreenState extends ConsumerState<ShortsFeedScreen> {
  final _pageController = PageController();
  String? _startedSessionKey;
  bool _hydrationScheduled = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_prefetchNearEnd);
  }

  @override
  void dispose() {
    _pageController.removeListener(_prefetchNearEnd);
    _pageController.dispose();
    super.dispose();
  }

  void _prefetchNearEnd() {
    if (!mounted) return;
    final page = _pageController.page;
    if (page == null) return;
    ref
        .read(_shortsSessionControllerProvider.notifier)
        .ensureLoadedThrough(page.ceil() + 8);
  }

  Future<void> _showVocabDetail(String vocabId) async {
    try {
      final items = await ref.read(libraryRepositoryProvider).loadVocab();
      final item = _findVocab(items, vocabId);
      if (!mounted) return;
      if (item == null) {
        _showDetailSnackBar('Không tìm thấy chi tiết từ này.');
        return;
      }
      await VocabDetailSheet.show(context, item);
    } catch (_) {
      if (!mounted) return;
      _showDetailSnackBar('Không tải được chi tiết từ.');
    }
  }

  Future<void> _showGrammarDetail(String grammarId) async {
    try {
      final items = await ref.read(libraryRepositoryProvider).loadGrammar();
      final item = _findGrammar(items, grammarId);
      if (!mounted) return;
      if (item == null) {
        _showDetailSnackBar('Không tìm thấy chi tiết ngữ pháp này.');
        return;
      }
      await GrammarDetailSheet.show(context, item);
    } catch (_) {
      if (!mounted) return;
      _showDetailSnackBar('Không tải được chi tiết ngữ pháp.');
    }
  }

  VocabItem? _findVocab(List<VocabItem> items, String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  GrammarItem? _findGrammar(List<GrammarItem> items, String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _showDetailSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(shortsSessionLoaderProvider);

    return sessionAsync.when(
      loading: () => const Center(
        child: LearningLoadingView(message: 'Đang tải Shorts...'),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Không tải được feed: $error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (session) {
        final sessionKey = session.items.map((item) => item.id).join('|');
        if (_startedSessionKey != sessionKey) {
          _startedSessionKey = sessionKey;
          _hydrationScheduled = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref
                  .read(_shortsSessionControllerProvider.notifier)
                  .start(session);
              _scheduleHydration(session);
            }
          });
        }

        final items = ref.watch(
          _shortsSessionControllerProvider.select((state) => state.items),
        );
        final selectedAnswers = ref.watch(
          _shortsSessionControllerProvider.select(
            (state) => state.selectedAnswers,
          ),
        );
        final currentIndex = ref.watch(
          _shortsSessionControllerProvider.select(
            (state) => state.currentIndex,
          ),
        );
        final correctCount = ref.watch(
          _shortsSessionControllerProvider.select(
            (state) => state.correctCount,
          ),
        );
        final incorrectCount = ref.watch(
          _shortsSessionControllerProvider.select(
            (state) => state.incorrectCount,
          ),
        );
        final performance = readPerformance(ref);
        final visibleItems = items.isEmpty ? session.items : items;
        if (visibleItems.isEmpty) {
          return const Center(child: Text('Chưa có nội dung.'));
        }

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: ref
              .read(_shortsSessionControllerProvider.notifier)
              .goTo,
          itemBuilder: (context, index) {
            if (index >= visibleItems.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return ShortCard(
              item: visibleItems[index],
              index: index,
              totalCount: visibleItems.length,
              selectedAnswers: selectedAnswers,
              correctCount: correctCount,
              incorrectCount: incorrectCount,
              active: index == currentIndex,
              controller: ref.read(_shortsSessionControllerProvider.notifier),
              performance: performance,
              onShowVocabDetail: _showVocabDetail,
              onShowGrammarDetail: _showGrammarDetail,
            );
          },
        );
      },
    );
  }

  void _scheduleHydration(ShortsSession initialSession) {
    if (_hydrationScheduled || initialSession.sourceItems.isEmpty) return;
    _hydrationScheduled = true;
    Future<void>.delayed(const Duration(milliseconds: 900), () async {
      if (!mounted) return;
      try {
        final hydrated = await ref.read(
          shortsHydratedSessionLoaderProvider.future,
        );
        if (!mounted) return;
        ref.read(_shortsSessionControllerProvider.notifier).hydrate(hydrated);
      } catch (_) {
        // The lightweight startup feed is enough for offline use; hydration is
        // only a performance optimization for richer later cards/remediation.
      }
    });
  }
}
