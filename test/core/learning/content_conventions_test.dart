import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// QA conventions trên data THẬT trong assets/data — guard cho pipeline
/// content: dictation/shorts/quiz đều dựa vào các bất biến này.
/// Đọc qua dart:io (cwd của `flutter test` là package root).
void main() {
  final conversations =
      jsonDecode(File('assets/data/conversation.json').readAsStringSync())
          as List<dynamic>;

  // convId -> set các câu zh (mirror logic _withConversationAudio).
  final conversationLines = <String, Set<String>>{
    for (final conv in conversations.cast<Map<String, dynamic>>())
      conv['id'] as String: {
        for (final line
            in (conv['lines'] as List? ?? const [])
                .cast<Map<String, dynamic>>())
          if (line['zh'] is String) line['zh'] as String,
      },
  };

  test('conversation.json: mọi line có zh + vi', () {
    for (final conv in conversations.cast<Map<String, dynamic>>()) {
      for (final line
          in (conv['lines'] as List? ?? const [])
              .cast<Map<String, dynamic>>()) {
        expect((line['zh'] as String?) ?? '', isNotEmpty,
            reason: 'zh rỗng trong ${conv['id']}');
        expect((line['vi'] as String?) ?? '', isNotEmpty,
            reason: 'vi rỗng trong ${conv['id']}');
      }
    }
  });

  for (var level = 1; level <= 4; level++) {
    test('collocation pool HSK$level: trường bắt buộc + audio resolvable', () {
      final pool = (jsonDecode(
        File(
          'assets/data/generated/collocation_pool_hsk$level.json',
        ).readAsStringSync(),
      ) as List)
          .cast<Map<String, dynamic>>();

      expect(pool, isNotEmpty);
      final seenIds = <String>{};
      var listenSupply = 0;

      for (final item in pool) {
        final id = item['id'] as String? ?? '';
        expect(id, isNotEmpty);
        expect(seenIds.add(id), isTrue, reason: 'id trùng: $id');
        expect(item['level'], level);
        expect((item['textCn'] as String?) ?? '', isNotEmpty,
            reason: 'textCn rỗng: $id');
        // Mode readVi và hiển thị nghĩa dựa vào 2 trường này — pipeline hiện
        // tại đạt 100%, giữ làm contract.
        expect((item['pinyin'] as String?) ?? '', isNotEmpty,
            reason: 'pinyin rỗng: $id');
        expect((item['textVi'] as String?) ?? '', isNotEmpty,
            reason: 'textVi rỗng: $id');
        final difficulty = (item['difficulty'] as num).toDouble();
        expect(difficulty, greaterThan(0), reason: 'difficulty $id');
        expect(difficulty, lessThanOrEqualTo(10), reason: 'difficulty $id');

        // Câu nguồn hội thoại phải resolve được về conversation.json —
        // nếu không, URL audio CDN suy ra sẽ sai/404.
        final conversationIds =
            (item['conversationIds'] as List? ?? const []).cast<String>();
        if (item['source'] == 'conversation_line' &&
            conversationIds.length == 1) {
          final lines = conversationLines[conversationIds.first];
          expect(lines, isNotNull,
              reason: 'conv ${conversationIds.first} không tồn tại ($id)');
          expect(lines, contains(item['textCn']),
              reason: 'line không khớp conversation.json: $id');
          if ((item['textCn'] as String).runes.length <= 16) {
            listenSupply++;
          }
        }
      }

      // Nguồn nghe chính (câu hội thoại có audio thật, đủ ngắn). HSK4 mỏng
      // (3 câu) — service đã tự bổ sung vocab example khi < 10.
      expect(listenSupply, greaterThan(0),
          reason: 'HSK$level không còn câu luyện nghe nào từ hội thoại');
    });

    test('vocab HSK$level: đủ nguồn ví dụ ngắn cho dictation fallback', () {
      final vocab = (jsonDecode(
        File('assets/data/hsk$level.json').readAsStringSync(),
      ) as List)
          .cast<Map<String, dynamic>>();

      final shortExamples = vocab.where((item) {
        final examples =
            (item['exampleSentences'] as List? ?? const [])
                .cast<Map<String, dynamic>>();
        if (examples.isEmpty) return false;
        final first = examples.first;
        final cn = (first['cn'] as String?) ?? '';
        final vi = (first['vi'] as String?) ?? '';
        return cn.isNotEmpty && vi.isNotEmpty && cn.runes.length <= 16;
      }).length;

      // Thực tế ≥ 979/level; ngưỡng 50 đủ chặt để báo động khi pipeline hỏng.
      expect(shortExamples, greaterThanOrEqualTo(50));
    });
  }
}
