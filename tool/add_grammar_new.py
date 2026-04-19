#!/usr/bin/env python3
"""
A3b — Add 14 new grammar entries to fix remaining broken refs.
Run AFTER migrate_phase_a.py.

Usage:
  python3 tool/add_grammar_new.py [--dry-run]
"""

import json
import sys
import os

DRY_RUN = '--dry-run' in sys.argv
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')


def load(f):
    with open(os.path.join(DATA_DIR, f), encoding='utf-8') as fh:
        return json.load(fh)


def save(f, data):
    path = os.path.join(DATA_DIR, f)
    if DRY_RUN:
        print(f'  [dry-run] would write {path} ({len(data)} entries)')
        return
    with open(path, 'w', encoding='utf-8') as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
    print(f'  ✓ {path} ({len(data)} entries)')


# ── New HSK1 grammar entries ─────────────────────────────────────────────────

NEW_HSK1 = [
    {
        "id": "g_wh_question",
        "title": "Câu hỏi với từ nghi vấn",
        "structure": "S + V + [疑问词]",
        "explanation": "Tiếng Trung dùng từ nghi vấn (什么、谁、哪、哪里、什么时候、为什么、怎么) đặt ngay tại vị trí của danh từ cần hỏi — không đảo ngược trật tự câu như tiếng Anh.",
        "level": 1,
        "category": "question",
        "formulaParts": [
            {"text": "S", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "V", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "疑问词", "isHighlighted": True}
        ],
        "usages": [
            {"icon": "❓", "title": "什么 — hỏi về vật/việc", "description": "你喝什么？ → Bạn uống gì?"},
            {"icon": "👤", "title": "谁 — hỏi về người", "description": "他是谁？ → Anh ấy là ai?"},
            {"icon": "📍", "title": "哪里/哪儿 — hỏi về nơi chốn", "description": "你去哪里？ → Bạn đi đâu?"},
            {"icon": "⏰", "title": "什么时候 — hỏi thời gian", "description": "你什么时候来？ → Bạn bao giờ đến?"}
        ],
        "examples": [
            {"zh": "你叫什么名字？", "pinyin": "Nǐ jiào shénme míngzi?", "vi": "Bạn tên gì?"},
            {"zh": "这是谁的书？", "pinyin": "Zhè shì shéi de shū?", "vi": "Đây là sách của ai?"},
            {"zh": "你去哪里？", "pinyin": "Nǐ qù nǎlǐ?", "vi": "Bạn đi đâu?"},
            {"zh": "你为什么学中文？", "pinyin": "Nǐ wèishéme xué Zhōngwén?", "vi": "Bạn vì sao học tiếng Trung?"}
        ],
        "exampleTags": ["TÊN", "SỞ HỮU", "NƠI CHỐN", "LÝ DO"],
        "relatedGrammar": ["g_ma", "g_svo", "g_shi"]
    },
    {
        "id": "g_he_conjunction",
        "title": "Liên từ 和 (và, cùng)",
        "structure": "A + 和 + B",
        "explanation": "和 (hé) dùng để nối hai danh từ hoặc đại từ. Lưu ý: 和 chủ yếu nối danh từ, không dùng để nối mệnh đề (câu) như 'và' trong tiếng Việt — dùng 而且 hoặc 也 khi nối câu.",
        "level": 1,
        "category": "conjunction",
        "formulaParts": [
            {"text": "A (danh từ)", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "和", "isHighlighted": True},
            {"text": "+", "isHighlighted": False},
            {"text": "B (danh từ)", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "🔗", "title": "Nối danh từ/đại từ", "description": "我和你 (tôi và bạn), 苹果和香蕉 (táo và chuối)"},
            {"icon": "⚠️", "title": "Không nối mệnh đề", "description": "Sai: 我吃饭和他喝水。Đúng: 我吃饭，他喝水。"}
        ],
        "examples": [
            {"zh": "我和我的朋友去图书馆。", "pinyin": "Wǒ hé wǒ de péngyou qù túshūguǎn.", "vi": "Tôi và bạn tôi đi thư viện."},
            {"zh": "桌子上有书和笔。", "pinyin": "Zhuōzi shàng yǒu shū hé bǐ.", "vi": "Trên bàn có sách và bút."},
            {"zh": "他喜欢音乐和电影。", "pinyin": "Tā xǐhuān yīnyuè hé diànyǐng.", "vi": "Anh ấy thích âm nhạc và phim."}
        ],
        "exampleTags": ["NGƯỜI", "VẬT", "SỞ THÍCH"],
        "relatedGrammar": ["g_svo", "g_budan_erqie", "g_gen"]
    },
    {
        "id": "g_hui_future",
        "title": "会 — sẽ / biết làm",
        "structure": "S + 会 + V",
        "explanation": "会 (huì) có hai nghĩa chính: (1) khả năng học được — biết làm gì đó; (2) dự đoán/tương lai — sẽ xảy ra. Phân biệt với 能 (có thể do điều kiện cho phép) và 可以 (được phép).",
        "level": 1,
        "category": "modal",
        "formulaParts": [
            {"text": "S", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "会", "isHighlighted": True},
            {"text": "+", "isHighlighted": False},
            {"text": "V", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "🎓", "title": "Khả năng (học được)", "description": "我会说中文 — Tôi biết nói tiếng Trung (đã học được)"},
            {"icon": "🔮", "title": "Dự đoán tương lai", "description": "明天会下雨 — Ngày mai sẽ mưa"},
            {"icon": "❌", "title": "Phủ định: 不会", "description": "我不会游泳 — Tôi không biết bơi"}
        ],
        "examples": [
            {"zh": "我会说一点儿中文。", "pinyin": "Wǒ huì shuō yīdiǎnr Zhōngwén.", "vi": "Tôi biết nói một chút tiếng Trung."},
            {"zh": "她不会开车。", "pinyin": "Tā bù huì kāichē.", "vi": "Cô ấy không biết lái xe."},
            {"zh": "明天他会来吗？", "pinyin": "Míngtiān tā huì lái ma?", "vi": "Ngày mai anh ấy có đến không?"},
            {"zh": "这件事情会很难。", "pinyin": "Zhè jiàn shìqíng huì hěn nán.", "vi": "Chuyện này sẽ rất khó."}
        ],
        "exampleTags": ["KHẢ NĂNG", "PHỦ ĐỊNH", "TƯƠNG LAI", "DỰ ĐOÁN"],
        "relatedGrammar": ["g_yao", "g_xiang", "g_neg_bu"]
    },
    {
        "id": "g_bie_negation",
        "title": "别 — đừng (mệnh lệnh phủ định)",
        "structure": "别 + V (+ 了)",
        "explanation": "别 (bié) dùng để ra lệnh phủ định — yêu cầu ai đó không làm gì. Nhẹ nhàng hơn 不要. Thường thêm 了 cuối câu để nhấn mạnh hoặc thể hiện sự thay đổi.",
        "level": 1,
        "category": "negation",
        "formulaParts": [
            {"text": "别", "isHighlighted": True},
            {"text": "+", "isHighlighted": False},
            {"text": "V", "isHighlighted": False},
            {"text": "(+ 了)", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "🚫", "title": "Cấm/khuyên không làm", "description": "别说话 — Đừng nói chuyện"},
            {"icon": "💬", "title": "Nhấn mạnh với 了", "description": "别哭了 — Đừng khóc nữa (đang khóc → dừng lại)"},
            {"icon": "🔄", "title": "别...了 — thôi đừng... nữa", "description": "Hàm ý đang làm và muốn dừng lại"}
        ],
        "examples": [
            {"zh": "别说话！", "pinyin": "Bié shuōhuà!", "vi": "Đừng nói chuyện!"},
            {"zh": "别担心，我来帮你。", "pinyin": "Bié dānxīn, wǒ lái bāng nǐ.", "vi": "Đừng lo, tôi sẽ giúp bạn."},
            {"zh": "别哭了，一切都会好的。", "pinyin": "Bié kū le, yīqiè dōu huì hǎo de.", "vi": "Đừng khóc nữa, mọi thứ sẽ ổn thôi."},
            {"zh": "别忘了带钥匙。", "pinyin": "Bié wàngle dài yàoshi.", "vi": "Đừng quên mang chìa khóa."}
        ],
        "exampleTags": ["MỆNH LỆNH", "KHUYÊN", "NHẤN MẠNH", "NHẮC NHỞ"],
        "relatedGrammar": ["g_neg_bu", "g_neg_mei", "g_yao"]
    }
]

