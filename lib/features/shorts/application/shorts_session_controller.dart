import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/learning/application/study_session_recorder.dart';
import '../../../core/learning/domain/fsrs.dart';
import '../domain/short_feed_item.dart';
import '../domain/shorts_session.dart';

const int _remediationDelayContentCards = 3;

class _ShortsRemediationRequest {
  const _ShortsRemediationRequest({
    required this.targetKey,
    required this.delayContentCards,
  });

  final String targetKey;
  final int delayContentCards;
}

class _ShortsRemediationSelection {
  const _ShortsRemediationSelection({
    required this.item,
    required this.nextCursor,
  });

  final ShortFeedItem item;
  final int nextCursor;
}

class ShortsSessionController extends Notifier<ShortsSessionState> {
  static const _appendThreshold = 8;
  static const _appendContentCount = 12;

  @override
  ShortsSessionState build() => const ShortsSessionState();

  void start(ShortsSession session) {
    final sourceItems = session.sourceItems.isEmpty
        ? session.items
              .where(
                (item) =>
                    item.type != ShortCardType.summary &&
                    item.type != ShortCardType.miniTest,
              )
              .toList(growable: false)
        : session.sourceItems;
    state = ShortsSessionState(
      items: session.items,
      sourceItems: sourceItems,
      remediationItems: session.remediationItems,
      nextCursor: session.nextCursor,
      contentCount: session.contentCount,
      blockQuizzes: session.blockQuizzes,
    );
  }

  void hydrate(ShortsSession session) {
    if (state.items.isEmpty) {
      start(session);
      return;
    }

    final sourceItems = _mergeItems(state.sourceItems, session.sourceItems);
    final remediationItems = _mergeItems(
      state.remediationItems,
      session.remediationItems,
    );
    state = state.copyWith(
      sourceItems: sourceItems,
      remediationItems: remediationItems,
    );
  }

  void goTo(int index) {
    if (index < 0) return;
    final nextState = _ensureLoadedThrough(state, index);
    if (nextState.items.isEmpty) {
      if (!identical(nextState, state)) state = nextState;
      return;
    }
    final clamped = index >= nextState.items.length
        ? nextState.items.length - 1
        : index;
    state = nextState.copyWith(currentIndex: clamped);
  }

  void ensureLoadedThrough(int index) {
    if (index < 0) return;
    final nextState = _ensureLoadedThrough(state, index);
    if (!identical(nextState, state)) {
      state = nextState;
    }
  }

  void next() {
    goTo(state.currentIndex + 1);
  }

  ShortsSessionState _appendMore(ShortsSessionState current) {
    final generated = const ShortsSessionBuilder().generateItems(
      sourceItems: current.sourceItems,
      nextCursor: current.nextCursor,
      contentCount: current.contentCount,
      blockQuizzes: current.blockQuizzes,
      contentTarget: current.contentCount + _appendContentCount,
    );

    return current.copyWith(
      items: [...current.items, ...generated.items],
      nextCursor: generated.nextCursor,
      contentCount: generated.contentCount,
      blockQuizzes: generated.blockQuizzes,
    );
  }

  ShortsSessionState _ensureLoadedThrough(
    ShortsSessionState current,
    int index,
  ) {
    var nextState = current;
    while (nextState.sourceItems.isNotEmpty &&
        index >= nextState.items.length - _appendThreshold) {
      nextState = _appendMore(nextState);
    }
    return nextState;
  }

  void selectAnswer(ShortFeedItem item, String answer) {
    final payload = item.payload;
    if (payload is! ShortQuickQuiz) return;
    selectQuizAnswer(
      itemId: item.id,
      answer: answer,
      correctAnswer: payload.answer,
      quiz: payload,
    );
  }

