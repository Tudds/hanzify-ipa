import 'dart:ui' as ui;

class CharacterStrokes {
  const CharacterStrokes({required this.char, required this.strokes});

  final String char;
  final List<ui.Path> strokes;
}
