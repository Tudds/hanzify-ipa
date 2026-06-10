import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/widgets/learning/learning_widgets.dart';
import '../../application/shorts_session_controller.dart';
import '../../domain/short_feed_item.dart';
import 'short_context_cards.dart';

class ShortQuizView extends StatelessWidget {
  const ShortQuizView({
    super.key,
    required this.itemId,
    required this.quiz,
    required this.selected,
    required this.onSelect,
    required this.onTimeout,
    required this.active,
    required this.performance,
  });

  final String itemId;
  final ShortQuickQuiz quiz;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onTimeout;
  final bool active;
  final bool performance;

  @override
  Widget build(BuildContext context) {
    return _TimedQuizView(
      key: ValueKey(itemId),
      quiz: quiz,
      selected: selected,
      onSelect: onSelect,
      onTimeout: onTimeout,
      active: active,
      performance: performance,
    );
  }
}

class ShortMiniTestView extends StatelessWidget {
  const ShortMiniTestView({
    super.key,
    required this.itemId,
    required this.payload,
    required this.selectedAnswers,
    required this.controller,
    required this.active,
    required this.performance,
  });

  final String itemId;
  final ShortMiniTest payload;
  final Map<String, String> selectedAnswers;
  final ShortsSessionController controller;
  final bool active;
  final bool performance;

  @override
  Widget build(BuildContext context) {
    if (payload.quizzes.isEmpty) {
      return const SizedBox.shrink();
    }
    final activeIndex = _activeQuizIndex();
    final quiz = payload.quizzes[activeIndex];
    final answerId = '$itemId:$activeIndex';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          payload.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          '${activeIndex + 1}/${payload.quizzes.length}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        ShortQuizView(
          itemId: answerId,
          quiz: quiz,
          selected: selectedAnswers[answerId],
          onSelect: (answer) => controller.selectQuizAnswer(
            itemId: answerId,
            answer: answer,
            correctAnswer: quiz.answer,
            quiz: quiz,
          ),
          onTimeout: () => controller.selectQuizAnswer(
            itemId: answerId,
            answer: '',
            correctAnswer: quiz.answer,
            quiz: quiz,
          ),
          active: active,
          performance: performance,
        ),
      ],
    );
  }

  int _activeQuizIndex() {
    for (var index = 0; index < payload.quizzes.length; index++) {
      if (!selectedAnswers.containsKey('$itemId:$index')) {
        return index;
      }
    }
    return payload.quizzes.length - 1;
  }
}

class _TimedQuizView extends StatefulWidget {
  const _TimedQuizView({
    super.key,
    required this.quiz,
    required this.selected,
    required this.onSelect,
    required this.onTimeout,
    required this.active,
    required this.performance,
  });

  final ShortQuickQuiz quiz;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onTimeout;
  final bool active;
  final bool performance;

  @override
  State<_TimedQuizView> createState() => _TimedQuizViewState();
}

class _TimedQuizViewState extends State<_TimedQuizView> {
  static const _duration = Duration(seconds: 30);

