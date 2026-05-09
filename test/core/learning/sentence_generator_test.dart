import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/learning/application/sentence_generator.dart';

void main() {
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
}
