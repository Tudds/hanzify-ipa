import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/application/sentence_generator.dart';

void main() {
  test('T1 blocks physical adjective in person gradable frame', () {
    final generator = _generator(
      head: _vocab('新鲜', pos: 'adj', vi: 'tươi'),
      partners: [_partner('食品', scenario: 'food')],
      frames: [
        _frame(
          id: 'F-H4-04',
          zh: '随着时间的推移，我越来越{ADJ}。',
          vi: 'Theo thời gian, tôi càng ngày càng {VADJ}.',
          slots: ['ADJ'],
          headSemanticWhitelist: ['adj.gradable.person'],
        ),
      ],
      headSemantics: {
        '新鲜': {'adj.physical_property'},
      },
    );

    final sentences = generator.generate(targetWord: '新鲜');

    expect(sentences.map((s) => s.zh), isNot(contains('我越来越新鲜')));
    expect(sentences, isEmpty);
  });

  test('T2 blocks health body frame when partner semantics do not match', () {
    final generator = _generator(
      head: _vocab('新鲜', pos: 'adj', vi: 'tươi'),
      partners: [_partner('食品', scenario: 'general')],
      frames: [
        _frame(
          id: 'F-H4-11',
          zh: '{N}对身体非常{ADJ}。',
          vi: '{VN} rất {VADJ} cho sức khỏe.',
          slots: ['N', 'ADJ'],
          headSemanticWhitelist: ['adj.evaluative.health'],
          partnerSemanticWhitelist: ['noun.body_topic', 'noun.food'],
        ),
      ],
      headSemantics: {
        '新鲜': {'adj.evaluative.health'},
      },
    );

    final sentences = generator.generate(targetWord: '新鲜');

    expect(sentences.map((s) => s.zh), isNot(contains('食品对身体非常新鲜。')));
    expect(sentences, isEmpty);
  });

  test('T3 blocks cognition verb in health purpose frame', () {
    final generator = _generator(
      head: _vocab('考虑'),
      partners: [_partner('问题', scenario: 'study')],
      frames: [
        _frame(
          id: 'F-H3-06',
          zh: '我为了健康而{VO}。',
          vi: 'Tôi {VVO} vì sức khỏe.',
          headSemanticWhitelist: ['verb.healthy'],
          partnerScenarioWhitelist: ['health', 'sports', 'food'],
        ),
      ],
      headSemantics: {
        '考虑': {'verb.cognition'},
      },
    );

    final sentences = generator.generate(targetWord: '考虑');

    expect(sentences.map((s) => s.zh), isNot(contains('我为了健康而考虑问题。')));
    expect(sentences, isEmpty);
  });

  test('T4 blocks non-skill verb in ability frame', () {
    final generator = _generator(
      head: _vocab('考虑'),
      partners: [_partner('情况')],
      frames: [
        _frame(
          id: 'F-H2-06',
          zh: '我会{VO}。',
          vi: 'Tôi biết {VVO}.',
          headSemanticWhitelist: ['verb.skill'],
          partnerSemanticWhitelist: ['noun.skill_object'],
        ),
      ],
      headSemantics: {
        '考虑': {'verb.cognition'},
      },
      partnerSemantics: {
        '情况': {'noun.abstract'},
      },
    );

    final sentences = generator.generate(targetWord: '考虑');

    expect(sentences.map((s) => s.zh), isNot(contains('我会考虑情况。')));
    expect(sentences, isEmpty);
  });

  test('T5 skips template containing two-character target', () {
    final generator = _generator(
      head: _vocab('考虑'),
      partners: [_partner('问题')],
      frames: [
        _frame(
          id: 'F-H4-08',
          zh: '经过仔细考虑，我决定{VO}。',
          vi: 'Sau khi cân nhắc kỹ, tôi quyết định {VVO}.',
        ),
      ],
    );

    final result = generator.generateWithStats(targetWord: '考虑');

    expect(result.sentences, isEmpty);
    expect(result.stats.targetInTemplate, 1);
  });

  test('T6 post-validation blocks repeated two-character target', () {
    final generator = _generator(
      head: _vocab('考虑'),
      partners: [_partner('问题')],
      frames: [
        _frame(
          id: 'repeat',
          zh: '考虑{VO}。',
          vi: '{VVO}.',
          forbidTargetInTemplate: false,
        ),
      ],
    );

    final result = generator.generateWithStats(targetWord: '考虑');

    expect(result.sentences.map((s) => s.zh), isNot(contains('考虑考虑问题。')));
    expect(result.stats.builtPostValidation, 1);
  });

  test('T7 deterministic exhaust returns fewer sentences than requested', () {
    final generator = _generator(
      head: _vocab('唱'),
      partners: [_partner('歌')],
      frames: [_frame(id: 'one', zh: '我{VO}。', vi: 'Tôi {VVO}.')],
    );

    final sentences = generator.generate(targetWord: '唱', count: 8);

    expect(sentences, hasLength(1));
  });

  test('T8 pair blacklist blocks noisy mined pair', () {
    final generator = _generator(
      head: _vocab('参加'),
      partners: [_partner('汉语')],
      frames: [_frame(id: 'basic', zh: '我{VO}。', vi: 'Tôi {VVO}.')],
      noisyPairBlacklist: {'参加|汉语'},
    );

    final sentences = generator.generate(targetWord: '参加');

    expect(sentences.map((s) => s.zh), isNot(contains('我参加汉语。')));
    expect(sentences, isEmpty);
  });

  test('pair blacklist blocks malformed 上中文 output', () {
    final generator = _generator(
      head: _vocab('上', vi: 'lên, trên, đi lên'),
      partners: [_partner('中文', scenario: 'study')],
      frames: [_frame(id: 'today', zh: '今天我{VO}。', vi: 'Hôm nay tôi {VVO}.')],
      noisyPairBlacklist: {'上|中文'},
    );

    final sentences = generator.generate(targetWord: '上');

    expect(sentences.map((s) => s.zh), isNot(contains('今天我上中文。')));
    expect(sentences, isEmpty);
  });

  test('pair blacklist blocks intransitive 下雨 object output', () {
    final generator = _generator(
      head: _vocab('下雨', vi: 'mưa, rơi mưa'),
      partners: [_partner('明天', scenario: 'time')],
      frames: [_frame(id: 'like', zh: '我喜欢{VO}。', vi: 'Tôi thích {VVO}.')],
      noisyPairBlacklist: {'下雨|明天'},
    );

    final sentences = generator.generate(targetWord: '下雨');

    expect(sentences.map((s) => s.zh), isNot(contains('我喜欢下雨明天。')));
    expect(sentences, isEmpty);
  });

  test('pair blacklist blocks formulaic 请问 fragments', () {
    final generator = _generator(
      head: _vocab('请问', vi: 'xin hỏi'),
      partners: [_partner('厕所', scenario: 'place')],
      frames: [_frame(id: 'basic', zh: '我{VO}。', vi: 'Tôi {VVO}.')],
      noisyPairBlacklist: {'请问|厕所'},
    );

    final sentences = generator.generate(targetWord: '请问');

    expect(sentences.map((s) => s.zh), isNot(contains('我请问厕所。')));
    expect(sentences, isEmpty);
  });

  test('pair blacklist blocks preposition 对 as plain adjective', () {
    final generator = _generator(
      head: _vocab('对', pos: 'adj', vi: 'đúng'),
      partners: [_partner('身体', scenario: 'health')],
      frames: [
        _frame(
          id: 'adj-basic',
          zh: '{N}很{ADJ}。',
          vi: '{VN} rất {VADJ}.',
          slots: ['N', 'ADJ'],
        ),
      ],
      noisyPairBlacklist: {'对|身体'},
    );

    final sentences = generator.generate(targetWord: '对');

    expect(sentences.map((s) => s.zh), isNot(contains('身体很对。')));
    expect(sentences, isEmpty);
  });

  test('pair blacklist blocks noun-compound study fragments', () {
    final generator = _generator(
      head: _vocab('学习', vi: 'học'),
      partners: [_partner('方法', scenario: 'study')],
      frames: [_frame(id: 'basic', zh: '我{VO}。', vi: 'Tôi {VVO}.')],
      noisyPairBlacklist: {'学习|方法'},
    );

    final sentences = generator.generate(targetWord: '学习');

    expect(sentences.map((s) => s.zh), isNot(contains('我学习方法。')));
    expect(sentences, isEmpty);
  });

  test('T9 pair allowlist can keep a curated pair', () {
    final generator = _generator(
      head: _vocab('锻炼'),
      partners: [
        _partner('身体', scenario: 'health', sources: ['curated']),
      ],
      frames: [
        _frame(
          id: 'F-H3-06',
          zh: '我为了健康而{VO}。',
          vi: 'Tôi {VVO} vì sức khỏe.',
          headSemanticWhitelist: ['verb.healthy'],
          partnerScenarioWhitelist: ['health', 'sports', 'food'],
        ),
      ],
      headSemantics: {
        '锻炼': {'verb.healthy'},
      },
      noisyPairBlacklist: {'锻炼|身体'},
      curatedPairAllowlist: {'锻炼|身体'},
    );

    final sentences = generator.generate(targetWord: '锻炼');

    expect(sentences.map((s) => s.zh), contains('我为了健康而锻炼身体。'));
  });

  test('T10 generation_enabled=false disables a frame', () {
    final generator = _generator(
      head: _vocab('唱'),
      partners: [_partner('歌')],
      frames: [
        _frame(
          id: 'F-H1-01',
          zh: '我{VO}。',
          vi: 'Tôi {VVO}.',
          generationEnabled: false,
        ),
      ],
    );

    final sentences = generator.generate(targetWord: '唱');

    expect(sentences.map((s) => s.frameId), isNot(contains('F-H1-01')));
    expect(sentences, isEmpty);
  });

  test('T11 RejectionStats counts disabled frames', () {
    final generator = _generator(
      head: _vocab('唱'),
      partners: [_partner('歌')],
      frames: [
        _frame(
          id: 'off',
          zh: '我{VO}。',
          vi: 'Tôi {VVO}.',
          generationEnabled: false,
        ),
      ],
    );

    final result = generator.generateWithStats(targetWord: '唱');

    expect(result.stats.frameDisabled, 1);
  });

  test('T12 SentenceFrame.fromJson keeps backward-compatible defaults', () {
    final frame = SentenceFrame.fromJson({
      'id': 'F-old',
      'zh': '我{VO}。',
      'vi': 'Tôi {VVO}.',
      'slot_types': ['VO'],
      'time': 'habitual',
      'mood': 'statement',
      'grammar_focus': 'basic_svo',
      'hsk_level_min': 1,
      'complexity': 1,
    });

    expect(frame.generationEnabled, isTrue);
    expect(frame.pinyinTemplate, isEmpty);
    expect(frame.headSemanticWhitelist, isEmpty);
    expect(frame.headSemanticBlacklist, isEmpty);
    expect(frame.partnerSemanticWhitelist, isEmpty);
    expect(frame.partnerSemanticBlacklist, isEmpty);
    expect(frame.partnerScenarioWhitelist, isEmpty);
    expect(frame.forbidTargetInTemplate, isTrue);
    expect(frame.forbiddenPatterns, isEmpty);
    expect(frame.minPartnerFrequency, 1);
    expect(frame.requiredPartnerSources, isEmpty);
    expect(frame.maxPartnerLevelDelta, 99);
  });

  test('contextual quality rejects short bare SVO candidates', () {
    final generator = _generator(
      head: _vocab('学习', vi: 'học'),
      partners: [
        _partner('中文', scenario: 'study', frequency: 3, sources: ['curated']),
      ],
      frames: [_frame(id: 'basic', zh: '我{VO}。', vi: 'Tôi {VVO}.')],
    );

    final result = generator.generateWithStats(
      targetWord: '学习',
      qualityOptions: SentenceQualityOptions.contextual,
    );

    expect(result.sentences, isEmpty);
    expect(result.stats.qualityRejected, 1);
  });

  test('contextual quality can deny noisy frame patterns by id', () {
    final generator = _generator(
      head: _vocab('学习', vi: 'học'),
      partners: [
        _partner('中文', scenario: 'study', frequency: 3, sources: ['curated']),
      ],
      frames: [
        _frame(
          id: 'denied',
          zh: '如果有时间，我就{VO}。',
          vi: 'Nếu có thời gian, tôi sẽ {VVO}.',
          complexity: 3,
        ),
      ],
    );

    final result = generator.generateWithStats(
      targetWord: '学习',
      qualityOptions: const SentenceQualityOptions(
        minHanziLength: 7,
        minViWordCount: 4,
        minFrameComplexity: 2,
        minPartnerFrequency: 2,
        minScore: 18,
        rejectBareSvo: true,
        deniedFrameIds: {'denied'},
      ),
    );

    expect(result.sentences, isEmpty);
    expect(result.stats.qualityRejected, 1);
  });

  test('quality scorer ranks richer contextual frames above bare SVO', () {
    final generator = _generator(
      head: _vocab('学习', vi: 'học'),
      partners: [
        _partner('中文', scenario: 'study', frequency: 3, sources: ['curated']),
      ],
      frames: [
        _frame(id: 'basic', zh: '我{VO}。', vi: 'Tôi {VVO}.'),
        _frame(
          id: 'context',
          zh: '如果有时间，我就{VO}。',
          vi: 'Nếu có thời gian, tôi sẽ {VVO}.',
          complexity: 3,
        ),
      ],
    );

    final sentences = generator.generate(targetWord: '学习', count: 1);

    expect(sentences.single.frameId, 'context');
    expect(sentences.single.zh, '如果有时间，我就学习中文。');
    expect(sentences.single.qualityScore, greaterThan(0));
  });

  test('quality-ranked generation stays deterministic with seed', () {
    final first =
        _generator(
          head: _vocab('学习', vi: 'học'),
          partners: [
            _partner(
              '中文',
              scenario: 'study',
              frequency: 3,
              sources: ['curated'],
            ),
            _partner(
              '汉字',
              scenario: 'culture',
              frequency: 2,
              sources: ['example'],
            ),
          ],
          frames: [
            _frame(
              id: 'context-a',
              zh: '如果有时间，我就{VO}。',
              vi: 'Nếu có thời gian, tôi sẽ {VVO}.',
              complexity: 3,
            ),
            _frame(
              id: 'context-b',
              zh: '今天我正在{VO}。',
              vi: 'Hôm nay tôi đang {VVO}.',
              complexity: 3,
            ),
          ],
        ).generate(
          targetWord: '学习',
          count: 3,
          qualityOptions: SentenceQualityOptions.contextual,
        );
    final second =
        _generator(
          head: _vocab('学习', vi: 'học'),
          partners: [
            _partner(
              '中文',
              scenario: 'study',
              frequency: 3,
              sources: ['curated'],
            ),
            _partner(
              '汉字',
              scenario: 'culture',
              frequency: 2,
              sources: ['example'],
            ),
          ],
          frames: [
            _frame(
              id: 'context-a',
              zh: '如果有时间，我就{VO}。',
              vi: 'Nếu có thời gian, tôi sẽ {VVO}.',
              complexity: 3,
            ),
            _frame(
              id: 'context-b',
              zh: '今天我正在{VO}。',
              vi: 'Hôm nay tôi đang {VVO}.',
              complexity: 3,
            ),
          ],
        ).generate(
          targetWord: '学习',
          count: 3,
          qualityOptions: SentenceQualityOptions.contextual,
        );

    expect(first.map((sentence) => sentence.zh), second.map((s) => s.zh));
  });

  test('builds full sentence pinyin from frame and collocation pinyin', () {
    final generator = _generator(
      head: _vocab('学习', pinyin: 'xuéxí', vi: 'học'),
      partners: [
        _partner('中文', pinyin: 'Zhōngwén', scenario: 'study', frequency: 3),
      ],
      frames: [
        _frame(
          id: 'context',
          zh: '如果有时间，我就{VO}。',
          pinyin: 'Rúguǒ yǒu shíjiān, wǒ jiù {PVO}.',
          vi: 'Nếu có thời gian, tôi sẽ {VVO}.',
          complexity: 3,
        ),
      ],
    );

    final sentence = generator.generate(targetWord: '学习').single;

    expect(sentence.zh, '如果有时间，我就学习中文。');
    expect(sentence.pinyin, 'Rúguǒ yǒu shíjiān, wǒ jiù xuéxí Zhōngwén.');
  });

  test('leaves generated pinyin empty when a pinyin part is missing', () {
    final generator = _generator(
      head: _vocab('学习', pinyin: 'xuéxí', vi: 'học'),
      partners: [_partner('中文', pinyin: '', scenario: 'study', frequency: 3)],
      frames: [
        _frame(
          id: 'context',
          zh: '如果有时间，我就{VO}。',
          pinyin: 'Rúguǒ yǒu shíjiān, wǒ jiù {PVO}.',
          vi: 'Nếu có thời gian, tôi sẽ {VVO}.',
          complexity: 3,
        ),
      ],
    );

    final sentence = generator.generate(targetWord: '学习').single;

    expect(sentence.pinyin, isEmpty);
  });
}