  Timer? _timer;
  var _remainingSeconds = _duration.inSeconds;
  var _locked = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _TimedQuizView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quiz != widget.quiz ||
        oldWidget.selected != widget.selected ||
        oldWidget.active != widget.active) {
      _locked = widget.selected != null;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!widget.active) return;
    _remainingSeconds = _duration.inSeconds;
    if (widget.selected != null) {
      _locked = true;
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _locked) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _handleTimeout();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  Future<void> _handleChoice(String choice) async {
    if (_locked) return;
    _timer?.cancel();
    setState(() => _locked = true);
    await _showFeedback(choice: choice, timedOut: false);
    if (!mounted) return;
    widget.onSelect(choice);
  }

  Future<void> _handleTimeout() async {
    if (_locked) return;
    setState(() {
      _locked = true;
      _remainingSeconds = 0;
    });
    await _showFeedback(choice: null, timedOut: true);
    if (!mounted) return;
    widget.onTimeout();
  }

  Future<void> _showFeedback({
    required String? choice,
    required bool timedOut,
  }) {
    return showLearningQuizFeedbackDialog(
      context: context,
      prompt: widget.quiz.prompt,
      promptPinyin: widget.quiz.promptPinyin,
      answer: widget.quiz.answer,
      selectedAnswer: choice,
      isCorrect: choice == widget.quiz.answer,
      timedOut: timedOut,
      meaning: widget.quiz.promptMeaning,
      explanation: widget.quiz.explanation,
      noSelectionText: 'Chưa chọn',
      performance: widget.performance,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selected = widget.selected;
    final indexedChoices = [
      for (var index = 0; index < widget.quiz.choices.length; index++)
        (index: index, choice: widget.quiz.choices[index]),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = MediaQuery.sizeOf(context).width;
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : fallbackWidth;
        final compact = width < 430;
        final horizontalPadding = (width * 0.045).clamp(12.0, 18.0).toDouble();
        final verticalPadding = (width * 0.04).clamp(12.0, 16.0).toDouble();
        final promptGap = (width * 0.065).clamp(18.0, 28.0).toDouble();
        final choicesGap = (width * 0.075).clamp(22.0, 32.0).toDouble();
        return ShortCardVectorFrame(
          assetPath: 'assets/images/shorts_quiz_card_frame.svg',
          accentHeight: 20,
          opacity: 0.44,
          showArtwork: widget.active && !widget.performance,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LearningCountdownProgress(
                  seconds: _remainingSeconds,
                  totalSeconds: _duration.inSeconds,
                ),
                SizedBox(height: promptGap),
                LearningQuizPrompt(
                  prompt: widget.quiz.prompt,
                  promptPinyin: widget.quiz.promptPinyin,
                  audioUrl: widget.quiz.audioUrl,
                  quizType: widget.quiz.quizType,
                  compact: compact,
                  animate: widget.active && !widget.performance,
                ),
                SizedBox(height: choicesGap),
                for (final entry in indexedChoices) ...[
                  widget.performance || !widget.active
                      ? LearningAnswerChoiceButton(
                          choice: entry.choice,
                          state: _choiceState(entry.choice, selected),
                          prominent: !compact,
                          onPressed:
                              _choiceState(entry.choice, selected) ==
                                  LearningAnswerChoiceState.idle
                              ? () => _handleChoice(entry.choice)
                              : null,
                        )
                      : LearningAnswerChoiceButton(
                              choice: entry.choice,
                              state: _choiceState(entry.choice, selected),
                              prominent: !compact,
                              onPressed:
                                  _choiceState(entry.choice, selected) ==
                                      LearningAnswerChoiceState.idle
                                  ? () => _handleChoice(entry.choice)
                                  : null,
                            )
                            .animate()
                            .fadeIn(
                              duration: MotionTokens.fast,
                              delay: (40 * entry.index).ms,
                            )
                            .slideY(
                              begin: 0.04,
                              end: 0,
                              duration: MotionTokens.medium,
                            ),
                  const SizedBox(height: 12),
                ],
                if (selected != null && widget.quiz.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  widget.performance || !widget.active
                      ? Text(
                          widget.quiz.explanation,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(height: 1.35),
                        )
                      : Text(
                              widget.quiz.explanation,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                height: 1.35,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: MotionTokens.fast)
                            .slideY(
                              begin: 0.12,
                              end: 0,
                              duration: MotionTokens.medium,
                            ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  LearningAnswerChoiceState _choiceState(String choice, String? selected) {
    if (selected == null) {
      return _locked
          ? LearningAnswerChoiceState.disabled
          : LearningAnswerChoiceState.idle;
    }
    if (choice == widget.quiz.answer) return LearningAnswerChoiceState.correct;
    if (choice == selected) return LearningAnswerChoiceState.wrong;
    return LearningAnswerChoiceState.disabled;
  }
}
