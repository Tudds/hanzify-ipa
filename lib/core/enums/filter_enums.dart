// lib/core/enums/filter_enums.dart
// Enum types dùng cho VocabFilter — thay thế stringly-typed filters.

/// Trạng thái filter theo bookmark/mastered.
enum FilterStatus {
  all,        // Tất cả
  mastered,   // Đã thuộc lòng
  bookmarked, // Đã đánh dấu
}

/// Loại từ (part-of-speech).
enum FilterWordType {
  all,     // Tất cả
  noun,    // Danh từ (n)
  verb,    // Động từ (v)
  adjective, // Tính từ (adj)
  adverb,  // Trạng từ (adv)
  pronoun, // Đại từ (pron)
  preposition, // Giới từ (prep)
  conjunction, // Liên từ (conj)
  measure, // Lượng từ (m)
  other,   // Khác
}

/// Chuyển đổi FilterWordType sang POS tag string dùng trong vocab.
String? filterWordTypeToPos(FilterWordType type) {
  switch (type) {
    case FilterWordType.all:
      return null;
    case FilterWordType.noun:
      return 'n';
    case FilterWordType.verb:
      return 'v';
    case FilterWordType.adjective:
      return 'adj';
    case FilterWordType.adverb:
      return 'adv';
    case FilterWordType.pronoun:
      return 'pron';
    case FilterWordType.preposition:
      return 'prep';
    case FilterWordType.conjunction:
      return 'conj';
    case FilterWordType.measure:
      return 'm';
    case FilterWordType.other:
      return 'other';
  }
}

/// Chuyển đổi POS tag string sang FilterWordType.
FilterWordType posToFilterWordType(String pos) {
  switch (pos) {
    case 'n':
      return FilterWordType.noun;
    case 'v':
      return FilterWordType.verb;
    case 'adj':
      return FilterWordType.adjective;
    case 'adv':
      return FilterWordType.adverb;
    case 'pron':
      return FilterWordType.pronoun;
    case 'prep':
      return FilterWordType.preposition;
    case 'conj':
      return FilterWordType.conjunction;
    case 'm':
      return FilterWordType.measure;
    default:
      return FilterWordType.other;
  }
}

/// Danh mục ngữ pháp dùng cho Grammar Filter.
enum FilterGrammarCategory {
  all,              // Tất cả
  basic,            // Cấu trúc cơ bản
  particle,         // Trợ từ
  aspect,           // Thể động từ
  sentencePattern,  // Mẫu câu
  complement,       // Bổ ngữ
  conjunction,      // Liên từ
  comparison,       // So sánh
  timeExpression,   // Biểu đạt thời gian
}

/// Chuyển đổi FilterGrammarCategory sang category string dùng trong grammar data.
String? filterGrammarCategoryToString(FilterGrammarCategory cat) {
  switch (cat) {
    case FilterGrammarCategory.all:
      return null;
    case FilterGrammarCategory.basic:
      return 'basic';
    case FilterGrammarCategory.particle:
      return 'particle';
    case FilterGrammarCategory.aspect:
      return 'aspect';
    case FilterGrammarCategory.sentencePattern:
      return 'sentence_pattern';
    case FilterGrammarCategory.complement:
      return 'complement';
    case FilterGrammarCategory.conjunction:
      return 'conjunction';
    case FilterGrammarCategory.comparison:
      return 'comparison';
    case FilterGrammarCategory.timeExpression:
      return 'time_expression';
  }
}

/// Chuyển đổi category string sang FilterGrammarCategory.
FilterGrammarCategory stringToFilterGrammarCategory(String category) {
  switch (category) {
    case 'basic':
      return FilterGrammarCategory.basic;
    case 'particle':
      return FilterGrammarCategory.particle;
    case 'aspect':
      return FilterGrammarCategory.aspect;
    case 'sentence_pattern':
      return FilterGrammarCategory.sentencePattern;
    case 'complement':
      return FilterGrammarCategory.complement;
    case 'conjunction':
      return FilterGrammarCategory.conjunction;
    case 'comparison':
      return FilterGrammarCategory.comparison;
    case 'time_expression':
      return FilterGrammarCategory.timeExpression;
    default:
      return FilterGrammarCategory.basic;
  }
}

/// Nhãn hiển thị cho FilterGrammarCategory.
String grammarCategoryLabel(FilterGrammarCategory cat) {
  switch (cat) {
    case FilterGrammarCategory.all:
      return 'Tất cả';
    case FilterGrammarCategory.basic:
      return 'Cấu trúc cơ bản';
    case FilterGrammarCategory.particle:
      return 'Trợ từ';
    case FilterGrammarCategory.aspect:
      return 'Thể động từ';
    case FilterGrammarCategory.sentencePattern:
      return 'Mẫu câu';
    case FilterGrammarCategory.complement:
      return 'Bổ ngữ';
    case FilterGrammarCategory.conjunction:
      return 'Liên từ';
    case FilterGrammarCategory.comparison:
      return 'So sánh';
    case FilterGrammarCategory.timeExpression:
      return 'Thời gian';
  }
}

// ============================================================================
// Danh mục hội thoại dùng cho Conversation Filter
// ============================================================================

/// Danh mục hội thoại dùng cho Conversation Filter.
enum FilterConversationCategory {
  all('Tất cả', ''),
  greeting('Chào hỏi', 'greeting'),
  shopping('Mua sắm', 'shopping'),
  restaurant('Nhà hàng', 'restaurant'),
  transport('Di chuyển', 'transport'),
  daily('Hàng ngày', 'daily'),
  school('Học tập', 'school'),
  travel('Du lịch', 'travel'),
  phone('Điện thoại', 'phone'),
  workplace('Công sở', 'workplace');

  final String label;
  final String value;
  const FilterConversationCategory(this.label, this.value);
}

/// Chuyển đổi FilterConversationCategory sang category string.
String? filterConversationCategoryToString(FilterConversationCategory cat) {
  if (cat == FilterConversationCategory.all) return null;
  return cat.value;
}

/// Chuyển đổi category string sang FilterConversationCategory.
FilterConversationCategory stringToFilterConversationCategory(String category) {
  return FilterConversationCategory.values.firstWhere(
    (e) => e.value == category,
    orElse: () => FilterConversationCategory.all,
  );
}
