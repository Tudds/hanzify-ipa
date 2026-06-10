import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'generated collocation pool covers HSK1-HSK4 without duplicate text',
    () async {
      final data = <Map<String, dynamic>>[];
      for (var level = 1; level <= 4; level++) {
        final raw = await rootBundle.loadString(
          'assets/data/generated/collocation_pool_hsk$level.json',
        );
        data.addAll((jsonDecode(raw) as List).cast<Map<String, dynamic>>());
      }
      final texts = <String>{};
      final levels = <int>{};

      for (final item in data) {
        expect(item['id'], isA<String>());
        expect(item['textCn'], isA<String>());
        expect(item['textVi'], isA<String>());
        expect(item['difficulty'], isA<num>());
        expect(texts.add(item['textCn'] as String), isTrue);
        levels.add(item['level'] as int);
      }

      expect(data.length, greaterThan(1000));
      expect(levels, containsAll(<int>{1, 2, 3, 4}));
    },
  );
}
