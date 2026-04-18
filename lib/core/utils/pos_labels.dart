// ============================================================================
// POS (Part-of-Speech) labels — centralized map for Vietnamese display.
// Used by VocabCard, VocabListScreen, and any widget that shows POS tags.
// ============================================================================

/// Full POS label with both Vietnamese and Chinese: 'Động từ (动词)'
String posLabelFull(String pos) => _posLabelFullMap[pos] ?? pos;

/// Short POS label (Vietnamese only): 'Động từ'
String posLabelShort(String pos) => _posLabelShortMap[pos] ?? pos;

const _posLabelShortMap = <String, String>{
  'v': 'Động từ',
  'n': 'Danh từ',
  'adj': 'Tính từ',
  'adv': 'Trạng từ',
  'prep': 'Giới từ',
  'conj': 'Liên từ',
  'pron': 'Đại từ',
  'num': 'Số từ',
  'mw': 'Lượng từ',
  'aux': 'Trợ từ',
  'interj': 'Thán từ',
  'other': 'Khác',
};

const _posLabelFullMap = <String, String>{
  'v': 'Động từ (动词)',
  'n': 'Danh từ (名词)',
  'adj': 'Tính từ (形容词)',
  'adv': 'Trạng từ (副词)',
  'prep': 'Giới từ (介词)',
  'conj': 'Liên từ (连词)',
  'pron': 'Đại từ (代词)',
  'num': 'Số từ (数词)',
  'mw': 'Lượng từ (量词)',
  'aux': 'Trợ từ (助词)',
  'interj': 'Thán từ (叹词)',
  'other': 'Khác (其他)',
};
