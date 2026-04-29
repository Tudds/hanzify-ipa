#!/usr/bin/env python3
"""
Phase B — Import HSK1 vocab từ 152 → 500 từ (HSK 2021 standard).

Sources:
  - HSK 2021 list: ivankra/hsk30 on GitHub (hsk30.csv)
  - CC-CEDICT: tool/.cache/cedict.txt.gz (English definitions)
  - Claude API: Vietnamese meanings + example sentences

Usage:
  python3 tool/import_vocab_hsk1.py [--dry-run] [--batch-size N] [--offset N]

  --dry-run     Preview only, no API calls, no file write
  --batch-size  Words per Claude API call (default: 20)
  --offset      Skip first N new words (for resume after interruption)
"""

import json
import sys
import os
import re
import csv
import io
import gzip
import shutil
import urllib.request
from datetime import datetime

DRY_RUN = '--dry-run' in sys.argv
BATCH_SIZE = int(next((sys.argv[i+1] for i, a in enumerate(sys.argv) if a == '--batch-size'), 20))
OFFSET = int(next((sys.argv[i+1] for i, a in enumerate(sys.argv) if a == '--offset'), 0))

DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
CACHE_DIR = os.path.join(os.path.dirname(__file__), '.cache')
HSK30_URL = 'https://raw.githubusercontent.com/ivankra/hsk30/master/hsk30.csv'
HSK30_CACHE = os.path.join(CACHE_DIR, 'hsk30.csv')
CEDICT_CACHE = os.path.join(CACHE_DIR, 'cedict.txt.gz')

os.makedirs(CACHE_DIR, exist_ok=True)

# ── POS mapping ──────────────────────────────────────────────────────────────

POS_MAP = {
    'V': 'v', 'N': 'n', 'Adj': 'adj', 'Adv': 'adv',
    'Num': 'num', 'M': 'mw', 'Pron': 'pron', 'Prep': 'prep',
    'Conj': 'conj', 'Part': 'part', 'Aux': 'aux', 'Int': 'int',
    'Prefix': 'prefix', 'Suffix': 'suffix',
}


def map_pos(pos_str):
    parts = [p.strip() for p in pos_str.replace('/', ',').split(',')]
    for p in parts:
        if p in POS_MAP:
            return POS_MAP[p]
    return 'n'


# ── Pinyin ────────────────────────────────────────────────────────────────────

def normalize_pinyin(pinyin: str) -> str:
    tone_map = str.maketrans(
        'āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜ',
        'aaaaeeeeiiiioooouuuuuuuu'
    )
    return re.sub(r'\s+', '', pinyin.lower().translate(tone_map))


# ── Data loading ──────────────────────────────────────────────────────────────

def load_hsk30():
    if not os.path.exists(HSK30_CACHE):
        print(f'Downloading HSK 2021 list → {HSK30_CACHE}')
        data = urllib.request.urlopen(HSK30_URL, timeout=30).read()
        with open(HSK30_CACHE, 'wb') as f:
            f.write(data)
        print(f'  Downloaded {len(data)//1024} KB')
    else:
        print(f'Using cached HSK 2021 list ({HSK30_CACHE})')

    with open(HSK30_CACHE, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        return list(reader)


def load_cedict():
    CEDICT_RE = re.compile(r'^(\S+)\s+(\S+)\s+\[([^\]]+)\]\s+/(.+)/$')
    cedict = {}
    with gzip.open(CEDICT_CACHE, 'rt', encoding='utf-8') as f:
        for line in f:
            m = CEDICT_RE.match(line)
            if m:
                _, simp, _, defs = m.groups()
                if simp not in cedict:
                    clean_defs = [d for d in defs.split('/') if d and not d.startswith('CL:')]
                    if clean_defs:
                        cedict[simp] = clean_defs
    print(f'Loaded {len(cedict)} CC-CEDICT entries')
    return cedict


def load_existing_hsk1():
    path = os.path.join(DATA_DIR, 'hsk1.json')
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def save_hsk1(data):
    path = os.path.join(DATA_DIR, 'hsk1.json')
    if DRY_RUN:
        print(f'  [dry-run] would write {path} ({len(data)} entries)')
        return
    ts = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup = os.path.join(DATA_DIR + f'_backup_phaseB_{ts}')
    os.makedirs(backup, exist_ok=True)
    shutil.copy(path, os.path.join(backup, 'hsk1.json'))
    print(f'  Backed up to {backup}/hsk1.json')
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f'  ✓ Wrote {path} ({len(data)} entries)')


