import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/theme/colors.dart';
import 'package:hanzify/core/theme/theme_state.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';

enum QuizMode { hanziToMeaning, meaningToHanzi }

extension QuizModeExt on QuizMode {
  String get label =>
      this == QuizMode.hanziToMeaning ? 'Hanzi → Nghĩa' : 'Nghĩa → Hanzi';
  String get emoji => this == QuizMode.hanziToMeaning ? '🀄' : '🇻🇳';
}

class QuizQuestion {
  final Vocab vocab;
  final List<String> options;
  final int correctIndex;
  final QuizMode mode;
  const QuizQuestion(
      {required this.vocab,
      required this.options,
      required this.correctIndex,
      required this.mode});
}

const _totalQuestions = 10;

List<T> _shuffle<T>(List<T> list) {
  final a = List<T>.from(list);
  final r = Random();
  for (int i = a.length - 1; i > 0; i--) {
    final j = r.nextInt(i + 1);
    final tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
  }
  return a;
}

List<QuizQuestion> _generateQuestions(
    List<Vocab> all, QuizMode mode) {
  if (all.length < 4) return [];
  final selected = _shuffle(all).take(_totalQuestions).toList();
  return selected.map((vocab) {
    final others =
        _shuffle(all.where((v) => v.id != vocab.id).toList()).take(3).toList();

    // Dùng meanings có cấu trúc nếu có, fallback sang flat meaning
    String getMeaning(Vocab v) {
      if (v.meanings.isNotEmpty) {
        return v.meanings.map((m) => m.vi).join(', ');
      }
      return v.meaning;
    }

    final String correct;
    final List<String> wrong;
    if (mode == QuizMode.hanziToMeaning) {
      correct = getMeaning(vocab);
      wrong = others.map(getMeaning).toList();
    } else {
      correct = vocab.hanzi;
      wrong = others.map((o) => o.hanzi).toList();
    }
    final allOpts = _shuffle([correct, ...wrong]);
    return QuizQuestion(
        vocab: vocab,
        options: allOpts,
        correctIndex: allOpts.indexOf(correct),
        mode: mode);
  }).toList();
}

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  QuizMode? _mode;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedAnswer;
  int _score = 0;
  bool _isFinished = false;
  int _streak = 0;
  bool? _answerFeedback; // null = none, true = correct, false = incorrect
  bool _showPinyin = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200), value: 1);
    _fadeAnim = _fadeCtrl.view;
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _shakeCtrl.dispose();
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _startQuiz(QuizMode mode) {
    final vocabState = ref.read(allVocabProvider);
    if (vocabState is! AsyncData<List<Vocab>>) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Vui lòng đợi tải dữ liệu từ vựng...'))
       );
       return;
    }
    final allVocab = vocabState.value;
    if (allVocab.length < 4) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Cần ít nhất 4 từ vựng để bắt đầu Quiz'))
       );
       return;
    }
    final qs = _generateQuestions(allVocab, mode);
    if (qs.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Không thể tạo câu hỏi Quiz từ dữ liệu hiện tại.'))
       );
       return;
    }
    setState(() {
      _mode = mode;
      _questions = qs;
      _currentIndex = 0;
      _selectedAnswer = null;
      _score = 0;
      _streak = 0;
      _isFinished = false;
    });
  }

  void _handleAnswer(int index) {
    if (_selectedAnswer != null) return;
    setState(() => _selectedAnswer = index);
    final isCorrect = index == _questions[_currentIndex].correctIndex;
    
    setState(() {
      _answerFeedback = isCorrect;
      if (isCorrect) {
        _score++;
        _streak++;
      } else {
        _streak = 0;
      }
    });

    if (!isCorrect) {
      _shakeCtrl.forward().then((_) => _shakeCtrl.reset());
    }

    _advanceTimer = Timer(const Duration(milliseconds: 1400), () async {
      if (mounted) setState(() => _answerFeedback = null);
      if (_currentIndex + 1 >= _questions.length) {
        if (mounted) setState(() => _isFinished = true);
        return;
      }
      await _fadeCtrl.animateTo(0);
      if (mounted) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
        });
      }
      await _fadeCtrl.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Actively watch to pre-load and keep ready
    ref.watch(allVocabProvider);
    final c = ref.watch(themeColorsProvider);

    if (_mode == null) return _buildModeSelect(c);
    if (_isFinished) return _buildResults(c);
    if (_questions.isEmpty) return _buildModeSelect(c);
    
    return Stack(
      children: [
        _buildQuiz(c),
        _buildFeedbackOverlay(c),
      ],
    );
  }

  Widget _buildFeedbackOverlay(AppThemeColors c) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation.drive(CurveTween(curve: Curves.elasticOut)),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _answerFeedback == null
              ? const SizedBox.shrink(key: ValueKey('none'))
              : Center(
                  key: ValueKey(_answerFeedback),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: (_answerFeedback! ? c.success : c.danger).withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_answerFeedback! ? c.success : c.danger).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _answerFeedback! ? '✓' : '✗',
                        style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildModeSelect(AppThemeColors c) {
    return Scaffold(
      backgroundColor: c.background,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).navigate('home'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('← Về',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.primary)),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'quiz_hero',
                  child: Material(
                    color: Colors.transparent,
                    child: const Center(child: Text('🧠', style: TextStyle(fontSize: 48))),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Chọn Chế Độ',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: c.text)),
                const SizedBox(height: 6),
                Text('Chọn kiểu câu hỏi bạn muốn luyện',
                    style: TextStyle(fontSize: 15, color: c.placeholder)),
                const SizedBox(height: 32),
                ...QuizMode.values.map((m) => _buildModeCard(m, c)),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildModeCard(QuizMode m, AppThemeColors c) {
    return GestureDetector(
      onTap: () => _startQuiz(m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.disabled.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
                child: Text(m.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.label,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: c.text)),
                const SizedBox(height: 3),
                Text('$_totalQuestions câu hỏi trắc nghiệm',
                    style: TextStyle(fontSize: 13, color: c.placeholder)),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_rounded,
                size: 18, color: c.primary),
          ),
        ]),
      ),
    );
  }

  Widget _buildResults(AppThemeColors c) {
    final pct = (_score / _questions.length * 100).round();
    final emoji = pct >= 80
        ? '🌟'
        : pct >= 60
            ? '👍'
            : '💪';
    final text = pct >= 80
        ? 'Xuất sắc!'
        : pct >= 60
            ? 'Khá tốt!'
            : 'Cần luyện thêm!';
    final barColor = pct >= 80
        ? c.success
        : pct >= 60
            ? c.warning
            : c.danger;
    
    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    barColor.withValues(alpha: 0.2),
                    barColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 56))),
            ),
            const SizedBox(height: 20),
            Text(text,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: c.text)),
            const SizedBox(height: 8),
            Text('$_score / ${_questions.length}',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: barColor)),
            const SizedBox(height: 4),
            Text('$pct% chính xác',
                style: TextStyle(fontSize: 16, color: c.placeholder)),
            const SizedBox(height: 24),
            _buildAnimatedProgressBar(c, barColor, c.accent, pct / 100),
            const SizedBox(height: 36),
            _gradientBtn('🔄 Làm lại', c, () => _startQuiz(_mode!)),
            const SizedBox(height: 10),
            _outlineBtn('🔀 Đổi chế độ', c, () => setState(() => _mode = null)),
            const SizedBox(height: 10),
            _outlineBtn('← Về Trang Chủ', c, () => ref.read(navigationProvider.notifier).navigate('home')),
          ]),
        ),
      ),
    );
  }

  Widget _gradientBtn(String label, AppThemeColors c, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c.primary, c.accent]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: c.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _outlineBtn(String label, AppThemeColors c, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            border: Border.all(color: c.disabled.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(14)),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: c.text)),
      ),
    );
  }

  Widget _buildQuiz(AppThemeColors c) {
    final q = _questions[_currentIndex];
    final isLarge = q.mode == QuizMode.hanziToMeaning;
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: c.background,
      body: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            GestureDetector(
              onTap: () => ref.read(navigationProvider.notifier).navigate('home'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('← Thoát',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.primary)),
              ),
            ),
            Expanded(
              child: Text('${q.mode.emoji} ${q.mode.label}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.placeholder)),
            ),
            _buildStreakBadge(c),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildAnimatedProgressBar(c, c.primary, c.accent, progress),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Câu ${_currentIndex + 1} / ${_questions.length}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: c.placeholder)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(children: [
                // Question card
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(sin(_shakeAnim.value * pi * 4) * 8, 0),
                    child: child,
                  ),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.surface, c.surfaceLow],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: c.disabled.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(children: [
                      Text(
                        q.mode == QuizMode.hanziToMeaning
                            ? q.vocab.hanzi
                            : (q.vocab.meanings.isNotEmpty
                                ? q.vocab.meanings.map((m) => m.vi).join(' / ')
                                : q.vocab.meaning),
                        style: TextStyle(
                            fontSize: isLarge ? 56 : 22,
                            fontWeight: FontWeight.w800,
                            color: c.text),
                        textAlign: TextAlign.center,
                      ),
                      if (q.mode == QuizMode.hanziToMeaning) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showPinyin ? q.vocab.pinyin : '• • •',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: _showPinyin
                                      ? c.primary
                                      : c.disabled),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => setState(
                                  () => _showPinyin = !_showPinyin),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: c.disabled.withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                child: Text(
                                    _showPinyin ? '🙈 Ẩn' : '👁 Hiện',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: c.placeholder)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ]),
                  ),
                ),
                // Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: List.generate(q.options.length, (idx) {
                      final isSelected = _selectedAnswer == idx;
                      final isCorrect = idx == q.correctIndex;
                      final showResult = _selectedAnswer != null;

                      Color bgColor = c.surface;
                      Color borderColor = c.disabled.withValues(alpha: 0.3);
                      Color textColor = c.text;
                      IconData? trailingIcon;
                      Color? trailingColor;

                      if (showResult) {
                        if (isCorrect) {
                          bgColor = c.success.withValues(alpha: 0.1);
                          borderColor = c.success;
                          textColor = c.success;
                          trailingIcon = Icons.check_circle_rounded;
                          trailingColor = c.success;
                        } else if (isSelected) {
                          bgColor = c.danger.withValues(alpha: 0.1);
                          borderColor = c.danger;
                          textColor = c.danger;
                          trailingIcon = Icons.cancel_rounded;
                          trailingColor = c.danger;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () => _handleAnswer(idx),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: bgColor,
                                border: Border.all(
                                    color: borderColor, width: 1.5),
                                borderRadius: BorderRadius.circular(16)),
                            child: Row(children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: c.disabled.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + idx),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: c.placeholder),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(q.options[idx],
                                    style: TextStyle(
                                        fontSize:
                                            q.mode ==
                                                    QuizMode.meaningToHanzi
                                                ? 28
                                                : 16,
                                        fontWeight: FontWeight.w500,
                                        color: textColor)),
                              ),
                              if (trailingIcon != null)
                                Icon(trailingIcon,
                                    size: 22, color: trailingColor),
                            ]),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (_selectedAnswer != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: c.surfaceLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: c.disabled.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      Text(q.vocab.hanzi,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: c.text)),
                      const SizedBox(height: 2),
                      Text(q.vocab.pinyin,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: c.primary)),
                      const SizedBox(height: 4),
                      // Dùng meanings có cấu trúc nếu có
                      if (q.vocab.meanings.isNotEmpty)
                        Text(
                          q.vocab.meanings.map((m) => m.vi).join(' / '),
                          style: TextStyle(
                              fontSize: 15, color: c.placeholder),
                          textAlign: TextAlign.center,
                        )
                      else
                        Text(q.vocab.meaning,
                            style: TextStyle(
                                fontSize: 15, color: c.placeholder)),
                      // Câu ví dụ đầu tiên nếu có
                      if (q.vocab.exampleSentences.isNotEmpty &&
                          q.vocab.exampleSentences.first.cn.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: c.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.vocab.exampleSentences.first.cn,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: c.text,
                                    fontWeight: FontWeight.w500),
                              ),
                              if (q.vocab.exampleSentences.first.vi
                                  .isNotEmpty)
                                Text(
                                  q.vocab.exampleSentences.first.vi,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: c.placeholder,
                                      fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ]),
                  ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAnimatedProgressBar(AppThemeColors c, Color startColor, Color endColor, double progress) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: progress),
      builder: (context, value, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final progressWidth = width * value;

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: c.disabled.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    width: progressWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [startColor, endColor],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: startColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  if (value > 0.05)
                    Positioned(
                      left: progressWidth - 10,
                      top: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: endColor.withValues(alpha: 0.8),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: endColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStreakBadge(AppThemeColors c) {
    if (_streak < 2) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.surfaceLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text('Streak: $_streak',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.accent)),
      ]),
    );
  }
}


