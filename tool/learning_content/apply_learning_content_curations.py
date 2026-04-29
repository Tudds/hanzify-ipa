#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'assets' / 'data'
GENERATED = DATA / 'generated'
CONVERSATION_FILE = DATA / 'conversation.json'
VI_SEED_FILE = GENERATED / 'vi_short_overrides_seed_hsk1_3.json'
SLOT_SEED_FILE = GENERATED / 'slot_compatibility_seed_hsk1_3.json'
VI_CURATED_FILE = GENERATED / 'vi_short_overrides_curated_hsk1_3.json'
SLOT_CURATED_FILE = GENERATED / 'slot_compatibility_curated_hsk1_3.json'

VI_OVERRIDES = {
    '了': 'rồi',
    '们': 'số nhiều',
    '在': 'ở',
    '请': 'xin mời',
    '会': 'biết',
    '就': 'thì',
    '把': 'đem',
    '被': 'bị',
    '比': 'so với',
    '跟': 'với',
    '对': 'đối với',
    '为': 'vì',
    '为了': 'để',
    '虽然': 'tuy',
    '但是': 'nhưng',
    '如果': 'nếu',
    '只要': 'chỉ cần',
    '只有': 'chỉ khi',
    '才': 'mới',
    '已经': 'đã',
    '正在': 'đang',
    '应该': 'nên',
    '必须': 'phải',
    '可能': 'có thể',
    '一定': 'nhất định',
    '突然': 'đột nhiên',
    '还是': 'vẫn',
    '或者': 'hoặc',
    '而且': 'hơn nữa',
    '然后': 'sau đó',
    '最后': 'cuối cùng',
}

SLOT_OVERRIDES = {
    '有': ['V'],
    '好': ['ADJ', 'AN'],
    '家': ['N'],
    '多': ['ADJ', 'AN'],
    '小': ['ADJ', 'AN'],
    '大': ['ADJ', 'AN'],
    '少': ['ADJ', 'AN'],
    '长': ['ADJ', 'AN'],
    '高': ['ADJ', 'AN'],
    '新': ['ADJ', 'AN'],
    '老': ['ADJ', 'AN'],
    '快': ['ADJ', 'AN'],
    '慢': ['ADJ', 'AN'],
    '早': ['ADJ', 'AN'],
    '晚': ['ADJ', 'AN'],
    '开': ['V', 'VO'],
    '问': ['V', 'VO'],
    '帮': ['V', 'VO'],
    '找': ['V', 'VO'],
    '发': ['V', 'VO'],
    '生': ['V', 'ADJ'],
    '进': ['V'],
    '出': ['V'],
    '起': ['V'],
    '行': ['V'],
}

EXCLUDE_SLOT_WORDS = {
    '的', '了', '们', '在', '不', '都', '没', '吗', '就', '吧', '呢', '啊', '把', '被', '比', '从', '给',
    '和', '为', '为了', '因为', '所以', '虽然', '但是', '如果', '只要', '只有', '才', '已经', '正在', '再',
    '又', '还', '也', '很', '非常', '太', '最', '更', '比较', '每', '这', '那', '哪', '什么', '谁',
}

