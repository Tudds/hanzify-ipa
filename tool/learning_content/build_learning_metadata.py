#!/usr/bin/env python3
import json
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'assets' / 'data'
GENERATED = DATA / 'generated'
DOCS_PROGRESS = ROOT / 'docs' / 'progress'

VOCAB_FILES = [DATA / f'hsk{level}.json' for level in (1, 2, 3)]
GRAMMAR_FILES = [DATA / f'grammar_hsk{level}.json' for level in (1, 2, 3)]
CONVERSATION_FILE = DATA / 'conversation.json'
COLLOCATIONS_DB_FILE = GENERATED / 'collocations_db.json'
FRAMES_BANK_FILE = GENERATED / 'frames_bank.json'
METADATA_FILE = GENERATED / 'learning_metadata_hsk1_3.json'
HSK3_BRIDGE_FILE = GENERATED / 'hsk3_bridge_modules.json'
VI_SHORT_SEED_FILE = GENERATED / 'vi_short_overrides_seed_hsk1_3.json'
SLOT_SEED_FILE = GENERATED / 'slot_compatibility_seed_hsk1_3.json'
COLLOCATION_GAP_FILE = GENERATED / 'collocation_gap_candidates_hsk1_3.json'
VI_SHORT_CURATED_FILE = GENERATED / 'vi_short_overrides_curated_hsk1_3.json'
SLOT_CURATED_FILE = GENERATED / 'slot_compatibility_curated_hsk1_3.json'
REPORT_FILE = DOCS_PROGRESS / 'missing_learning_data_2026-04-27.md'
FUNCTION_WORDS = {
    '的', '了', '着', '过', '吗', '呢', '吧', '啊', '把', '被', '比', '从', '对', '跟', '给', '和', '或', '及',
    '在', '为', '为了', '因为', '所以', '但是', '可是', '不过', '虽然', '如果', '要是', '只要', '只有',
    '才', '就', '都', '也', '还', '再', '又', '很', '非常', '太', '最', '更', '比较', '不', '没', '没有',
}


def load_json(path):
    return json.loads(path.read_text(encoding='utf-8'))


def load_override_map(path, value_key):
    if not path.exists():
        return {}
    data = load_json(path)
    overrides = {}
    for item in data.get('items', []):
        value = item.get(value_key)
        if value or value == []:
            overrides[item['id']] = value
    return overrides


def vi_short(entry):
    meanings = entry.get('meanings') or []
    raw = meanings[0].get('vi', '') if meanings else ''
    for sep in [',', '/', '；', ';', '(']:
        raw = raw.split(sep)[0]
    return raw.strip()


def canonical_key(entry):
    pinyin = entry.get('pinyin') or entry.get('pinyinNormalized') or ''
    return f"{entry['hanzi']}_{pinyin}".replace(' ', '_')


def slot_compatibility(entry):
    pos = entry.get('wordType') or ((entry.get('meanings') or [{}])[0].get('pos')) or ''
    slots = []
    if pos.startswith('v'):
        slots += ['V', 'VO']
    if pos in {'adj', 'a'} or pos.startswith('adj'):
        slots += ['ADJ', 'AN']
    if pos.startswith('n') or pos in {'pron', 'time', 'place'}:
        slots += ['N']
    if pos in {'mw', 'm', 'measure'}:
        slots += ['MW']
    return slots


def sentence_texts_from_conversation(conversations):
    texts = []
    for conv in conversations:
        for key in ['lines', 'dialogue', 'sentences']:
            for line in conv.get(key, []) or []:
                if isinstance(line, dict):
                    value = line.get('zh') or line.get('cn') or line.get('textCn') or line.get('text')
                    if value:
                        texts.append(value)
                elif isinstance(line, str):
                    texts.append(line)
    return texts


def grammar_examples(grammar):
    for item in grammar:
        for example in item.get('examples', []) or []:
            yield item, example.get('zh') or example.get('cn') or ''


