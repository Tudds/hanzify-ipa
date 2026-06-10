import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/performance_provider.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/hanzify_haptic.dart';
import '../../../dictionary/domain/vocab_item.dart';
import '../../application/quiz_pool.dart';
import '../widgets/drill_scaffold.dart';

class WordMatchDrillScreen extends ConsumerStatefulWidget {
  const WordMatchDrillScreen({super.key, required this.level});

  final int level;

  @override
  ConsumerState<WordMatchDrillScreen> createState() =>
      _WordMatchDrillScreenState();
}

class _WordMatchDrillScreenState extends ConsumerState<WordMatchDrillScreen> {
  static const int _pairsPerRound = 6;

  List<VocabItem>? _round;
  List<String>? _shuffledVi;
  final Map<String, String> _matched = {};
  String? _selectedHanzi;
  String? _wrongHanzi;
  String? _wrongVi;
  int _score = 0;
  int _totalPairs = 0;
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    final asyncPool = ref.watch(quizPoolProvider);
    return asyncPool.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Lỗi: $e'))),
      data: (pool) {
        if (_round == null) {
          final round = pool
              .sample(level: widget.level, count: _pairsPerRound)
              .vocab;
          _round = round;
          _totalPairs = round.length;
          _shuffledVi = round.map((v) => v.viShort).toList()..shuffle();
        }
        final round = _round!;
        if (round.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Nối từ')),
            body: const Center(child: Text('Không đủ từ vựng để luyện.')),
          );
        }
        if (_finished) {
          return Scaffold(
            body: DrillSummary(
              score: _score,
              total: _totalPairs,
              onRestart: () {
                setState(() {
                  final next = pool
                      .sample(level: widget.level, count: _pairsPerRound)
                      .vocab;
                  _round = next;
                  _totalPairs = next.length;
                  _shuffledVi = next.map((v) => v.viShort).toList()..shuffle();
                  _matched.clear();
                  _selectedHanzi = null;
                  _wrongHanzi = null;
                  _wrongVi = null;
                  _score = 0;
                  _finished = false;
                });
              },
            ),
          );
        }
        return DrillScaffold(
          title: 'Nối từ',
          progress: _matched.length / _totalPairs,
          score: _score,
          body: _buildBoard(round),
        );
      },
    );
  }

  Widget _buildBoard(List<VocabItem> round) {
    final shuffledVi = _shuffledVi!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Row(
        children: [
          Expanded(
            child: _Column(
              items: [for (final v in round) v.hanzi],
              selectedKey: _selectedHanzi,
              wrongKey: _wrongHanzi,
              isHanzi: true,
              matched: _matched.keys.toSet(),
              onTap: _onPickHanzi,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Column(
              items: shuffledVi,
              selectedKey: null,
              wrongKey: _wrongVi,
              isHanzi: false,
              matched: _matched.values.toSet(),
              onTap: _onPickVi,
            ),
          ),
        ],
      ),
    );
  }

  void _onPickHanzi(String hanzi) {
    if (_matched.containsKey(hanzi)) return;
    HanzifyHaptic.selection();
    setState(() {
      _selectedHanzi = hanzi;
      _wrongHanzi = null;
      _wrongVi = null;
    });
  }

  void _onPickVi(String vi) {
    final round = _round!;
    final selected = _selectedHanzi;
    if (selected == null) return;
    if (_matched.values.contains(vi)) return;
    final correctPair = round.firstWhere(
      (v) => v.hanzi == selected,
      orElse: () => round.first,
    );
    if (correctPair.viShort == vi) {
      HanzifyHaptic.success();
      setState(() {
        _matched[selected] = vi;
        _score++;
        _selectedHanzi = null;
        if (_matched.length == _totalPairs) {
          _finished = true;
        }
      });
    } else {
      HanzifyHaptic.error();
      setState(() {
        _wrongHanzi = selected;
        _wrongVi = vi;
      });
      Future.delayed(const Duration(milliseconds: 380), () {
        if (!mounted) return;
        setState(() {
          _wrongHanzi = null;
          _wrongVi = null;
          _selectedHanzi = null;
        });
      });
    }
  }
}

class _Column extends ConsumerWidget {
  const _Column({
    required this.items,
    required this.selectedKey,
    required this.wrongKey,
    required this.isHanzi,
    required this.matched,
    required this.onTap,
  });

  final List<String> items;
  final String? selectedKey;
  final String? wrongKey;
  final bool isHanzi;
  final Set<String> matched;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performance = readPerformance(ref);
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _Tile(
                key: ValueKey('${isHanzi ? 'h' : 'v'}$i'),
                text: items[i],
                isHanzi: isHanzi,
                isSelected: items[i] == selectedKey,
                isMatched: matched.contains(items[i]),
                isWrong: items[i] == wrongKey,
                performance: performance,
                onTap: () => onTap(items[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.text,
    required this.isHanzi,
    required this.isSelected,
    required this.isMatched,
    required this.isWrong,
    required this.performance,
    required this.onTap,
  });

  final String text;
  final bool isHanzi;
  final bool isSelected;
  final bool isMatched;
  final bool isWrong;
  final bool performance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Color bg;
    Color border;
    Color fg;
    if (isMatched) {
      bg = colors.primary.withValues(alpha: 0.15);
      border = colors.primary;
      fg = colors.primary;
    } else if (isWrong) {
      bg = colors.errorContainer;
      border = colors.error;
      fg = colors.onErrorContainer;
    } else if (isSelected) {
      bg = colors.tertiaryContainer;
      border = colors.tertiary;
      fg = colors.onTertiaryContainer;
    } else {
      bg = colors.surfaceContainerHigh;
      border = colors.outlineVariant.withValues(alpha: 0.5);
      fg = colors.onSurface;
    }

    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Opacity(
        opacity: isMatched ? 0.55 : 1,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: isHanzi
              ? AppTypography.hanziDisplay(size: 22, color: fg)
              : TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
        ),
      ),
    );

    return Animate(
      target: isWrong ? 1 : 0,
      effects: performance
          ? const []
          : [ShakeEffect(duration: 320.ms, hz: 8, offset: const Offset(4, 0))],
      child: InkWell(
        onTap: isMatched ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: tile,
      ),
    );
  }
}