# ── Claude API batch translation ──────────────────────────────────────────────

def translate_batch(words_batch: list[dict]) -> list[dict]:
    """
    Call Claude API to get Vietnamese meanings + example sentences.
    Input: list of {hanzi, pinyin, pos, en_defs}
    Output: list of {hanzi, vi_meaning, en_meaning, example_cn, example_pinyin, example_vi}
    """
    try:
        import anthropic
    except ImportError:
        print('  ⚠ anthropic package not installed. Run: pip install anthropic')
        sys.exit(1)

    client = anthropic.Anthropic()

    word_lines = []
    for i, w in enumerate(words_batch, 1):
        en = w['en_defs'][0] if w['en_defs'] else 'see context'
        word_lines.append(f'{i}. {w["hanzi"]} ({w["pinyin"]}, {w["pos"]}) — {en}')

    prompt = f"""Dưới đây là {len(words_batch)} từ tiếng Trung HSK1. Với mỗi từ, hãy cung cấp:
1. Nghĩa tiếng Việt ngắn gọn (vi_meaning) — ưu tiên từ thông dụng trong tiếng Việt
2. Nghĩa tiếng Anh ngắn (en_meaning) — 1-3 từ
3. Một câu ví dụ đơn giản (HSK1 level): cn, pinyin (có dấu thanh), vi (dịch tiếng Việt)

Danh sách từ:
{chr(10).join(word_lines)}

Trả lời theo định dạng JSON array CHÍNH XÁC như sau (không có markdown, chỉ JSON thuần):
[
  {{
    "hanzi": "词",
    "vi_meaning": "nghĩa tiếng Việt",
    "en_meaning": "English meaning",
    "example_cn": "例句。",
    "example_pinyin": "Lìjù.",
    "example_vi": "Câu dịch."
  }},
  ...
]

Lưu ý:
- vi_meaning: dùng dấu phẩy để liệt kê nhiều nghĩa (vd: "yêu, thương")
- Câu ví dụ phải đơn giản (≤12 chữ), dùng từ HSK1 khi có thể
- Pinyin câu ví dụ: viết hoa chữ đầu câu, có dấu thanh đầy đủ
"""

    if DRY_RUN:
        print(f'  [dry-run] would call Claude API for {len(words_batch)} words')
        return []

    print(f'  Calling Claude API for {len(words_batch)} words...')
    msg = client.messages.create(
        model='claude-haiku-4-5-20251001',
        max_tokens=4096,
        messages=[{'role': 'user', 'content': prompt}]
    )
    response_text = msg.content[0].text.strip()

    # Parse JSON response
    try:
        # Strip markdown code blocks if present
        if response_text.startswith('```'):
            response_text = re.sub(r'^```[a-z]*\n?', '', response_text)
            response_text = re.sub(r'\n?```$', '', response_text)
        return json.loads(response_text)
    except json.JSONDecodeError as e:
        print(f'  ⚠ JSON parse error: {e}')
        print(f'  Response (first 200 chars): {response_text[:200]}')
        return []


# ── Build entry ───────────────────────────────────────────────────────────────