def build_frequency(vocab, grammar, conversations):
    corpus = []
    for item in vocab:
        corpus.extend(ex.get('cn') or ex.get('zh') or '' for ex in item.get('exampleSentences', []) or [])
    for _, text in grammar_examples(grammar):
        corpus.append(text)
    corpus.extend(sentence_texts_from_conversation(conversations))
    full_text = '\n'.join(corpus)
    counts = Counter()
    for item in vocab:
        counts[item['id']] = full_text.count(item['hanzi'])
    ranked = {item_id: rank for rank, (item_id, _) in enumerate(counts.most_common(), start=1)}
    return counts, ranked


def build_vocab_grammar_links(vocab, grammar):
    links = defaultdict(list)
    grammar_examples_by_id = defaultdict(str)
    for grammar_item, text in grammar_examples(grammar):
        grammar_examples_by_id[grammar_item['id']] += text
    for item in vocab:
        hanzi = item['hanzi']
        for grammar_id, examples in grammar_examples_by_id.items():
            if hanzi in examples:
                links[item['id']].append(grammar_id)
    return {key: value for key, value in links.items() if value}


def collocation_coverage(vocab, collocations_db):
    covered_heads = set()
    for section in ['verb_object', 'adj_noun', 'measure_noun']:
        covered_heads.update(collocations_db.get(section, {}).keys())
    return {item['id']: item['hanzi'] in covered_heads for item in vocab}


def frame_coverage_by_level(frames_bank):
    counter = Counter(frame['hsk_level_min'] for frame in frames_bank.get('frames', []))
    return {str(level): counter[level] for level in (1, 2, 3)}