# ── New HSK2 grammar entries ─────────────────────────────────────────────────

NEW_HSK2 = [
    {
        "id": "g_zenme",
        "title": "怎么 — như thế nào / tại sao",
        "structure": "怎么 + V / S + 怎么 + V",
        "explanation": "怎么 (zěnme) hỏi về cách thức (làm như thế nào) hoặc lý do (tại sao lại vậy). Phân biệt với 怎么样 — 怎么 đứng trước động từ, còn 怎么样 thường là vị ngữ độc lập.",
        "level": 2,
        "category": "question",
        "formulaParts": [
            {"text": "S", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "怎么", "isHighlighted": True},
            {"text": "+", "isHighlighted": False},
            {"text": "V", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "🔧", "title": "Hỏi cách làm", "description": "这个字怎么写？ → Chữ này viết như thế nào?"},
            {"icon": "❓", "title": "Hỏi lý do (bất ngờ)", "description": "你怎么来了？ → Sao bạn lại đến đây?"},
            {"icon": "🗣️", "title": "Hỏi cách nói", "description": "这个用中文怎么说？ → Cái này tiếng Trung nói thế nào?"}
        ],
        "examples": [
            {"zh": "这个字怎么写？", "pinyin": "Zhège zì zěnme xiě?", "vi": "Chữ này viết như thế nào?"},
            {"zh": "去火车站怎么走？", "pinyin": "Qù huǒchēzhàn zěnme zǒu?", "vi": "Đến ga xe lửa đi như thế nào?"},
            {"zh": "你怎么知道的？", "pinyin": "Nǐ zěnme zhīdào de?", "vi": "Bạn biết điều đó như thế nào vậy?"},
            {"zh": "「谢谢」用英语怎么说？", "pinyin": "Xièxiè yòng Yīngyǔ zěnme shuō?", "vi": "Cảm ơn tiếng Anh nói thế nào?"}
        ],
        "exampleTags": ["VIẾT", "ĐƯỜNG ĐI", "CÁCH BIẾT", "NGÔN NGỮ"],
        "relatedGrammar": ["g_wh_question", "g_shenme", "g_shi_de"]
    },
    {
        "id": "g_zěnmeyàng",
        "title": "怎么样 — thế nào / như thế nào",
        "structure": "S + 怎么样 / 怎么样 + S？",
        "explanation": "怎么样 (zěnmeyàng) hỏi về tình trạng, đánh giá, hoặc ý kiến. Khác với 怎么 (hỏi cách thức): 怎么样 thường là vị ngữ cuối câu hoặc đứng đầu để đề nghị.",
        "level": 2,
        "category": "question",
        "formulaParts": [
            {"text": "S", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "怎么样", "isHighlighted": True}
        ],
        "usages": [
            {"icon": "💬", "title": "Hỏi tình trạng/cảm nhận", "description": "你最近怎么样？ → Dạo này bạn thế nào?"},
            {"icon": "🤔", "title": "Hỏi ý kiến/đánh giá", "description": "这个菜怎么样？ → Món này thế nào?"},
            {"icon": "💡", "title": "Đề nghị/gợi ý", "description": "我们一起去，怎么样？ → Chúng ta cùng đi, thế nào?"}
        ],
        "examples": [
            {"zh": "你最近怎么样？", "pinyin": "Nǐ zuìjìn zěnmeyàng?", "vi": "Dạo này bạn thế nào?"},
            {"zh": "这部电影怎么样？", "pinyin": "Zhè bù diànyǐng zěnmeyàng?", "vi": "Bộ phim này thế nào?"},
            {"zh": "明天一起爬山，怎么样？", "pinyin": "Míngtiān yīqǐ páshān, zěnmeyàng?", "vi": "Ngày mai cùng leo núi nhé, thế nào?"},
            {"zh": "你的身体怎么样了？", "pinyin": "Nǐ de shēntǐ zěnmeyàng le?", "vi": "Sức khỏe của bạn thế nào rồi?"}
        ],
        "exampleTags": ["THĂM HỎI", "ĐÁNH GIÁ", "GỢI Ý", "SỨC KHỎE"],
        "relatedGrammar": ["g_zenme", "g_wh_question", "g_ne"]
    },
    {
        "id": "g_youdianr",
        "title": "有点儿 — hơi..., có chút...",
        "structure": "S + 有点儿 + adj/V",
        "explanation": "有点儿 (yǒudiǎnr) diễn tả mức độ nhỏ, thường mang hàm ý không hài lòng hoặc cảm giác tiêu cực. Phân biệt với 一点儿 (yīdiǎnr) đứng sau tính từ: 有点儿贵 (hơi đắt — phàn nàn) vs 便宜一点儿 (rẻ hơn một chút — yêu cầu).",
        "level": 2,
        "category": "degree",
        "formulaParts": [
            {"text": "S", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "有点儿", "isHighlighted": True},
            {"text": "+", "isHighlighted": False},
            {"text": "adj/V (thường tiêu cực)", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "😕", "title": "Tính từ tiêu cực", "description": "有点儿贵 (hơi đắt), 有点儿累 (hơi mệt), 有点儿难 (hơi khó)"},
            {"icon": "🤒", "title": "Cảm giác khó chịu", "description": "我有点儿不舒服 — Tôi hơi không khỏe"},
            {"icon": "⚠️", "title": "Phân biệt với 一点儿", "description": "有点儿 + adj (trước adj) ≠ adj + 一点儿 (sau adj)"}
        ],
        "examples": [
            {"zh": "这道题有点儿难。", "pinyin": "Zhè dào tí yǒudiǎnr nán.", "vi": "Bài này hơi khó."},
            {"zh": "我今天有点儿累。", "pinyin": "Wǒ jīntiān yǒudiǎnr lèi.", "vi": "Hôm nay tôi hơi mệt."},
            {"zh": "这件衣服有点儿贵。", "pinyin": "Zhè jiàn yīfú yǒudiǎnr guì.", "vi": "Cái áo này hơi đắt."},
            {"zh": "她有点儿不高兴。", "pinyin": "Tā yǒudiǎnr bù gāoxìng.", "vi": "Cô ấy có vẻ hơi không vui."}
        ],
        "exampleTags": ["ĐỘ KHÓ", "CẢM GIÁC", "GIÁ CẢ", "TÂM TRẠNG"],
        "relatedGrammar": ["g_yidianr", "g_tai_le", "g_bi"]
    },
    {
        "id": "g_yixia",
        "title": "一下 — thử / một chút / làm nhẹ nhàng",
        "structure": "V + 一下",
        "explanation": "一下 (yīxià) đứng sau động từ, làm mềm yêu cầu hoặc chỉ hành động ngắn, nhẹ nhàng, thử làm. Giúp câu ra lệnh/yêu cầu nghe lịch sự hơn nhiều.",
        "level": 2,
        "category": "aspect",
        "formulaParts": [
            {"text": "V", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "一下", "isHighlighted": True}
        ],
        "usages": [
            {"icon": "🙏", "title": "Làm mềm yêu cầu", "description": "等一下 (chờ một chút), 看一下 (nhìn thử xem)"},
            {"icon": "⚡", "title": "Hành động ngắn/nhanh", "description": "我去一下 — Tôi đi một chút (sẽ quay lại)"},
            {"icon": "🔍", "title": "Thử làm xem sao", "description": "你试一下 — Bạn thử xem"}
        ],
        "examples": [
            {"zh": "请等一下，我马上来。", "pinyin": "Qǐng děng yīxià, wǒ mǎshàng lái.", "vi": "Vui lòng đợi một chút, tôi đến ngay."},
            {"zh": "你帮我看一下这封信。", "pinyin": "Nǐ bāng wǒ kàn yīxià zhè fēng xìn.", "vi": "Bạn giúp tôi xem thử bức thư này."},
            {"zh": "我去一下洗手间。", "pinyin": "Wǒ qù yīxià xǐshǒujiān.", "vi": "Tôi đi vệ sinh một chút."},
            {"zh": "你试一下这双鞋。", "pinyin": "Nǐ shì yīxià zhè shuāng xié.", "vi": "Bạn thử đôi giày này xem."}
        ],
        "exampleTags": ["ĐỢI", "NHỜ VẢ", "ĐI ĐÂU ĐÓ", "THỬ"],
        "relatedGrammar": ["g_yidianr", "g_zhe", "g_le1"]
    },
    {
        "id": "g_ránhòu",
        "title": "然后 — rồi, sau đó",
        "structure": "..., 然后 + [mệnh đề tiếp theo]",
        "explanation": "然后 (ránhòu) nối hai hành động hoặc sự kiện theo trình tự thời gian — hành động thứ hai xảy ra SAU hành động thứ nhất. Tương tự 'rồi', 'sau đó', 'tiếp theo đó' trong tiếng Việt.",
        "level": 2,
        "category": "conjunction",
        "formulaParts": [
            {"text": "[hành động 1]", "isHighlighted": False},
            {"text": "，", "isHighlighted": False},
            {"text": "然后", "isHighlighted": True},
            {"text": "+", "isHighlighted": False},
            {"text": "[hành động 2]", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "1️⃣", "title": "Trình tự hành động", "description": "我先吃饭，然后去学习 — Tôi ăn cơm trước, rồi đi học"},
            {"icon": "📋", "title": "Hướng dẫn từng bước", "description": "Dùng nhiều trong chỉ đường, công thức nấu ăn"},
            {"icon": "📖", "title": "Kể chuyện", "description": "他进来，然后坐下 — Anh ấy bước vào, rồi ngồi xuống"}
        ],
        "examples": [
            {"zh": "我先洗澡，然后睡觉。", "pinyin": "Wǒ xiān xǐzǎo, ránhòu shuìjiào.", "vi": "Tôi tắm trước, rồi đi ngủ."},
            {"zh": "你先直走，然后向右转。", "pinyin": "Nǐ xiān zhí zǒu, ránhòu xiàng yòu zhuǎn.", "vi": "Bạn đi thẳng trước, rồi rẽ phải."},
            {"zh": "她喝了一杯水，然后继续工作。", "pinyin": "Tā hēle yī bēi shuǐ, ránhòu jìxù gōngzuò.", "vi": "Cô ấy uống một ly nước, rồi tiếp tục làm việc."}
        ],
        "exampleTags": ["THÓI QUEN", "CHỈ ĐƯỜNG", "KỂ CHUYỆN"],
        "relatedGrammar": ["g_xian_ránhòu", "g_jiu", "g_le1"]
    },
    {
        "id": "g_xian_ránhòu",
        "title": "先...然后 — trước...rồi mới",
        "structure": "先 + V1，然后 + V2",
        "explanation": "先 (xiān) + 然后 (ránhòu) nhấn mạnh thứ tự ưu tiên: làm việc này TRƯỚC, sau đó mới làm việc kia. 先 đứng trước động từ đầu tiên, nhấn mạnh tính tuần tự.",
        "level": 2,
        "category": "conjunction",
        "formulaParts": [
            {"text": "先", "isHighlighted": True},
            {"text": "+ V1，", "isHighlighted": False},
            {"text": "然后", "isHighlighted": True},
            {"text": "+ V2", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "📝", "title": "Thứ tự bắt buộc", "description": "先想好，然后说 — Nghĩ kỹ trước, rồi mới nói"},
            {"icon": "🍽️", "title": "Lập kế hoạch", "description": "我们先吃饭，然后去看电影 — Ăn trước rồi đi xem phim"},
            {"icon": "🎯", "title": "Khuyên nhủ", "description": "你先休息一下，然后再做 — Nghỉ chút đã rồi làm tiếp"}
        ],
        "examples": [
            {"zh": "你先完成作业，然后才能玩。", "pinyin": "Nǐ xiān wánchéng zuòyè, ránhòu cái néng wán.", "vi": "Bạn làm xong bài tập trước, rồi mới được chơi."},
            {"zh": "我们先讨论一下，然后做决定。", "pinyin": "Wǒmen xiān tǎolùn yīxià, ránhòu zuò juédìng.", "vi": "Chúng ta thảo luận trước, rồi mới ra quyết định."},
            {"zh": "先把这里搞清楚，然后看下一页。", "pinyin": "Xiān bǎ zhèlǐ gǎo qīngchǔ, ránhòu kàn xià yī yè.", "vi": "Hiểu rõ phần này trước, rồi mới đọc trang tiếp."}
        ],
        "exampleTags": ["QUY TẮC", "KẾ HOẠCH", "KHUYÊN NHỦ"],
        "relatedGrammar": ["g_ránhòu", "g_cai", "g_jiu"]
    },
    {
        "id": "g_zai_repeat",
        "title": "再 — lại, thêm lần nữa",
        "structure": "再 + V (+ 一次/一下)",
        "explanation": "再 (zài) chỉ hành động lặp lại hoặc sẽ xảy ra thêm lần nữa (ở tương lai). Phân biệt với 又 (yòu) — 又 chỉ hành động đã lặp lại rồi (quá khứ). Nhớ: 再 = sẽ lại; 又 = đã lại.",
        "level": 2,
        "category": "adverb",
        "formulaParts": [
            {"text": "再", "isHighlighted": True},
            {"text": "+", "isHighlighted": False},
            {"text": "V", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "🔁", "title": "Làm lại (tương lai)", "description": "再说一次 — Nói lại một lần nữa (yêu cầu)"},
            {"icon": "👋", "title": "Tạm biệt", "description": "再见 (zàijiàn) — Gặp lại! (kết hợp cố định)"},
            {"icon": "➕", "title": "Thêm một ít nữa", "description": "再来一碗 — Cho thêm một bát nữa"}
        ],
        "examples": [
            {"zh": "请再说一遍。", "pinyin": "Qǐng zài shuō yī biàn.", "vi": "Vui lòng nói lại một lần nữa."},
            {"zh": "你再想想，这样做对吗？", "pinyin": "Nǐ zài xiǎng xiǎng, zhèyàng zuò duì ma?", "vi": "Bạn nghĩ lại xem, làm vậy có đúng không?"},
            {"zh": "我下次再来。", "pinyin": "Wǒ xià cì zài lái.", "vi": "Lần sau tôi sẽ đến lại."},
            {"zh": "再给我五分钟。", "pinyin": "Zài gěi wǒ wǔ fēnzhōng.", "vi": "Cho tôi thêm năm phút nữa."}
        ],
        "exampleTags": ["YÊU CẦU", "SUY NGHĨ", "HẸN", "THỜI GIAN"],
        "relatedGrammar": ["g_yixia", "g_guo", "g_le1"]
    },
    {
        "id": "g_hai_yao",
        "title": "还 — vẫn còn / cũng, thêm",
        "structure": "S + 还 + V/adj",
        "explanation": "还 (hái) có nhiều nghĩa: (1) vẫn còn — trạng thái/hành động tiếp tục; (2) còn nữa — thêm vào danh sách; (3) khá, tạm được — đánh giá vừa phải. Phân biệt với 再 — 还 dùng cho thực tế đang diễn ra, 再 dùng cho yêu cầu/tương lai.",
        "level": 2,
        "category": "adverb",
        "formulaParts": [
            {"text": "S", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "还", "isHighlighted": True},
            {"text": "+", "isHighlighted": False},
            {"text": "V / adj", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "⏳", "title": "Vẫn còn (tiếp diễn)", "description": "他还在睡觉 — Anh ấy vẫn đang ngủ"},
            {"icon": "➕", "title": "Còn có, thêm", "description": "我还要一杯水 — Tôi muốn thêm một ly nước"},
            {"icon": "👌", "title": "Khá, tạm ổn", "description": "这个菜还不错 — Món này khá được"}
        ],
        "examples": [
            {"zh": "你还没吃饭吗？", "pinyin": "Nǐ hái méi chī fàn ma?", "vi": "Bạn vẫn chưa ăn cơm sao?"},
            {"zh": "我还要买两个苹果。", "pinyin": "Wǒ hái yào mǎi liǎng gè píngguǒ.", "vi": "Tôi còn muốn mua thêm hai quả táo."},
            {"zh": "他的中文还可以。", "pinyin": "Tā de Zhōngwén hái kěyǐ.", "vi": "Tiếng Trung của anh ấy khá ổn."},
            {"zh": "外面还在下雨。", "pinyin": "Wàimiàn hái zài xià yǔ.", "vi": "Bên ngoài vẫn đang mưa."}
        ],
        "exampleTags": ["TIẾP DIỄN", "MUA SẮM", "ĐÁNH GIÁ", "THỜI TIẾT"],
        "relatedGrammar": ["g_zai_V", "g_zhe", "g_zai_repeat"]
    },
    {
        "id": "g_le_duration",
        "title": "了...了 — đã ... được (khoảng thời gian)",
        "structure": "V + 了 + [thời gian] + 了",
        "explanation": "Dùng hai 了 để diễn tả hành động/trạng thái đã kéo dài đến hiện tại và vẫn đang tiếp diễn. 了₁ sau động từ chỉ sự tiếp diễn, 了₂ cuối câu xác nhận tình trạng hiện tại. Khác với 了₁ đơn (đã hoàn thành).",
        "level": 2,
        "category": "aspect",
        "formulaParts": [
            {"text": "S + V", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "了", "isHighlighted": True},
            {"text": "+ [duration]", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "了", "isHighlighted": True}
        ],
        "usages": [
            {"icon": "📅", "title": "Đã làm được bao lâu", "description": "我学汉语学了两年了 — Tôi học tiếng Trung được hai năm rồi (vẫn đang học)"},
            {"icon": "🏠", "title": "Đã ở bao lâu", "description": "他在北京住了三年了 — Anh ấy ở Bắc Kinh được ba năm rồi"},
            {"icon": "⚠️", "title": "Phân biệt với 了 đơn", "description": "我学了两年 (đã học xong 2 năm, có thể đã dừng) vs 我学了两年了 (vẫn đang học)"}
        ],
        "examples": [
            {"zh": "我来北京已经住了五年了。", "pinyin": "Wǒ lái Běijīng yǐjīng zhùle wǔ nián le.", "vi": "Tôi đã sống ở Bắc Kinh được năm năm rồi."},
            {"zh": "他们认识了很多年了。", "pinyin": "Tāmen rènshile hěn duō nián le.", "vi": "Họ đã quen biết nhau nhiều năm rồi."},
            {"zh": "你等了多长时间了？", "pinyin": "Nǐ děngle duō cháng shíjiān le?", "vi": "Bạn đã đợi bao lâu rồi?"},
            {"zh": "我学中文学了两年了，还是说得不好。", "pinyin": "Wǒ xué Zhōngwén xuéle liǎng nián le, háishì shuō de bù hǎo.", "vi": "Tôi học tiếng Trung được hai năm rồi mà vẫn nói không tốt."}
        ],
        "exampleTags": ["THỜI GIAN", "Ở ĐÂU", "HỎI THỜI GIAN", "TỰ ĐÁNH GIÁ"],
        "relatedGrammar": ["g_le1", "g_le2", "g_yijing_le"]
    }
]

