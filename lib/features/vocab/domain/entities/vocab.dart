import 'package:equatable/equatable.dart';

// ============================================================================
// Meaning — một nghĩa kèm từ loại
// ============================================================================
class Meaning extends Equatable {
  final String pos; // "v" | "n" | "adj" | "adv" | "prep" | "conj" | ...
  final String vi;  // Nghĩa tiếng Việt
  final String en;  // Nghĩa tiếng Anh (tuỳ chọn, để trống nếu chưa có)

  const Meaning({
    required this.pos,
    required this.vi,
    this.en = '',
  });

  @override
  List<Object?> get props => [pos, vi, en];

  Meaning copyWith({String? pos, String? vi, String? en}) =>
      Meaning(pos: pos ?? this.pos, vi: vi ?? this.vi, en: en ?? this.en);

  Map<String, dynamic> toJson() => {'pos': pos, 'vi': vi, 'en': en};

  factory Meaning.fromJson(Map<String, dynamic> json) => Meaning(
        pos: json['pos'] as String? ?? 'other',
        vi: json['vi'] as String? ?? '',
        en: json['en'] as String? ?? '',
      );
}

// ============================================================================
// ExampleSentence — một câu ví dụ song ngữ
// ============================================================================
class ExampleSentence extends Equatable {
  final String cn;     // Câu tiếng Trung
  final String pinyin; // Phiên âm có dấu
  final String vi;     // Dịch tiếng Việt

  const ExampleSentence({
    required this.cn,
    required this.pinyin,
    required this.vi,
  });

  @override
  List<Object?> get props => [cn, pinyin, vi];

  Map<String, dynamic> toJson() => {'cn': cn, 'pinyin': pinyin, 'vi': vi};

  factory ExampleSentence.fromJson(Map<String, dynamic> json) =>
      ExampleSentence(
        cn: json['cn'] as String? ?? '',
        pinyin: json['pinyin'] as String? ?? '',
        vi: json['vi'] as String? ?? '',
      );
}

// ============================================================================
// Vocab — domain entity chính
// ============================================================================
class Vocab extends Equatable {
  final String id;
  final String hanzi;
  final String pinyin;

  /// Pinyin không dấu/không khoảng trắng: "nǐ hǎo" → "nihao"
  final String pinyinNormalized;

  /// Các chữ đơn tạo thành từ: "你好" → ["你", "好"]
  final List<String> characters;

  /// Danh sách nghĩa + từ loại (thay thế String meaning cũ)
  final List<Meaning> meanings;

  /// Chuỗi nghĩa phẳng (dùng cho hiển thị nhanh, derive từ meanings)
  final String meaning;

  /// Câu ví dụ có cấu trúc
  final List<ExampleSentence> exampleSentences;

  final int level;
  final String wordType;
  final bool isBookmarked;
  final bool isMastered;

  // SRS fields
  final int repetitions;
  final double easeFactor;
  final int interval;
  final DateTime nextReview;

  const Vocab({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    this.pinyinNormalized = '',
    this.characters = const [],
    this.meanings = const [],
    this.meaning = '',
    this.exampleSentences = const [],
    required this.level,
    this.wordType = 'other',
    this.isBookmarked = false,
    this.isMastered = false,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    required this.nextReview,
  });

  @override
  List<Object?> get props => [
    id, hanzi, pinyin, pinyinNormalized, characters,
    meanings, meaning, exampleSentences, level, wordType,
    isBookmarked, isMastered, repetitions, easeFactor, interval, nextReview,
  ];

  Vocab copyWith({
    int? repetitions,
    double? easeFactor,
    int? interval,
    DateTime? nextReview,
    bool? isBookmarked,
    bool? isMastered,
    List<Meaning>? meanings,
    String? meaning,
    List<ExampleSentence>? exampleSentences,
    List<String>? characters,
    String? pinyinNormalized,
  }) {
    return Vocab(
      id: id,
      hanzi: hanzi,
      pinyin: pinyin,
      pinyinNormalized: pinyinNormalized ?? this.pinyinNormalized,
      characters: characters ?? this.characters,
      meanings: meanings ?? this.meanings,
      meaning: meaning ?? this.meaning,
      exampleSentences: exampleSentences ?? this.exampleSentences,
      level: level,
      wordType: wordType,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isMastered: isMastered ?? this.isMastered,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReview: nextReview ?? this.nextReview,
    );
  }
}