  void selectQuizAnswer({
    required String itemId,
    required String answer,
    required String correctAnswer,
    ShortQuickQuiz? quiz,
  }) {
    if (state.selectedAnswers.containsKey(itemId)) return;

    final selectedAnswers = Map<String, String>.from(state.selectedAnswers)
      ..[itemId] = answer;
    final isCorrect = answer == correctAnswer;
    // Trả lời trống = hết giờ → bỏ qua (không phải lựa chọn của user).
    final vocabId = quiz?.targetVocabId;
    if (answer.isNotEmpty && vocabId != null && vocabId.isNotEmpty) {
      ref
          .read(studySessionRecorderProvider)
          .record(
            targetType: 'vocab',
            targetId: vocabId,
            rating: isCorrect ? SrsRating.good : SrsRating.again,
          );
    }
    var nextState = state.copyWith(
      selectedAnswers: selectedAnswers,
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
      incorrectCount: state.incorrectCount + (isCorrect ? 0 : 1),
    );
    final targetKey = quiz == null ? null : shortsTargetKeyForQuiz(quiz);
    if (!isCorrect && targetKey != null) {
      nextState = _insertRemediation(
        nextState,
        _ShortsRemediationRequest(
          targetKey: targetKey,
          delayContentCards: _remediationDelayContentCards,
        ),
      );
    }
    state = nextState;
  }

  ShortsSessionState _insertRemediation(
    ShortsSessionState current,
    _ShortsRemediationRequest request,
  ) {
    final selection = _nextRemediationFor(current, request.targetKey);
    if (selection == null) return current;

    final insertionIndex = _remediationInsertionIndex(
      current.items,
      current.currentIndex,
      request.targetKey,
      request.delayContentCards,
    );
    final items = [...current.items]..insert(insertionIndex, selection.item);
    final cursors = Map<String, int>.from(current.remediationCursorByTarget)
      ..[request.targetKey] = selection.nextCursor;

    return current.copyWith(items: items, remediationCursorByTarget: cursors);
  }

  _ShortsRemediationSelection? _nextRemediationFor(
    ShortsSessionState current,
    String targetKey,
  ) {
    final existingIds = current.items.map((item) => item.id).toSet();
    final candidates = current.remediationItems
        .where(
          (item) =>
              shortsTargetKeyForItem(item) == targetKey &&
              !existingIds.contains(item.id),
        )
        .toList(growable: false);
    if (candidates.isEmpty) return null;

    final cursor = current.remediationCursorByTarget[targetKey] ?? 0;
    final item = candidates[cursor % candidates.length];
    return _ShortsRemediationSelection(item: item, nextCursor: cursor + 1);
  }

  int _remediationInsertionIndex(
    List<ShortFeedItem> items,
    int currentIndex,
    String targetKey,
    int delayContentCards,
  ) {
    var contentSeen = 0;
    for (var index = currentIndex + 1; index < items.length; index++) {
      if (shortsIsContentCard(items[index])) contentSeen++;
      if (contentSeen < delayContentCards) continue;
      final insertionIndex = index + 1;
      if (!_recentTargetsContain(items, insertionIndex, targetKey)) {
        return insertionIndex;
      }
    }
    return items.length;
  }

  bool _recentTargetsContain(
    List<ShortFeedItem> items,
    int insertionIndex,
    String targetKey,
  ) {
    final start = insertionIndex - kShortsRecentTargetWindow < 0
        ? 0
        : insertionIndex - kShortsRecentTargetWindow;
    for (var index = start; index < insertionIndex; index++) {
      if (shortsTargetKeyForItem(items[index]) == targetKey) return true;
    }
    return false;
  }

  List<ShortFeedItem> _mergeItems(
    List<ShortFeedItem> current,
    List<ShortFeedItem> incoming,
  ) {
    if (incoming.isEmpty) return current;
    final seen = current.map((item) => item.id).toSet();
    final merged = [...current];
    for (final item in incoming) {
      if (seen.add(item.id)) merged.add(item);
    }
    return merged;
  }
}