def build_hsk3_bridge_modules(grammar_by_level, conversations):
    hsk2_conversations = [conv for conv in conversations if (conv.get('hskLevel') or conv.get('level')) == 2]
    hsk3_grammar = grammar_by_level[3]
    modules = []
    chunk_size = 4
    for index in range(0, len(hsk3_grammar), chunk_size):
        grammar_chunk = hsk3_grammar[index:index + chunk_size]
        source_conv = hsk2_conversations[(index // chunk_size) % len(hsk2_conversations)] if hsk2_conversations else None
        modules.append({
            'id': f'hsk3_bridge_{index // chunk_size + 1:02d}',
            'level': 3,
            'type': 'bridge_module',
            'title': f'HSK3 bridge {index // chunk_size + 1}',
            'sourceConversationIds': [source_conv['id']] if source_conv else [],
            'grammarIds': [item['id'] for item in grammar_chunk],
            'exampleSentences': [
                {
                    'grammarId': item['id'],
                    'zh': example.get('zh') or example.get('cn') or '',
                    'pinyin': example.get('pinyin') or '',
                    'vi': example.get('vi') or '',
                }
                for item in grammar_chunk
                for example in (item.get('examples') or [])[:2]
            ],
            'note': 'Bridge module dùng HSK2 conversation làm context và HSK3 grammar examples làm câu validated.',
        })
    return {
        'version': '1.0',
        'generated_at': '2026-04-27',
        'scope': 'Temporary HSK3 bridge content until more HSK3 conversations are curated.',
        'modules': modules,
    }


def build_curation_seeds(vocab_metadata):
    vi_short = []
    slot_seed = []
    collocation_gap = []
    for item in sorted(vocab_metadata, key=lambda row: (-row['frequency_count'], row['level'], row['hanzi'])):
        if len(vi_short) < 120 and item['vi_short']:
            vi_short.append({
                'id': item['id'],
                'hanzi': item['hanzi'],
                'level': item['level'],
                'current_vi_short': item['vi_short'],
                'override_vi_short': '',
            })
        if len(slot_seed) < 120 and not item['slot_compatibility']:
            slot_seed.append({
                'id': item['id'],
                'hanzi': item['hanzi'],
                'level': item['level'],
                'suggested_slots': [],
                'note': 'Điền thủ công nếu từ này cần tham gia generator/challenge slot.',
            })
        if (
            len(collocation_gap) < 160
            and not item['has_collocations']
            and item['hanzi'] not in FUNCTION_WORDS
            and any(slot in item['slot_compatibility'] for slot in ['V', 'VO', 'ADJ', 'AN'])
        ):
            collocation_gap.append({
                'id': item['id'],
                'hanzi': item['hanzi'],
                'level': item['level'],
                'slot_compatibility': item['slot_compatibility'],
                'frequency_count': item['frequency_count'],
                'needed': 'Add collocation partners if this word should be a generator head.',
            })
    return vi_short, slot_seed, collocation_gap


def main():
    vi_short_overrides = load_override_map(VI_SHORT_CURATED_FILE, 'override_vi_short')
    slot_overrides = load_override_map(SLOT_CURATED_FILE, 'suggested_slots')

    vocab = []
    by_level = defaultdict(list)
    for path in VOCAB_FILES:
        items = load_json(path)
        vocab.extend(items)
        for item in items:
            by_level[item['level']].append(item)

    grammar = []
    grammar_by_level = defaultdict(list)
    for path in GRAMMAR_FILES:
        items = load_json(path)
        grammar.extend(items)
        for item in items:
            grammar_by_level[item['level']].append(item)

    conversations = load_json(CONVERSATION_FILE)
    conversation_counts = Counter(conv.get('hskLevel') or conv.get('level') for conv in conversations)
    collocations_db = load_json(COLLOCATIONS_DB_FILE)
    frames_bank = load_json(FRAMES_BANK_FILE)

    frequency_counts, frequency_ranks = build_frequency(vocab, grammar, conversations)
    links = build_vocab_grammar_links(vocab, grammar)
    coverage = collocation_coverage(vocab, collocations_db)

    vocab_metadata = []
    for item in vocab:
        item_vi_short = vi_short(item)
        item_slots = slot_compatibility(item)
        vocab_metadata.append({
            'id': item['id'],
            'hanzi': item['hanzi'],
            'level': item['level'],
            'canonical_key': canonical_key(item),
            'frequency_count': frequency_counts[item['id']],
            'frequency_rank': frequency_ranks[item['id']],
            'slot_compatibility': slot_overrides.get(item['id'], item_slots),
            'vi_short': vi_short_overrides.get(item['id'], item_vi_short),
            'vocab_grammar_links': links.get(item['id'], []),
            'has_collocations': coverage[item['id']],
        })

    missing_by_level = {}
    for level, items in by_level.items():
        missing = [item for item in items if not coverage[item['id']]]
        missing_by_level[level] = missing

    metadata = {
        'version': '1.0',
        'generated_at': '2026-04-27',
        'scope': 'HSK1-HSK3 learning metadata; source vocab files are not modified.',
        'summary': {
            'vocab_count': len(vocab),
            'grammar_count': len(grammar),
            'conversation_counts': {str(k): conversation_counts[k] for k in sorted(conversation_counts)},
            'curated_vi_short_count': len(vi_short_overrides),
            'curated_slot_count': len(slot_overrides),
            'frame_counts': frame_coverage_by_level(frames_bank),
            'collocation_coverage': {
                str(level): {
                    'covered': len(by_level[level]) - len(missing_by_level[level]),
                    'total': len(by_level[level]),
                }
                for level in sorted(by_level)
            },
        },
        'vocab': vocab_metadata,
    }
    GENERATED.mkdir(parents=True, exist_ok=True)
    METADATA_FILE.write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    bridge_modules = build_hsk3_bridge_modules(grammar_by_level, conversations)
    HSK3_BRIDGE_FILE.write_text(json.dumps(bridge_modules, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    vi_short_seed, slot_seed, collocation_gap = build_curation_seeds(vocab_metadata)
    VI_SHORT_SEED_FILE.write_text(json.dumps({
        'version': '1.0',
        'generated_at': '2026-04-27',
        'items': vi_short_seed,
    }, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    SLOT_SEED_FILE.write_text(json.dumps({
        'version': '1.0',
        'generated_at': '2026-04-27',
        'items': slot_seed,
    }, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    COLLOCATION_GAP_FILE.write_text(json.dumps({
        'version': '1.0',
        'generated_at': '2026-04-27',
        'items': collocation_gap,
    }, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    lines = [
        '# Missing learning data — HSK1-HSK3',
        '',
        'Ngày audit: 2026-04-27',
        '',
        '## Đã bổ sung bằng script',
        '',
        f'- Metadata file: `{METADATA_FILE.relative_to(ROOT)}`',
        f'- HSK3 bridge file: `{HSK3_BRIDGE_FILE.relative_to(ROOT)}`',
        f'- VI curation seed: `{VI_SHORT_SEED_FILE.relative_to(ROOT)}`',
        f'- VI curated overrides: `{VI_SHORT_CURATED_FILE.relative_to(ROOT)}`',
        f'- Slot curation seed: `{SLOT_SEED_FILE.relative_to(ROOT)}`',
        f'- Slot curated overrides: `{SLOT_CURATED_FILE.relative_to(ROOT)}`',
        f'- Collocation gap candidates: `{COLLOCATION_GAP_FILE.relative_to(ROOT)}`',
        '- `canonical_key` cho vocab HSK1-HSK3.',
        '- `frequency_count` và `frequency_rank` từ vocab examples + grammar examples + conversations.',
        '- `slot_compatibility` suy ra tối thiểu từ `wordType`.',
        '- `vocab_grammar_links` suy từ việc vocab xuất hiện trong grammar examples.',
        '- `vi_short` lấy nghĩa Việt ngắn đầu tiên.',
        '- `has_collocations` để audit coverage generator on-demand.',
        f'- `{len(bridge_modules["modules"])}` HSK3 bridge modules từ HSK3 grammar examples + HSK2 conversation context.',
        f'- `{len(vi_short_overrides)}` curated `vi_short` overrides đã apply vào metadata.',
        f'- `{len(slot_overrides)}` curated slot overrides đã apply vào metadata.',
        f'- `{len(collocation_gap)}` verb/adj candidates cần bổ sung collocation nếu muốn làm generator head.',
        '',
        '## Coverage hiện tại',
        '',
        '| Level | Vocab | Có collocation head | Thiếu collocation head | Grammar | Conversation | Frames |',
        '|---|---:|---:|---:|---:|---:|---:|',
    ]
    frame_counts = frame_coverage_by_level(frames_bank)
    for level in (1, 2, 3):
        total = len(by_level[level])
        missing = len(missing_by_level[level])
        lines.append(
            f'| HSK{level} | {total} | {total - missing} | {missing} | '
            f'{len(grammar_by_level[level])} | {conversation_counts[level]} | {frame_counts[str(level)]} |'
        )

    lines += [
        '',
        '## Thiếu cần bổ sung tiếp',
        '',
        f'1. HSK3 conversation đã tăng lên {conversation_counts[3]} hội thoại; bridge module vẫn giữ để phủ grammar còn thiếu context.',
        f'   - Đã tạo `{HSK3_BRIDGE_FILE.relative_to(ROOT)}` để dùng tạm cho grammar chưa có hội thoại phù hợp.',
        '2. Các vocab `has_collocations=false` chưa generate được bằng CollocationsDB head hiện tại.',
        f'   - Đã tạo `{COLLOCATION_GAP_FILE.relative_to(ROOT)}` cho các verb/adj ưu tiên bổ sung partner.',
        '3. `vi_short` là auto-derived, cần curate thủ công cho các từ/câu hay dùng nếu bản dịch gượng.',
        f'   - Đã tạo `{VI_SHORT_CURATED_FILE.relative_to(ROOT)}` và apply {len(vi_short_overrides)} overrides vào metadata.',
        '4. `slot_compatibility` là rule tối thiểu theo POS, chưa phải semantic constraint đầy đủ.',
        f'   - Đã tạo `{SLOT_CURATED_FILE.relative_to(ROOT)}` và apply {len(slot_overrides)} overrides vào metadata.',
        '',
        '## Sample vocab thiếu collocation head',
        '',
    ]
    for level in (1, 2, 3):
        sample = ', '.join(item['hanzi'] for item in missing_by_level[level][:80])
        lines += [f'### HSK{level}', '', sample or 'Không có.', '']

    DOCS_PROGRESS.mkdir(parents=True, exist_ok=True)
    REPORT_FILE.write_text('\n'.join(lines), encoding='utf-8')

    print(f'wrote {METADATA_FILE.relative_to(ROOT)}')
    print(f'wrote {HSK3_BRIDGE_FILE.relative_to(ROOT)}')
    print(f'wrote {VI_SHORT_SEED_FILE.relative_to(ROOT)}')
    print(f'wrote {SLOT_SEED_FILE.relative_to(ROOT)}')
    print(f'wrote {COLLOCATION_GAP_FILE.relative_to(ROOT)}')
    print(f'wrote {REPORT_FILE.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
