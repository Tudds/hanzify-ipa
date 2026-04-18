import 'package:flutter/material.dart';
import 'package:hanzify/core/theme/colors.dart';

class HanzifyHighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle baseStyle;
  final AppThemeColors colors;

  const HanzifyHighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    required this.baseStyle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty || !text.contains(highlight)) {
      return Text(text, style: baseStyle);
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = text.indexOf(highlight, start)) != -1) {
      // Normal part before highlight
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }
      // Highlighted part
      spans.add(
        TextSpan(
          text: highlight,
          style: baseStyle.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
      start = indexOfHighlight + highlight.length;
    }

    // Remaining part after last highlight
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      TextSpan(children: spans, style: baseStyle),
    );
  }
}