SentenceGenerator _generator({
  required VocabLite head,
  required List<CollocationPartner> partners,
  required List<SentenceFrame> frames,
  Map<String, Set<String>> headSemantics = const {},
  Map<String, Set<String>> partnerSemantics = const {},
  Set<String>? noisyPairBlacklist,
  Set<String>? curatedPairAllowlist,
}) {
  final entry = CollocationEntry(
    headHanzi: head.hanzi,
    headPinyin: head.pinyin,
    headVi: head.vi,
    headLevel: head.level,
    headPos: head.pos,
    collocations: partners,
  );
  return SentenceGenerator(
    collocationsDb: CollocationsDb(
      version: '1.0',
      verbObject: head.pos == 'v' ? {head.hanzi: entry} : const {},
      adjNoun: head.pos == 'adj' ? {head.hanzi: entry} : const {},
      measureNoun: const {},
    ),
    framesBank: FramesBank(version: '1.0', frames: frames),
    vocabIndex: {
      head.hanzi: head,
      for (final partner in partners)
        partner.objectHanzi: _vocab(partner.objectHanzi, pos: 'n'),
    },
    headSemantics: headSemantics,
    partnerSemantics: partnerSemantics,
    noisyPairBlacklist: noisyPairBlacklist,
    curatedPairAllowlist: curatedPairAllowlist,
    seed: 1,
  );
}

