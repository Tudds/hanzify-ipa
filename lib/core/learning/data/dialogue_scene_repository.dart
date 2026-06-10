import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/dialogue_scene.dart';

class DialogueSceneRepository {
  DialogueSceneRepository({AssetBundle? bundle})
    : _bundle = bundle,
      _includeBuiltInScenes = bundle == null;

  static const conversationAsset = 'assets/data/conversation.json';
  static const nextHsk3ConversationSceneId = 'conv_hsk3_conditions_01';

  final AssetBundle? _bundle;
  final bool _includeBuiltInScenes;
  Map<String, DialogueScene>? _cache;

  Future<Map<String, DialogueScene>> loadScenes() async {
    final cached = _cache;
    if (cached != null) return cached;
    final bundle = _bundle ?? rootBundle;
    final raw = await bundle.loadString(conversationAsset);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final scenes = <String, DialogueScene>{
      for (final entry in list)
        if (entry['id'] case final String id) id: DialogueScene.fromJson(entry),
    };
    if (_includeBuiltInScenes) {
      for (final entry in _builtInSceneJson) {
        if (entry['id'] case final String id) {
          scenes.putIfAbsent(id, () => DialogueScene.fromJson(entry));
        }
      }
    }
    _cache = scenes;
    return scenes;
  }
}

const _builtInSceneJson = [
  {
    'id': DialogueSceneRepository.nextHsk3ConversationSceneId,
    'title': 'Lập kế hoạch ôn thi',
    'titleZh': '准备考试计划',
    'titlePinyin': 'Zhǔnbèi kǎoshì jìhuà',
    'description':
        'Nhờ cố vấn HSK3 điều chỉnh cách ôn tập khi thời gian hạn chế.',
    'level': 3,
    'category': 'study',
    'icon': '📚',
    'lines': [
      {
        'speaker': 'A',
        'zh': '老师，虽然我每天学习，但是进步不太快。',
        'pinyin': 'Lǎoshī, suīrán wǒ měitiān xuéxí, dànshì jìnbù bú tài kuài.',
        'vi': 'Cô ơi, tuy ngày nào em cũng học, nhưng tiến bộ không nhanh lắm.',
      },
      {
        'speaker': 'B',
        'zh': '别着急，只要你坚持练习，就会越来越好。',
        'pinyin':
            'Bié zháojí, zhǐyào nǐ jiānchí liànxí, jiù huì yuè lái yuè hǎo.',
        'vi':
            'Đừng sốt ruột, chỉ cần em kiên trì luyện tập thì sẽ ngày càng tốt.',
      },
      {
        'speaker': 'A',
        'zh': '如果我工作很忙，还应该每天复习吗？',
        'pinyin': 'Rúguǒ wǒ gōngzuò hěn máng, hái yīnggāi měitiān fùxí ma?',
        'vi': 'Nếu công việc bận, em vẫn nên ôn mỗi ngày không?',
      },
      {
        'speaker': 'B',
        'zh': '当然。只有把今天的生词复习完，明天的课才会轻松。',
        'pinyin':
            'Dāngrán. Zhǐyǒu bǎ jīntiān de shēngcí fùxí wán, míngtiān de kè cái huì qīngsōng.',
        'vi':
            'Tất nhiên. Chỉ khi ôn xong từ mới hôm nay thì bài ngày mai mới nhẹ hơn.',
      },
      {
        'speaker': 'A',
        'zh': '那我先听一遍对话，再做练习。',
        'pinyin': 'Nà wǒ xiān tīng yí biàn duìhuà, zài zuò liànxí.',
        'vi': 'Vậy em nghe hội thoại một lượt trước, rồi làm bài luyện tập.',
      },
      {
        'speaker': 'B',
        'zh': '很好，虽然时间不多，但是方法对了就有效。',
        'pinyin':
            'Hěn hǎo, suīrán shíjiān bù duō, dànshì fāngfǎ duì le jiù yǒuxiào.',
        'vi':
            'Rất tốt, tuy thời gian không nhiều nhưng đúng phương pháp thì hiệu quả.',
      },
    ],
    'vocabulary': [
      {
        'zh': '进步',
        'pinyin': 'jìnbù',
        'vi': 'tiến bộ',
        'pos': 'động từ/danh từ',
      },
      {'zh': '坚持', 'pinyin': 'jiānchí', 'vi': 'kiên trì', 'pos': 'động từ'},
      {'zh': '复习', 'pinyin': 'fùxí', 'vi': 'ôn tập', 'pos': 'động từ'},
      {'zh': '生词', 'pinyin': 'shēngcí', 'vi': 'từ mới', 'pos': 'danh từ'},
      {'zh': '轻松', 'pinyin': 'qīngsōng', 'vi': 'nhẹ nhàng', 'pos': 'tính từ'},
      {'zh': '方法', 'pinyin': 'fāngfǎ', 'vi': 'phương pháp', 'pos': 'danh từ'},
    ],
    'speakers': [
      {
        'code': 'A',
        'nameVi': 'Vy',
        'role': 'Người học',
        'avatarColor': '#5E35B1',
      },
      {
        'code': 'B',
        'nameVi': 'Cô Mai',
        'role': 'Cố vấn HSK3',
        'avatarColor': '#00897B',
      },
    ],
    'relatedGrammar': ['g_suiran_danshi', 'g_zhiyao_jiu', 'g_zhiyou_cai'],
    'cultureTip':
        'Ở lớp tiếng Trung, người học thường gọi giáo viên là 老师 để giữ sắc thái lịch sự, kể cả khi trao đổi riêng về kế hoạch học.',
  },
];
