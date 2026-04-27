import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/graph/graph_repository_asset_impl.dart';

// Fixture data — conv_greeting_01 (trích từ real assets)
const _convToVocab = {
  'conv_greeting_01': ['hsk1_你好', 'hsk1_叫', 'hsk1_是', 'hsk1_哪', 'hsk1_国'],
};
const _vocabToConv = {
  'hsk1_你好': ['conv_greeting_01'],
  'hsk1_叫': ['conv_greeting_01'],
  'hsk1_是': ['conv_greeting_01'],
};
const _vocabToSentence = {
  'hsk1_你好': ['conv_greeting_01#L0', 'conv_greeting_01#L1'],
  'hsk1_叫': ['conv_greeting_01#L1', 'conv_greeting_01#L2'],
  'hsk1_是': ['conv_greeting_01#L2'],
};
const _convToGrammar = {
  'conv_greeting_01': ['g_shi', 'g_wh_question'],
};
const _grammarToSentence = {
  'g_shi': ['conv_greeting_01#L2'],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock rootBundle để trả về fixture JSON
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          final Map<String, dynamic>? data = switch (key) {
            'assets/data/graph/inverted/conv_to_vocab.json' => _convToVocab,
            'assets/data/graph/inverted/vocab_to_conv.json' => _vocabToConv,
            'assets/data/graph/inverted/vocab_to_sentence.json' =>
              _vocabToSentence,
            'assets/data/graph/inverted/conv_to_grammar.json' => _convToGrammar,
            'assets/data/graph/inverted/grammar_to_sentence.json' =>
              _grammarToSentence,
            _ => null,
          };
          if (data == null) return null;
          final encoded = utf8.encode(jsonEncode(data));
          return ByteData.view(Uint8List.fromList(encoded).buffer);
        });
  });

  group('GraphRepositoryAssetImpl', () {
    late GraphRepositoryAssetImpl repo;

    setUp(() async {
      repo = await GraphRepositoryAssetImpl.load();
    });

    test('getVocabIdsForConv returns correct IDs', () async {
      final ids = await repo.getVocabIdsForConv('conv_greeting_01');
      expect(ids, containsAll(['hsk1_你好', 'hsk1_叫', 'hsk1_是']));
      expect(ids.length, 5);
    });

    test('getGrammarIdsForConv returns relatedGrammar IDs', () async {
      final ids = await repo.getGrammarIdsForConv('conv_greeting_01');
      expect(ids, containsAll(['g_shi', 'g_wh_question']));
    });

    test('getConvsForVocab returns correct conv refs', () async {
      final refs = await repo.getConvsForVocab('hsk1_你好');
      expect(refs.length, 1);
      expect(refs.first.convId, 'conv_greeting_01');
      expect(
        refs.first.sentenceIds,
        containsAll(['conv_greeting_01#L0', 'conv_greeting_01#L1']),
      );
    });

    test('getSentencesForGrammar returns sentence IDs', () async {
      final sents = await repo.getSentencesForGrammar('g_shi');
      expect(sents, contains('conv_greeting_01#L2'));
    });

    test(
      'getConversationContext — rankedVocabs in descending score order',
      () async {
        final ctx = await repo.getConversationContext('conv_greeting_01');

        expect(ctx.convId, 'conv_greeting_01');
        expect(ctx.rankedVocabs, isNotEmpty);

        // Scores are sorted descending
        for (int i = 0; i < ctx.rankedVocabs.length - 1; i++) {
          expect(
            ctx.rankedVocabs[i].score,
            greaterThanOrEqualTo(ctx.rankedVocabs[i + 1].score),
          );
        }
      },
    );

    test(
      'getConversationContext — grammarRefs matches conv_to_grammar',
      () async {
        final ctx = await repo.getConversationContext('conv_greeting_01');
        final grammarIds = ctx.grammarRefs.map((r) => r.grammarId).toList();
        expect(grammarIds, containsAll(['g_shi', 'g_wh_question']));
      },
    );

    test(
      'getConversationContext — vocab with most sentences ranks first',
      () async {
        final ctx = await repo.getConversationContext('conv_greeting_01');
        // hsk1_你好 has 2 sentences, hsk1_是 has 1 → 你好 should rank higher
        final vNihao = ctx.rankedVocabs.indexWhere(
          (r) => r.vocabId == 'hsk1_你好',
        );
        final vShi = ctx.rankedVocabs.indexWhere((r) => r.vocabId == 'hsk1_是');
        expect(vNihao, lessThan(vShi));
      },
    );

    test('unknown convId returns empty context gracefully', () async {
      final ctx = await repo.getConversationContext('conv_nonexistent');
      expect(ctx.rankedVocabs, isEmpty);
      expect(ctx.grammarRefs, isEmpty);
    });

    test('unknown vocabId returns empty list gracefully', () async {
      final refs = await repo.getConvsForVocab('hsk99_xyz');
      expect(refs, isEmpty);
    });
  });
}
