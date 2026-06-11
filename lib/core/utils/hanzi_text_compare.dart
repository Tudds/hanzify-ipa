/// So sánh câu trả lời chữ Hán gõ tay với đáp án.
///
/// Pure Dart (không import Flutter) để test nhanh và tái dùng được ngoài UI.
library;

/// Dấu câu CJK + ASCII bị bỏ qua khi chấm. Các ký tự full-width trong dải
/// U+FF01–U+FF5E (！？，：；（）...) đã được map về half-width trước khi strip
/// nên chỉ cần liệt kê phần còn lại.
const _ignoredPunctuation = {
  // CJK
  '。', '、', '…', '·', '—', '～', '‘', '’', '“', '”',
  '「', '」', '『', '』', '《', '》', '【', '】',
  // ASCII (sau khi đã map full-width -> half-width)
  ',', '.', '!', '?', ';', ':', "'", '"', '(', ')', '-', '~',
};

/// Chuẩn hóa câu trả lời: bỏ mọi whitespace (kể cả U+3000), map ký tự
/// full-width về half-width, bỏ dấu câu.
String normalizeHanziAnswer(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    var code = rune;
    if (code >= 0xFF01 && code <= 0xFF5E) {
      code -= 0xFEE0; // full-width ASCII -> half-width
    }
    final char = String.fromCharCode(code);
    if (char.trim().isEmpty) continue; // whitespace, gồm cả U+3000
    if (_ignoredPunctuation.contains(char)) continue;
    buffer.write(char);
  }
  return buffer.toString();
}

enum HanziDiffKind {
  /// Ký tự đúng vị trí so với đáp án.
  match,

  /// Ký tự user gõ thay cho một ký tự khác trong đáp án.
  wrong,

  /// Ký tự có trong đáp án nhưng user bỏ sót.
  missing,

  /// Ký tự thừa user gõ thêm.
  extra,
}

class HanziDiffSegment {
  const HanziDiffSegment(this.text, this.kind);

  final String text;
  final HanziDiffKind kind;

  @override
  bool operator ==(Object other) {
    return other is HanziDiffSegment &&
        other.text == text &&
        other.kind == kind;
  }

  @override
  int get hashCode => Object.hash(text, kind);

  @override
  String toString() => 'HanziDiffSegment(${kind.name}, "$text")';
}

/// Đối chiếu [actual] (câu user gõ) với [expected] (đáp án) bằng LCS trên
/// code point. Caller tự chuẩn hóa hai chuỗi bằng [normalizeHanziAnswer]
/// trước khi gọi. Câu luyện ngắn (≤ ~20 ký tự) nên O(n·m) là đủ.
List<HanziDiffSegment> diffHanzi(String expected, String actual) {
  final e = expected.runes.map(String.fromCharCode).toList(growable: false);
  final a = actual.runes.map(String.fromCharCode).toList(growable: false);

  // Bảng LCS.
  final lcs = List.generate(e.length + 1, (_) => List.filled(a.length + 1, 0));
  for (var i = e.length - 1; i >= 0; i--) {
    for (var j = a.length - 1; j >= 0; j--) {
      lcs[i][j] = e[i] == a[j]
          ? lcs[i + 1][j + 1] + 1
          : (lcs[i + 1][j] > lcs[i][j + 1] ? lcs[i + 1][j] : lcs[i][j + 1]);
    }
  }

  // Backtrack thành chuỗi thao tác theo từng ký tự.
  final ops = <HanziDiffSegment>[];
  var i = 0, j = 0;
  while (i < e.length && j < a.length) {
    if (e[i] == a[j]) {
      ops.add(HanziDiffSegment(a[j], HanziDiffKind.match));
      i++;
      j++;
    } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
      ops.add(HanziDiffSegment(e[i], HanziDiffKind.missing));
      i++;
    } else {
      ops.add(HanziDiffSegment(a[j], HanziDiffKind.extra));
      j++;
    }
  }
  while (i < e.length) {
    ops.add(HanziDiffSegment(e[i++], HanziDiffKind.missing));
  }
  while (j < a.length) {
    ops.add(HanziDiffSegment(a[j++], HanziDiffKind.extra));
  }

  // Ghép cặp missing+extra liền kề thành "wrong" (gõ nhầm ký tự) để hiển thị
  // tự nhiên hơn, rồi gộp các ký tự cùng loại liên tiếp thành một segment.
  final paired = <HanziDiffSegment>[];
  for (var k = 0; k < ops.length; k++) {
    final current = ops[k];
    final next = k + 1 < ops.length ? ops[k + 1] : null;
    final isSubstitution =
        next != null &&
        ((current.kind == HanziDiffKind.missing &&
                next.kind == HanziDiffKind.extra) ||
            (current.kind == HanziDiffKind.extra &&
                next.kind == HanziDiffKind.missing));
    if (isSubstitution) {
      final typed = current.kind == HanziDiffKind.extra ? current : next;
      paired.add(HanziDiffSegment(typed.text, HanziDiffKind.wrong));
      k++;
    } else {
      paired.add(current);
    }
  }

  final merged = <HanziDiffSegment>[];
  for (final segment in paired) {
    if (merged.isNotEmpty && merged.last.kind == segment.kind) {
      merged[merged.length - 1] = HanziDiffSegment(
        merged.last.text + segment.text,
        segment.kind,
      );
    } else {
      merged.add(segment);
    }
  }
  return merged;
}