VocabLite _vocab(
  String hanzi, {
  String pos = 'v',
  String pinyin = '',
  String vi = '',
  int level = 2,
}) {
  return VocabLite(
    hanzi: hanzi,
    pinyin: pinyin,
    vi: vi.isEmpty ? hanzi : vi,
    pos: pos,
    level: level,
  );
}

CollocationPartner _partner(
  String hanzi, {
  String pinyin = '',
  String scenario = 'general',
  List<String> sources = const ['example'],
  int frequency = 1,
  int level = 2,
}) {
  return CollocationPartner(
    objectHanzi: hanzi,
    objectPinyin: pinyin,
    objectVi: hanzi,
    objectLevel: level,
    frequency: frequency,
    sources: sources,
    scenario: scenario,
  );
}

SentenceFrame _frame({
  required String id,
  required String zh,
  String pinyin = '',
  required String vi,
  List<String> slots = const ['VO'],
  int complexity = 1,
  bool generationEnabled = true,
  List<String> headSemanticWhitelist = const [],
  List<String> headSemanticBlacklist = const [],
  List<String> partnerSemanticWhitelist = const [],
  List<String> partnerSemanticBlacklist = const [],
  List<String> partnerScenarioWhitelist = const [],
  bool forbidTargetInTemplate = true,
}) {
  return SentenceFrame(
    id: id,
    zhTemplate: zh,
    pinyinTemplate: pinyin,
    viTemplate: vi,
    slotTypes: slots.map(SlotTypeX.fromString).toList(),
    time: 'habitual',
    mood: 'statement',
    grammarFocus: 'test',
    hskLevelMin: 1,
    complexity: complexity,
    generationEnabled: generationEnabled,
    headSemanticWhitelist: headSemanticWhitelist,
    headSemanticBlacklist: headSemanticBlacklist,
    partnerSemanticWhitelist: partnerSemanticWhitelist,
    partnerSemanticBlacklist: partnerSemanticBlacklist,
    partnerScenarioWhitelist: partnerScenarioWhitelist,
    forbidTargetInTemplate: forbidTargetInTemplate,
  );
}