# ── New HSK3 grammar entries ─────────────────────────────────────────────────

NEW_HSK3 = [
    {
        "id": "g_say_transfer",
        "title": "说 — truyền đạt lời nói (câu gián tiếp)",
        "structure": "S + 说 + [nội dung]",
        "explanation": "说 (shuō) dùng để dẫn lời nói gián tiếp. Tiếng Trung không chia động từ và không cần dấu ngoặc kép khi dẫn ý — chỉ cần 说 + nội dung. Các biến thể: 告诉 (nói với ai), 问 (hỏi), 回答说 (trả lời rằng).",
        "level": 3,
        "category": "reported_speech",
        "formulaParts": [
            {"text": "S₁", "isHighlighted": False},
            {"text": "+", "isHighlighted": False},
            {"text": "说", "isHighlighted": True},
            {"text": "+", "isHighlighted": False},
            {"text": "[nội dung lời nói]", "isHighlighted": False}
        ],
        "usages": [
            {"icon": "💬", "title": "Truyền đạt lời người khác", "description": "他说他不来了 — Anh ấy nói (rằng) anh ấy không đến nữa"},
            {"icon": "📣", "title": "告诉 — nói với (ai đó)", "description": "他告诉我他结婚了 — Anh ấy nói với tôi là anh ấy đã kết hôn"},
            {"icon": "❓", "title": "问 — hỏi (gián tiếp)", "description": "她问我去不去 — Cô ấy hỏi tôi có đi không"}
        ],
        "examples": [
            {"zh": "他说他今天有事，不能来。", "pinyin": "Tā shuō tā jīntiān yǒu shì, bù néng lái.", "vi": "Anh ấy nói anh ấy hôm nay có việc, không đến được."},
            {"zh": "老师告诉我们明天考试。", "pinyin": "Lǎoshī gàosù wǒmen míngtiān kǎoshì.", "vi": "Giáo viên nói với chúng tôi ngày mai có bài kiểm tra."},
            {"zh": "她问我喜不喜欢这里。", "pinyin": "Tā wèn wǒ xǐ bu xǐhuān zhèlǐ.", "vi": "Cô ấy hỏi tôi có thích nơi này không."},
            {"zh": "朋友说这家餐厅的菜很好吃。", "pinyin": "Péngyou shuō zhè jiā cāntīng de cài hěn hǎochī.", "vi": "Bạn tôi nói đồ ăn nhà hàng này rất ngon."}
        ],
        "exampleTags": ["BẬN", "THÔNG BÁO", "HỎI GIÁN TIẾP", "GIỚI THIỆU"],
        "relatedGrammar": ["g_shi_de", "g_ruguo", "g_yinwei_suoyi"]
    }
]


