import 'package:equatable/equatable.dart';

/// Domain entity cho một chữ Hán đơn lẻ.
/// Dữ liệu stroke là SVG path string theo viewport 0–1000.
class Character extends Equatable {
  final String char;
  final List<String> strokes; // danh sách SVG path (M … Q … Z)
  final int? hskLevel;
  final String? radical;
  final int strokeCount;
  final String? pinyin;
  final String? definition;
  final String? definitionVi;

  const Character({
    required this.char,
    required this.strokes,
    this.hskLevel,
    this.radical,
    required this.strokeCount,
    this.pinyin,
    this.definition,
    this.definitionVi,
  });

  @override
  List<Object?> get props => [
        char,
        strokes,
        hskLevel,
        radical,
        strokeCount,
        pinyin,
        definition,
        definitionVi,
      ];

  /// Tạo Character từ CharacterDbModel (Drift)
  factory Character.fromDbModel(dynamic model) => Character(
        char: model.char as String,
        strokes: List<String>.from(model.strokes as List),
        hskLevel: model.hskLevel as int?,
        radical: model.radical as String?,
        strokeCount: model.strokeCount as int? ?? (model.strokes as List).length,
        pinyin: model.pinyin as String?,
        definition: model.definition as String?,
        definitionVi: model.definitionVi as String?,
      );
}
