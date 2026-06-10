import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/character_strokes.dart';
import '../domain/svg_path_parser.dart';

class CharacterRepository {
  CharacterRepository({AssetBundle? bundle}) : _bundle = bundle;

  static const _assets = [
    'assets/data/char_hsk1.json',
    'assets/data/char_hsk2.json',
    'assets/data/char_hsk3.json',
    'assets/data/char_hsk4.json',
  ];
  static const _parser = SvgPathParser();

  final AssetBundle? _bundle;
  final Map<String, CharacterStrokes> _cache = {};
  bool _loaded = false;
  Future<void>? _loading;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loading ??= _doLoad();
    await _loading;
  }

  Future<void> _doLoad() async {
    final bundle = _bundle ?? rootBundle;
    for (final path in _assets) {
      try {
        final raw = await bundle.loadString(path);
        final list = (jsonDecode(raw) as List<dynamic>)
            .cast<Map<String, dynamic>>();
        for (final entry in list) {
          final char = entry['char'] as String?;
          final strokes = (entry['strokes'] as List<dynamic>?)
              ?.cast<String>();
          if (char == null || strokes == null) continue;
          _cache[char] = CharacterStrokes(
            char: char,
            strokes: strokes.map(_parser.parse).toList(growable: false),
          );
        }
      } catch (_) {
        // Asset may be missing for some HSK level; continue.
      }
    }
    _loaded = true;
  }

  Future<CharacterStrokes?> load(String char) async {
    await _ensureLoaded();
    return _cache[char];
  }

  Future<List<CharacterStrokes?>> loadAll(String word) async {
    await _ensureLoaded();
    return word.runes.map((r) {
      final s = String.fromCharCode(r);
      return _cache[s];
    }).toList(growable: false);
  }
}

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository();
});