HSK3_CONVERSATIONS = [
    {
        'id': 'conv_hsk3_apartment_repair_01',
        'title': 'Sửa đồ trong nhà',
        'titleZh': '修理家里的东西',
        'titlePinyin': 'Xiūlǐ jiālǐ de dōngxi',
        'description': 'Nói về xử lý đồ bị hỏng trong căn hộ.',
        'level': 3,
        'category': 'home',
        'icon': '🛠️',
        'lines': [
            {'speaker': 'A', 'zh': '厨房的灯坏了，你能帮我看一下吗？', 'pinyin': 'Chúfáng de dēng huài le, nǐ néng bāng wǒ kàn yíxià ma?', 'vi': 'Đèn trong bếp hỏng rồi, bạn giúp tôi xem một chút được không?'},
            {'speaker': 'B', 'zh': '可以。你先把开关关上，比较安全。', 'pinyin': 'Kěyǐ. Nǐ xiān bǎ kāiguān guān shàng, bǐjiào ānquán.', 'vi': 'Được. Bạn tắt công tắc trước, như vậy an toàn hơn.'},
            {'speaker': 'A', 'zh': '这个灯昨天还好好的，今天突然不亮了。', 'pinyin': 'Zhège dēng zuótiān hái hǎohāo de, jīntiān tūrán bú liàng le.', 'vi': 'Cái đèn này hôm qua vẫn bình thường, hôm nay đột nhiên không sáng nữa.'},
            {'speaker': 'B', 'zh': '可能是灯泡被烧坏了，我帮你换一个。', 'pinyin': 'Kěnéng shì dēngpào bèi shāo huài le, wǒ bāng nǐ huàn yí ge.', 'vi': 'Có thể bóng đèn bị cháy rồi, tôi giúp bạn thay một cái.'},
            {'speaker': 'A', 'zh': '太好了，修好以后我请你喝茶。', 'pinyin': 'Tài hǎo le, xiū hǎo yǐhòu wǒ qǐng nǐ hē chá.', 'vi': 'Tốt quá, sửa xong tôi mời bạn uống trà.'},
        ],
        'vocabulary': [
            {'zh': '厨房', 'pinyin': 'chúfáng', 'vi': 'nhà bếp', 'pos': 'danh từ'},
            {'zh': '安全', 'pinyin': 'ānquán', 'vi': 'an toàn', 'pos': 'tính từ'},
            {'zh': '突然', 'pinyin': 'tūrán', 'vi': 'đột nhiên', 'pos': 'trạng từ'},
            {'zh': '修好', 'pinyin': 'xiū hǎo', 'vi': 'sửa xong', 'pos': 'động từ'},
        ],
        'relatedGrammar': ['g_ba', 'g_bei', 'g_result_complement'],
    },
    {
        'id': 'conv_hsk3_work_meeting_01',
        'title': 'Chuẩn bị cuộc họp',
        'titleZh': '准备会议',
        'titlePinyin': 'Zhǔnbèi huìyì',
        'description': 'Trao đổi công việc trước cuộc họp.',
        'level': 3,
        'category': 'work',
        'icon': '💼',
        'lines': [
            {'speaker': 'A', 'zh': '经理让我们下午三点开会。', 'pinyin': 'Jīnglǐ ràng wǒmen xiàwǔ sān diǎn kāihuì.', 'vi': 'Quản lý bảo chúng ta họp lúc ba giờ chiều.'},
            {'speaker': 'B', 'zh': '我已经把报告准备好了。', 'pinyin': 'Wǒ yǐjīng bǎ bàogào zhǔnbèi hǎo le.', 'vi': 'Tôi đã chuẩn bị xong báo cáo rồi.'},
            {'speaker': 'A', 'zh': '虽然时间不多，但是内容一定要清楚。', 'pinyin': 'Suīrán shíjiān bù duō, dànshì nèiróng yídìng yào qīngchu.', 'vi': 'Tuy thời gian không nhiều, nhưng nội dung nhất định phải rõ ràng.'},
            {'speaker': 'B', 'zh': '如果大家有问题，可以会后再讨论。', 'pinyin': 'Rúguǒ dàjiā yǒu wèntí, kěyǐ huì hòu zài tǎolùn.', 'vi': 'Nếu mọi người có câu hỏi, có thể thảo luận sau cuộc họp.'},
            {'speaker': 'A', 'zh': '好的，我先把重点写在白板上。', 'pinyin': 'Hǎo de, wǒ xiān bǎ zhòngdiǎn xiě zài báibǎn shàng.', 'vi': 'Được, tôi viết các điểm chính lên bảng trước.'},
        ],
        'vocabulary': [
            {'zh': '经理', 'pinyin': 'jīnglǐ', 'vi': 'quản lý', 'pos': 'danh từ'},
            {'zh': '报告', 'pinyin': 'bàogào', 'vi': 'báo cáo', 'pos': 'danh từ'},
            {'zh': '内容', 'pinyin': 'nèiróng', 'vi': 'nội dung', 'pos': 'danh từ'},
            {'zh': '讨论', 'pinyin': 'tǎolùn', 'vi': 'thảo luận', 'pos': 'động từ'},
        ],
        'relatedGrammar': ['g_ba', 'g_suiran_danshi', 'g_ruguo'],
    },
    {
        'id': 'conv_hsk3_return_item_01',
        'title': 'Đổi trả hàng',
        'titleZh': '退换商品',
        'titlePinyin': 'Tuìhuàn shāngpǐn',
        'description': 'Nói chuyện ở cửa hàng khi sản phẩm có vấn đề.',
        'level': 3,
        'category': 'shopping',
        'icon': '🧾',
        'lines': [
            {'speaker': 'A', 'zh': '这件衣服我昨天刚买，但是有点儿小。', 'pinyin': 'Zhè jiàn yīfu wǒ zuótiān gāng mǎi, dànshì yǒudiǎnr xiǎo.', 'vi': 'Cái áo này tôi mới mua hôm qua, nhưng hơi nhỏ.'},
            {'speaker': 'B', 'zh': '只要没有被穿过，就可以换。', 'pinyin': 'Zhǐyào méiyǒu bèi chuān guo, jiù kěyǐ huàn.', 'vi': 'Chỉ cần chưa bị mặc qua thì có thể đổi.'},
            {'speaker': 'A', 'zh': '我没有穿，只是在家试了一下。', 'pinyin': 'Wǒ méiyǒu chuān, zhǐ shì zài jiā shì le yíxià.', 'vi': 'Tôi chưa mặc, chỉ thử ở nhà một chút.'},
            {'speaker': 'B', 'zh': '那我帮您找一件大一点儿的。', 'pinyin': 'Nà wǒ bāng nín zhǎo yí jiàn dà yìdiǎnr de.', 'vi': 'Vậy tôi giúp anh/chị tìm một cái lớn hơn một chút.'},
            {'speaker': 'A', 'zh': '谢谢，如果颜色一样就更好了。', 'pinyin': 'Xièxie, rúguǒ yánsè yíyàng jiù gèng hǎo le.', 'vi': 'Cảm ơn, nếu màu giống nhau thì càng tốt.'},
        ],
        'vocabulary': [
            {'zh': '商品', 'pinyin': 'shāngpǐn', 'vi': 'hàng hóa', 'pos': 'danh từ'},
            {'zh': '换', 'pinyin': 'huàn', 'vi': 'đổi', 'pos': 'động từ'},
            {'zh': '试', 'pinyin': 'shì', 'vi': 'thử', 'pos': 'động từ'},
            {'zh': '颜色', 'pinyin': 'yánsè', 'vi': 'màu sắc', 'pos': 'danh từ'},
        ],
        'relatedGrammar': ['g_zhiyou_cai', 'g_bei', 'g_ruguo'],
    },
    {
        'id': 'conv_hsk3_trip_delay_01',
        'title': 'Chuyến đi bị trễ',
        'titleZh': '旅行延误',
        'titlePinyin': 'Lǚxíng yánwù',
        'description': 'Xử lý tình huống tàu xe bị trễ khi đi du lịch.',
        'level': 3,
        'category': 'travel',
        'icon': '🚆',
        'lines': [
            {'speaker': 'A', 'zh': '火车晚点了，我们可能赶不上下午的活动。', 'pinyin': 'Huǒchē wǎndiǎn le, wǒmen kěnéng gǎn bu shàng xiàwǔ de huódòng.', 'vi': 'Tàu trễ rồi, có thể chúng ta không kịp hoạt động buổi chiều.'},
            {'speaker': 'B', 'zh': '别着急，我先给导游打个电话。', 'pinyin': 'Bié zháojí, wǒ xiān gěi dǎoyóu dǎ ge diànhuà.', 'vi': 'Đừng sốt ruột, tôi gọi điện cho hướng dẫn viên trước.'},
            {'speaker': 'A', 'zh': '如果活动被取消，我们可以明天再去。', 'pinyin': 'Rúguǒ huódòng bèi qǔxiāo, wǒmen kěyǐ míngtiān zài qù.', 'vi': 'Nếu hoạt động bị hủy, chúng ta có thể đi lại vào ngày mai.'},
            {'speaker': 'B', 'zh': '对，而且今天我们可以在附近休息。', 'pinyin': 'Duì, érqiě jīntiān wǒmen kěyǐ zài fùjìn xiūxi.', 'vi': 'Đúng, hơn nữa hôm nay chúng ta có thể nghỉ gần đây.'},
            {'speaker': 'A', 'zh': '只要大家安全，晚一点儿也没关系。', 'pinyin': 'Zhǐyào dàjiā ānquán, wǎn yìdiǎnr yě méi guānxi.', 'vi': 'Chỉ cần mọi người an toàn, muộn một chút cũng không sao.'},
        ],
        'vocabulary': [
            {'zh': '晚点', 'pinyin': 'wǎndiǎn', 'vi': 'trễ giờ', 'pos': 'động từ'},
            {'zh': '活动', 'pinyin': 'huódòng', 'vi': 'hoạt động', 'pos': 'danh từ'},
            {'zh': '取消', 'pinyin': 'qǔxiāo', 'vi': 'hủy', 'pos': 'động từ'},
            {'zh': '附近', 'pinyin': 'fùjìn', 'vi': 'gần đây', 'pos': 'danh từ'},
        ],
        'relatedGrammar': ['g_ruguo', 'g_bei', 'g_zhiyao_jiu'],
    },
    {
        'id': 'conv_hsk3_clinic_appointment_01',
        'title': 'Đặt lịch khám',
        'titleZh': '预约看病',
        'titlePinyin': 'Yùyuē kànbìng',
        'description': 'Trao đổi với phòng khám về triệu chứng và lịch hẹn.',
        'level': 3,
        'category': 'health',
        'icon': '🏥',
        'lines': [
            {'speaker': 'A', 'zh': '您好，我想预约明天上午看医生。', 'pinyin': 'Nínhǎo, wǒ xiǎng yùyuē míngtiān shàngwǔ kàn yīshēng.', 'vi': 'Xin chào, tôi muốn đặt lịch khám bác sĩ sáng mai.'},
            {'speaker': 'B', 'zh': '请问您哪里不舒服？', 'pinyin': 'Qǐngwèn nín nǎlǐ bù shūfu?', 'vi': 'Xin hỏi anh/chị khó chịu ở đâu?'},
            {'speaker': 'A', 'zh': '我从昨天开始头疼，而且有点儿发烧。', 'pinyin': 'Wǒ cóng zuótiān kāishǐ tóuténg, érqiě yǒudiǎnr fāshāo.', 'vi': 'Tôi bắt đầu đau đầu từ hôm qua, hơn nữa hơi sốt.'},
            {'speaker': 'B', 'zh': '如果发烧比较严重，您应该早点儿来。', 'pinyin': 'Rúguǒ fāshāo bǐjiào yánzhòng, nín yīnggāi zǎodiǎnr lái.', 'vi': 'Nếu sốt khá nặng, anh/chị nên đến sớm hơn.'},
            {'speaker': 'A', 'zh': '好的，我把身份证也带上。', 'pinyin': 'Hǎo de, wǒ bǎ shēnfènzhèng yě dài shàng.', 'vi': 'Được, tôi cũng sẽ mang theo giấy tờ tùy thân.'},
        ],
        'vocabulary': [
            {'zh': '预约', 'pinyin': 'yùyuē', 'vi': 'đặt lịch', 'pos': 'động từ'},
            {'zh': '头疼', 'pinyin': 'tóuténg', 'vi': 'đau đầu', 'pos': 'động từ'},
            {'zh': '发烧', 'pinyin': 'fāshāo', 'vi': 'sốt', 'pos': 'động từ'},
            {'zh': '严重', 'pinyin': 'yánzhòng', 'vi': 'nghiêm trọng', 'pos': 'tính từ'},
        ],
        'relatedGrammar': ['g_cong_kaishi', 'g_ruguo', 'g_ba'],
    },
    {
        'id': 'conv_hsk3_study_plan_01',
        'title': 'Kế hoạch học tập',
        'titleZh': '学习计划',
        'titlePinyin': 'Xuéxí jìhuà',
        'description': 'Lập kế hoạch học và ôn tập trước kỳ thi.',
        'level': 3,
        'category': 'study',
        'icon': '📚',
        'lines': [
            {'speaker': 'A', 'zh': '下个月就考试了，你复习得怎么样？', 'pinyin': 'Xià ge yuè jiù kǎoshì le, nǐ fùxí de zěnmeyàng?', 'vi': 'Tháng sau thi rồi, bạn ôn tập thế nào?'},
            {'speaker': 'B', 'zh': '我每天复习一个小时，但是听力还是比较难。', 'pinyin': 'Wǒ měitiān fùxí yí ge xiǎoshí, dànshì tīnglì háishì bǐjiào nán.', 'vi': 'Mỗi ngày tôi ôn một tiếng, nhưng nghe vẫn khá khó.'},
            {'speaker': 'A', 'zh': '你可以一边听录音，一边跟着读。', 'pinyin': 'Nǐ kěyǐ yìbiān tīng lùyīn, yìbiān gēnzhe dú.', 'vi': 'Bạn có thể vừa nghe ghi âm vừa đọc theo.'},
            {'speaker': 'B', 'zh': '这个方法不错，我今天就开始试试。', 'pinyin': 'Zhège fāngfǎ búcuò, wǒ jīntiān jiù kāishǐ shìshi.', 'vi': 'Cách này không tệ, hôm nay tôi sẽ bắt đầu thử.'},
            {'speaker': 'A', 'zh': '只要坚持练习，成绩一定会提高。', 'pinyin': 'Zhǐyào jiānchí liànxí, chéngjì yídìng huì tígāo.', 'vi': 'Chỉ cần kiên trì luyện tập, điểm số nhất định sẽ tăng.'},
        ],
        'vocabulary': [
            {'zh': '复习', 'pinyin': 'fùxí', 'vi': 'ôn tập', 'pos': 'động từ'},
            {'zh': '听力', 'pinyin': 'tīnglì', 'vi': 'nghe hiểu', 'pos': 'danh từ'},
            {'zh': '方法', 'pinyin': 'fāngfǎ', 'vi': 'phương pháp', 'pos': 'danh từ'},
            {'zh': '提高', 'pinyin': 'tígāo', 'vi': 'nâng cao', 'pos': 'động từ'},
        ],
        'relatedGrammar': ['g_yibian_yibian', 'g_zhiyao_jiu', 'g_de_comp'],
    },
    {
        'id': 'conv_hsk3_family_decision_01',
        'title': 'Quyết định cuối tuần',
        'titleZh': '周末的决定',
        'titlePinyin': 'Zhōumò de juédìng',
        'description': 'Gia đình bàn kế hoạch cuối tuần.',
        'level': 3,
        'category': 'family',
        'icon': '👨‍👩‍👧',
        'lines': [
            {'speaker': 'A', 'zh': '这个周末我们去看爷爷奶奶吧。', 'pinyin': 'Zhège zhōumò wǒmen qù kàn yéye nǎinai ba.', 'vi': 'Cuối tuần này chúng ta đi thăm ông bà nhé.'},
            {'speaker': 'B', 'zh': '好啊，不过孩子还有作业没做完。', 'pinyin': 'Hǎo a, búguò háizi hái yǒu zuòyè méi zuò wán.', 'vi': 'Được, nhưng con vẫn còn bài tập chưa làm xong.'},
            {'speaker': 'A', 'zh': '那我们让他今天晚上先把作业做完。', 'pinyin': 'Nà wǒmen ràng tā jīntiān wǎnshang xiān bǎ zuòyè zuò wán.', 'vi': 'Vậy tối nay chúng ta để con làm xong bài tập trước.'},
            {'speaker': 'B', 'zh': '如果明天下雨，我们就开车去。', 'pinyin': 'Rúguǒ míngtiān xiàyǔ, wǒmen jiù kāichē qù.', 'vi': 'Nếu ngày mai trời mưa, chúng ta sẽ lái xe đi.'},
            {'speaker': 'A', 'zh': '可以，别忘了给他们带点儿水果。', 'pinyin': 'Kěyǐ, bié wàng le gěi tāmen dài diǎnr shuǐguǒ.', 'vi': 'Được, đừng quên mang cho họ ít trái cây.'},
        ],
        'vocabulary': [
            {'zh': '周末', 'pinyin': 'zhōumò', 'vi': 'cuối tuần', 'pos': 'danh từ'},
            {'zh': '决定', 'pinyin': 'juédìng', 'vi': 'quyết định', 'pos': 'danh từ'},
            {'zh': '作业', 'pinyin': 'zuòyè', 'vi': 'bài tập', 'pos': 'danh từ'},
            {'zh': '忘', 'pinyin': 'wàng', 'vi': 'quên', 'pos': 'động từ'},
        ],
        'relatedGrammar': ['g_ba', 'g_ruguo', 'g_bie_negation'],
    },
    {
        'id': 'conv_hsk3_service_complaint_01',
        'title': 'Phản ánh dịch vụ',
        'titleZh': '反映服务问题',
        'titlePinyin': 'Fǎnyìng fúwù wèntí',
        'description': 'Khách hàng phản ánh vấn đề dịch vụ một cách lịch sự.',
        'level': 3,
        'category': 'service',
        'icon': '☎️',
        'lines': [
            {'speaker': 'A', 'zh': '您好，我想反映一个服务问题。', 'pinyin': 'Nínhǎo, wǒ xiǎng fǎnyìng yí ge fúwù wèntí.', 'vi': 'Xin chào, tôi muốn phản ánh một vấn đề dịch vụ.'},
            {'speaker': 'B', 'zh': '请您慢慢说，我来帮您记录。', 'pinyin': 'Qǐng nín mànman shuō, wǒ lái bāng nín jìlù.', 'vi': 'Xin anh/chị nói từ từ, tôi sẽ ghi lại giúp anh/chị.'},
            {'speaker': 'A', 'zh': '我昨天订的房间被安排错了。', 'pinyin': 'Wǒ zuótiān dìng de fángjiān bèi ānpái cuò le.', 'vi': 'Phòng tôi đặt hôm qua bị sắp xếp nhầm.'},
            {'speaker': 'B', 'zh': '非常抱歉，我们马上帮您解决。', 'pinyin': 'Fēicháng bàoqiàn, wǒmen mǎshàng bāng nín jiějué.', 'vi': 'Rất xin lỗi, chúng tôi sẽ giúp anh/chị giải quyết ngay.'},
            {'speaker': 'A', 'zh': '谢谢，只要今天能换好就可以。', 'pinyin': 'Xièxie, zhǐyào jīntiān néng huàn hǎo jiù kěyǐ.', 'vi': 'Cảm ơn, chỉ cần hôm nay đổi xong là được.'},
        ],
        'vocabulary': [
            {'zh': '反映', 'pinyin': 'fǎnyìng', 'vi': 'phản ánh', 'pos': 'động từ'},
            {'zh': '服务', 'pinyin': 'fúwù', 'vi': 'dịch vụ', 'pos': 'danh từ'},
            {'zh': '安排', 'pinyin': 'ānpái', 'vi': 'sắp xếp', 'pos': 'động từ'},
            {'zh': '解决', 'pinyin': 'jiějué', 'vi': 'giải quyết', 'pos': 'động từ'},
        ],
        'relatedGrammar': ['g_bei', 'g_zhiyao_jiu', 'g_de_attr'],
    },
]

