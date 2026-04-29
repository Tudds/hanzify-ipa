# Missing learning data — HSK1-HSK3

Ngày audit: 2026-04-27

## Đã bổ sung bằng script

- Metadata file: `assets/data/generated/learning_metadata_hsk1_3.json`
- HSK3 bridge file: `assets/data/generated/hsk3_bridge_modules.json`
- VI curation seed: `assets/data/generated/vi_short_overrides_seed_hsk1_3.json`
- VI curated overrides: `assets/data/generated/vi_short_overrides_curated_hsk1_3.json`
- Slot curation seed: `assets/data/generated/slot_compatibility_seed_hsk1_3.json`
- Slot curated overrides: `assets/data/generated/slot_compatibility_curated_hsk1_3.json`
- Collocation gap candidates: `assets/data/generated/collocation_gap_candidates_hsk1_3.json`
- `canonical_key` cho vocab HSK1-HSK3.
- `frequency_count` và `frequency_rank` từ vocab examples + grammar examples + conversations.
- `slot_compatibility` suy ra tối thiểu từ `wordType`.
- `vocab_grammar_links` suy từ việc vocab xuất hiện trong grammar examples.
- `vi_short` lấy nghĩa Việt ngắn đầu tiên.
- `has_collocations` để audit coverage generator on-demand.
- `7` HSK3 bridge modules từ HSK3 grammar examples + HSK2 conversation context.
- `121` curated `vi_short` overrides đã apply vào metadata.
- `120` curated slot overrides đã apply vào metadata.
- `160` verb/adj candidates cần bổ sung collocation nếu muốn làm generator head.

## Coverage hiện tại

| Level | Vocab | Có collocation head | Thiếu collocation head | Grammar | Conversation | Frames |
|---|---:|---:|---:|---:|---:|---:|
| HSK1 | 509 | 69 | 440 | 24 | 10 | 10 |
| HSK2 | 936 | 111 | 825 | 31 | 8 | 15 |
| HSK3 | 1153 | 194 | 959 | 25 | 11 | 10 |

## Thiếu cần bổ sung tiếp

1. HSK3 conversation đã tăng lên 11 hội thoại; bridge module vẫn giữ để phủ grammar còn thiếu context.
   - Đã tạo `assets/data/generated/hsk3_bridge_modules.json` để dùng tạm cho grammar chưa có hội thoại phù hợp.
2. Các vocab `has_collocations=false` chưa generate được bằng CollocationsDB head hiện tại.
   - Đã tạo `assets/data/generated/collocation_gap_candidates_hsk1_3.json` cho các verb/adj ưu tiên bổ sung partner.
3. `vi_short` là auto-derived, cần curate thủ công cho các từ/câu hay dùng nếu bản dịch gượng.
   - Đã tạo `assets/data/generated/vi_short_overrides_curated_hsk1_3.json` và apply 121 overrides vào metadata.
4. `slot_compatibility` là rule tối thiểu theo POS, chưa phải semantic constraint đầy đủ.
   - Đã tạo `assets/data/generated/slot_compatibility_curated_hsk1_3.json` và apply 120 overrides vào metadata.

## Sample vocab thiếu collocation head

### HSK1

八, 爸爸, 杯子, 北京, 本, 不, 不客气, 菜, 茶, 出租车, 打电话, 的, 点, 电脑, 电视, 电影, 东西, 都, 对不起, 多, 多少, 儿子, 二, 饭店, 飞机, 分钟, 狗, 汉语, 好吃, 号, 和, 很, 后面, 回, 会, 几, 家, 叫, 今天, 九, 开, 看见, 块, 老师, 了, 冷, 里, 六, 妈妈, 吗, 猫, 没关系, 米饭, 明天, 名字, 哪, 哪儿, 那, 呢, 能, 你, 你好, 年, 女儿, 朋友, 苹果, 七, 钱, 前面, 热, 人, 认识, 日, 三, 商店, 上午, 谁, 什么, 生日, 十

### HSK2

啊, 阿姨, 矮, 爱好, 把, 班, 半, 包, 饱, 北方, 被, 鼻子, 比, 比较, 比赛, 必须, 变化, 别, 别人, 宾馆, 冰箱, 不但, 才, 草, 层, 差, 长, 唱歌, 超市, 衬衫, 城市, 迟到, 除了, 船, 春, 词典, 从, 错, 打篮球, 担心, 蛋糕, 当然, 地, 地方, 地铁, 地图, 弟弟, 第一, 电梯, 电子邮件, 东, 冬, 动物, 短, 段, 饿, 耳朵, 发现, 方便, 放心, 分, 附近, 刚才, 更, 公共汽车, 公司, 公园, 故事, 刮风, 关系, 过去, 还是, 好像, 号码, 黑板, 花, 画, 坏, 环境, 换

### HSK3

爱情, 安全, 按时, 按照, 百, 棒, 抱歉, 倍, 本来, 笔记本, 表演, 冰, 不得不, 不管, 不过, 不仅, 部分, 猜, 材料, 菜单, 参观, 厕所, 曾经, 叉子, 产品, 长途, 超过, 吃惊, 重新, 出发, 出现, 厨房, 传统, 窗户, 词语, 打折, 大概, 大使馆, 大约, 单独, 当时, 导游, 得到, 灯, 低, 底, 点心, 掉, 定, 丢, 动作, 肚子, 堆, 对面, 而且, 法律, 方法, 方面, 方向, 放弃, 非常, 风景, 服务, 父母, 感情, 感兴趣, 各, 跟, 工资, 顾客, 管理, 光, 广告, 规定, 国际, 过程, 海, 喊, 行, 好处
