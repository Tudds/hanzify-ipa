import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/performance_provider.dart';
import '../../../core/widgets/learning/learning_widgets.dart';
import '../domain/review_challenge.dart';

class ReviewSessionPanel extends ConsumerStatefulWidget {
  const ReviewSessionPanel({
    super.key,
    required this.challenge,
    this.duration = const Duration(seconds: 30),
    this.onAnswer,
    this.onChoice,
    this.onTimeout,
  });

  final ReviewChallenge challenge;
  final Duration duration;
  final ValueChanged<bool>? onAnswer;
  final ValueChanged<String>? onChoice;
  final VoidCallback? onTimeout;

  @override
  ConsumerState<ReviewSessionPanel> createState() => _ReviewSessionPanelState();
}

class _ReviewSessionPanelState extends ConsumerState<ReviewSessionPanel> {
  Timer? _timer;
  late int _remainingSeconds;
  var _locked = false;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void didUpdateWidget(covariant ReviewSessionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge != widget.challenge) {
      _locked = false;
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    _remainingSeconds = widget.duration.inSeconds;
    if (_remainingSeconds <= 0) return;
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
    final isCorrect = choice == widget.challenge.answer;
    await _showFeedback(choice: choice, isCorrect: isCorrect, timedOut: false);
    if (!mounted) return;
    widget.onChoice?.call(choice);
    widget.onAnswer?.call(isCorrect);
  }

  Future<void> _handleTimeout() async {
    if (_locked) return;
    setState(() {
      _locked = true;
      _remainingSeconds = 0;
    });
    await _showFeedback(choice: null, isCorrect: false, timedOut: true);
    if (!mounted) return;
    widget.onTimeout?.call();
    widget.onAnswer?.call(false);
  }

  Future<void> _showFeedback({
    required String? choice,
    required bool isCorrect,
    required bool timedOut,
  }) {
    return showLearningQuizFeedbackDialog(
      context: context,
      prompt: widget.challenge.prompt,
      promptPinyin: widget.challenge.promptPinyin,
      answer: widget.challenge.answer,
      selectedAnswer: choice,
      isCorrect: isCorrect,
      timedOut: timedOut,
      meaning: widget.challenge.promptMeaning,
      performance: readPerformance(ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final performance = readPerformance(ref);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: colors.surface.withValues(alpha: 0.92),
      child:
          Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LearningCountdownProgress(
                      seconds: _remainingSeconds,
                      totalSeconds: widget.duration.inSeconds,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 22),
                    LearningQuizPrompt(
                      prompt: widget.challenge.prompt,
                      promptPinyin: widget.challenge.promptPinyin,
                      audioUrl: widget.challenge.audioUrl,
                      quizType: widget.challenge.quizType,
                      animate: !performance,
                    ),
                    const SizedBox(height: 22),
                    for (final choice in widget.challenge.choices) ...[
                      LearningAnswerChoiceButton(
                        choice: choice,
                        state: _locked
                            ? LearningAnswerChoiceState.disabled
                            : LearningAnswerChoiceState.idle,
                        onPressed: _locked ? null : () => _handleChoice(choice),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              )
              .animate(autoPlay: !performance)
              .fadeIn(duration: 180.ms)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: 220.ms,
                curve: Curves.easeOutCubic,
              ),
    );
  }
}
