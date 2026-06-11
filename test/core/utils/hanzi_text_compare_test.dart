import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/utils/hanzi_text_compare.dart';

void main() {
  group('normalizeHanziAnswer', () {
    test('strips whitespace including ideographic space U+3000', () {
      expect(normalizeHanziAnswer(' 我 喝　茶 '), '我喝茶');
    });

    test('strips CJK and ASCII punctuation', () {
      expect(normalizeHanziAnswer('我喝茶。'), '我喝茶');
      expect(normalizeHanziAnswer('你好，世界！'), '你好世界');
      expect(normalizeHanziAnswer('“引用”、《书》…'), '引用书');
      expect(normalizeHanziAnswer('what?!'), 'what');
    });

    test('maps full-width ASCII to half-width', () {
      expect(normalizeHanziAnswer('ＡＢＣ１２３'), 'ABC123');
      // Dấu câu full-width (！？) map về half-width rồi bị strip.
      expect(normalizeHanziAnswer('好！？'), '好');
    });
  });

  group('diffHanzi', () {
    test('identical strings produce one match segment', () {
      expect(diffHanzi('我喝茶', '我喝茶'), const [
        HanziDiffSegment('我喝茶', HanziDiffKind.match),
      ]);
    });

    test('substitution becomes a wrong segment', () {
      expect(diffHanzi('我喝茶', '我喜茶'), const [
        HanziDiffSegment('我', HanziDiffKind.match),
        HanziDiffSegment('喜', HanziDiffKind.wrong),
        HanziDiffSegment('茶', HanziDiffKind.match),
      ]);
    });

    test('omission becomes a missing segment', () {
      expect(diffHanzi('我喝茶', '我茶'), const [
        HanziDiffSegment('我', HanziDiffKind.match),
        HanziDiffSegment('喝', HanziDiffKind.missing),
        HanziDiffSegment('茶', HanziDiffKind.match),
      ]);
    });

    test('insertion becomes an extra segment', () {
      expect(diffHanzi('我喝茶', '我喝喝茶'), const [
        HanziDiffSegment('我喝', HanziDiffKind.match),
        HanziDiffSegment('喝', HanziDiffKind.extra),
        HanziDiffSegment('茶', HanziDiffKind.match),
      ]);
    });

    test('completely different answer pairs into wrong segments', () {
      final segments = diffHanzi('你好', '再见');
      expect(
        segments.every(
          (s) => s.kind == HanziDiffKind.wrong || s.kind != HanziDiffKind.match,
        ),
        isTrue,
      );
    });

    test('empty attempt marks everything missing', () {
      expect(diffHanzi('你好', ''), const [
        HanziDiffSegment('你好', HanziDiffKind.missing),
      ]);
    });
  });
}
