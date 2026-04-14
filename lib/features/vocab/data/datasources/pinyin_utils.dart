// ============================================================================
// Pinyin Normalisation — shared utility
// "nǐ hǎo" → "nihao"  |  "ni3hao3" → "nihao"
// ============================================================================
String normalizePinyin(String pinyin) {
  const toneMap = {
    'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a',
    'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
    'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
    'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
    'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
    'ǖ': 'v', 'ǘ': 'v', 'ǚ': 'v', 'ǜ': 'v', 'ü': 'v',
  };
  var result = pinyin.toLowerCase();
  toneMap.forEach((toned, plain) => result = result.replaceAll(toned, plain));
  return result.replaceAll(RegExp(r'[\s\d]'), '');
}