def main():
    print('=== A3b — Add new grammar entries ===')
    if DRY_RUN:
        print('MODE: dry-run\n')

    # Load existing
    g1 = load('grammar_hsk1.json')
    g2 = load('grammar_hsk2.json')
    g3 = load('grammar_hsk3.json')

    existing_ids = {g['id'] for g in g1 + g2 + g3}

    # Add HSK1 entries
    added_hsk1 = 0
    for entry in NEW_HSK1:
        if entry['id'] not in existing_ids:
            g1.append(entry)
            added_hsk1 += 1
            print(f'  + HSK1: {entry["id"]} — {entry["title"]}')
        else:
            print(f'  skip (exists): {entry["id"]}')

    # Add HSK2 entries
    added_hsk2 = 0
    for entry in NEW_HSK2:
        if entry['id'] not in existing_ids:
            g2.append(entry)
            added_hsk2 += 1
            print(f'  + HSK2: {entry["id"]} — {entry["title"]}')
        else:
            print(f'  skip (exists): {entry["id"]}')

    # Add HSK3 entries
    added_hsk3 = 0
    for entry in NEW_HSK3:
        if entry['id'] not in existing_ids:
            g3.append(entry)
            added_hsk3 += 1
            print(f'  + HSK3: {entry["id"]} — {entry["title"]}')
        else:
            print(f'  skip (exists): {entry["id"]}')

    save('grammar_hsk1.json', g1)
    save('grammar_hsk2.json', g2)
    save('grammar_hsk3.json', g3)

    print(f'\nAdded: {added_hsk1} HSK1, {added_hsk2} HSK2, {added_hsk3} HSK3')
    print(f'Totals: {len(g1)} HSK1, {len(g2)} HSK2, {len(g3)} HSK3')

    # Validate remaining broken refs
    print('\n── Post-add validation ──')
    all_ids = {g['id'] for g in g1 + g2 + g3}
    conv = load('conversation.json')
    broken = [(c['id'], ref) for c in conv for ref in c.get('relatedGrammar', []) if ref not in all_ids]
    if broken:
        print(f'⚠ Still broken: {len(broken)}')
        for cid, ref in broken[:10]:
            print(f'  {cid} → {ref}')
    else:
        print('✓ All grammar refs resolved')


if __name__ == '__main__':
    main()