def build_entry(hanzi: str, pinyin: str, pos: str, translated: dict) -> dict:
    word_type = map_pos(pos)
    return {
        'id': f'hsk1_{hanzi}',
        'hanzi': hanzi,
        'pinyin': pinyin,
        'pinyinNormalized': normalize_pinyin(pinyin),
        'characters': list(hanzi),
        'meanings': [
            {
                'pos': word_type,
                'vi': translated.get('vi_meaning', ''),
                'en': translated.get('en_meaning', ''),
            }
        ],
        'exampleSentences': [
            {
                'cn': translated.get('example_cn', ''),
                'pinyin': translated.get('example_pinyin', ''),
                'vi': translated.get('example_vi', ''),
            }
        ] if translated.get('example_cn') else [],
        'level': 1,
        'wordType': word_type,
    }


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print('=== Phase B — HSK1 vocab import (152 → 500) ===')
    if DRY_RUN:
        print('MODE: dry-run\n')
    else:
        print('MODE: live\n')

    # Load data sources
    hsk30_rows = load_hsk30()
    cedict = load_cedict()
    existing = load_existing_hsk1()
    existing_hanzi = {e['hanzi'] for e in existing}
    print(f'Existing HSK1: {len(existing)} từ')

    # Get HSK1 rows from CSV, primary form only (before '|')
    hsk1_official = []
    for r in hsk30_rows:
        if r['Level'] != '1':
            continue
        simp = r['Simplified'].split('|')[0].strip()
        pinyin = r['Pinyin'].split('|')[0].strip()
        pos = r['POS'].split('|')[0].strip()
        hsk1_official.append((simp, pinyin, pos))

    # Find missing words
    new_words = [(h, p, pos) for h, p, pos in hsk1_official if h not in existing_hanzi]
    print(f'HSK 2021 HSK1: {len(hsk1_official)} từ')
    print(f'Missing (to add): {len(new_words)} từ')

    if OFFSET:
        print(f'Offset: skipping first {OFFSET} words')
        new_words = new_words[OFFSET:]

    print(f'Processing: {len(new_words)} từ (batch_size={BATCH_SIZE})\n')

    if DRY_RUN:
        print('Sample words to add:')
        for h, p, pos in new_words[:10]:
            en = cedict.get(h, ['(no CEDICT)'])[0][:60]
            print(f'  {h} ({p}, {pos}) — {en}')
        print(f'  ... and {len(new_words)-10} more')
        return

    # Process in batches
    new_entries = []
    failed = []

    for batch_start in range(0, len(new_words), BATCH_SIZE):
        batch = new_words[batch_start:batch_start + BATCH_SIZE]
        batch_num = batch_start // BATCH_SIZE + 1
        total_batches = (len(new_words) + BATCH_SIZE - 1) // BATCH_SIZE
        print(f'Batch {batch_num}/{total_batches}: {batch[0][0]} … {batch[-1][0]}')

        # Prepare batch data
        batch_data = []
        for hanzi, pinyin, pos in batch:
            en_defs = cedict.get(hanzi, [])
            batch_data.append({
                'hanzi': hanzi,
                'pinyin': pinyin,
                'pos': pos,
                'en_defs': en_defs,
            })

        # Translate
        translated_list = translate_batch(batch_data)

        # Build entries
        translated_map = {t['hanzi']: t for t in translated_list}
        for hanzi, pinyin, pos in batch:
            t = translated_map.get(hanzi)
            if t:
                entry = build_entry(hanzi, pinyin, pos, t)
                new_entries.append(entry)
            else:
                print(f'  ⚠ Missing translation for {hanzi}')
                failed.append(hanzi)
                # Add stub entry with English definition
                en_defs = cedict.get(hanzi, [''])
                stub_entry = build_entry(hanzi, pinyin, pos, {
                    'vi_meaning': en_defs[0] if en_defs else '',
                    'en_meaning': en_defs[0].split(';')[0][:40] if en_defs else '',
                    'example_cn': '',
                    'example_pinyin': '',
                    'example_vi': '',
                })
                new_entries.append(stub_entry)

        print(f'  ✓ {len(translated_list)} translated (cumulative new: {len(new_entries)})')

    # Merge and save
    combined = existing + new_entries
    save_hsk1(combined)

    print(f'\n=== Summary ===')
    print(f'Original: {len(existing)} từ')
    print(f'Added: {len(new_entries)} từ')
    print(f'Total: {len(combined)} từ')
    if failed:
        print(f'⚠ Failed/stub: {len(failed)} từ: {failed}')
    else:
        print('✓ All words translated successfully')


if __name__ == '__main__':
    main()