for conversation in HSK3_CONVERSATIONS:
    conversation['speakers'] = [
        {'code': 'A', 'nameVi': 'An', 'role': 'Người nói A', 'avatarColor': '#3F51B5'},
        {'code': 'B', 'nameVi': 'Bình', 'role': 'Người nói B', 'avatarColor': '#009688'},
    ]
    conversation['cultureTip'] = 'Bridge HSK3 conversation được curate để luyện grammar/vocab HSK3 trong ngữ cảnh đời sống.'
    conversation['isBookmarked'] = False
    conversation['isMastered'] = False


def load_json(path):
    return json.loads(path.read_text(encoding='utf-8'))


def write_json(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def apply_vi_short_curations():
    seed = load_json(VI_SEED_FILE)['items']
    items = []
    for item in seed:
        override = VI_OVERRIDES.get(item['hanzi'], item['current_vi_short'])
        items.append({**item, 'override_vi_short': override})
    write_json(VI_CURATED_FILE, {
        'version': '1.0',
        'generated_at': '2026-04-27',
        'scope': 'Curated vi_short overrides for top-frequency HSK1-HSK3 vocab seed.',
        'items': items,
    })


def apply_slot_curations():
    seed = load_json(SLOT_SEED_FILE)['items']
    items = []
    for item in seed:
        hanzi = item['hanzi']
        if hanzi in SLOT_OVERRIDES:
            slots = SLOT_OVERRIDES[hanzi]
            note = 'Curated slot override.'
        elif hanzi in EXCLUDE_SLOT_WORDS:
            slots = []
            note = 'Function word; exclude from generator content slots.'
        else:
            slots = []
            note = 'Needs manual review before using as generator slot.'
        items.append({**item, 'suggested_slots': slots, 'note': note})
    write_json(SLOT_CURATED_FILE, {
        'version': '1.0',
        'generated_at': '2026-04-27',
        'scope': 'Curated slot compatibility overrides for top HSK1-HSK3 seed items.',
        'items': items,
    })


def append_hsk3_conversations():
    conversations = load_json(CONVERSATION_FILE)
    existing = {item['id'] for item in conversations}
    added = 0
    for conversation in HSK3_CONVERSATIONS:
        if conversation['id'] not in existing:
            conversations.append(conversation)
            added += 1
    write_json(CONVERSATION_FILE, conversations)
    return added


def main():
    apply_vi_short_curations()
    apply_slot_curations()
    added = append_hsk3_conversations()
    print(f'wrote {VI_CURATED_FILE.relative_to(ROOT)}')
    print(f'wrote {SLOT_CURATED_FILE.relative_to(ROOT)}')
    print(f'appended {added} HSK3 conversations to {CONVERSATION_FILE.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
