import 'package:flutter/material.dart';

class HanzifyHighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle baseStyle;
  final Color? highlightColor;

  const HanzifyHighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    required this.baseStyle,
    this.highlightColor,
    @Deprecated('Use highlightColor or theme instead') dynamic colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = highlightColor ?? cs.primary;

    if (highlight.isEmpty || !text.contains(highlight)) {
      return Text(text, style: baseStyle);
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = text.indexOf(highlight, start)) != -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }
      spans.add(
        TextSpan(
          text: highlight,
          style: baseStyle.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
      start = indexOfHighlight + highlight.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      TextSpan(children: spans, style: baseStyle),
    );
  }
}
