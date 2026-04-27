#!/usr/bin/env python3
"""
Build char_hsk4.json — chỉ chứa các chars MỚI (chưa có trong HSK1-3).

Sources (priority):
  1. hsk4.json single-char vocab → pinyin + Vietnamese meaning
  2. makemeahanzi dictionary.txt → strokes, radical, pinyin fallback, EN def fallback

Usage:
  python3 tool/build_char_hsk4.py [--dry-run]
"""

import json
import os
import re
import sys

DRY_RUN = '--dry-run' in sys.argv
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
CACHE_DIR = os.path.join(os.path.dirname(__file__), '.cache')
MMA_CACHE = os.path.join(CACHE_DIR, 'makemeahanzi_dictionary.txt')


def load(f):
    with open(os.path.join(DATA_DIR, f), encoding='utf-8') as fh:
        return json.load(fh)


def normalize_pinyin(pinyin: str) -> str:
    tone_map = str.maketrans('āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜ',
                              'aaaaeeeeiiiioooouuuuuuuu')
    return re.sub(r'\s+', '', pinyin.lower().translate(tone_map))


def load_mma() -> dict:
    mma = {}
    with open(MMA_CACHE, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
                mma[entry['character']] = entry
            except Exception:
                pass
    print(f'Loaded {len(mma)} makemeahanzi entries')
    return mma


def build_vocab_map() -> dict:
    """Single-char entries from all levels → pinyin + VI meaning."""
    char_map = {}
    for fname in ('hsk1.json', 'hsk2.json', 'hsk3.json', 'hsk4.json'):
        for v in load(fname):
            if len(v['hanzi']) == 1:
                meanings = v.get('meanings', [])
                vi_def = meanings[0]['vi'] if meanings else ''
                if v['hanzi'] not in char_map:  # first occurrence wins (lower level)
                    char_map[v['hanzi']] = {
                        'pinyin': v['pinyin'],
                        'pinyinNormalized': v['pinyinNormalized'],
                        'definitionVi': vi_def,
                    }
    return char_map


def main():
    print('=== Build char_hsk4.json ===')
    if DRY_RUN:
        print('MODE: dry-run\n')

    mma = load_mma()
    vocab_map = build_vocab_map()
    print(f'Vocab single-char entries: {len(vocab_map)}')

    # Chars already covered in HSK1-3
    existing_chars = set()
    for lv in [1, 2, 3]:
        for c in load(f'char_hsk{lv}.json'):
            existing_chars.add(c['char'])
    print(f'Existing chars (HSK1-3): {len(existing_chars)}')

    # All unique chars in HSK4 vocab
    hsk4_vocab = load('hsk4.json')
    hsk4_chars = set()
    for w in hsk4_vocab:
        hsk4_chars.update(w['hanzi'])

    new_chars = sorted(hsk4_chars - existing_chars)
    print(f'New chars for char_hsk4.json: {len(new_chars)}\n')

    entries = []
    stats = {'pinyin': 0, 'radical': 0, 'defVi_vocab': 0, 'defVi_mma': 0, 'missing_def': 0}

    for char in new_chars:
        entry = {
            'char': char,
            'strokes': [],
            'hskLevel': 4,
            'strokeCount': None,
            'radical': None,
            'pinyin': None,
            'pinyinNormalized': None,
            'definition': None,
            'definitionVi': None,
        }

        # Source 1: vocab map
        if char in vocab_map:
            vm = vocab_map[char]
            entry['pinyin'] = vm['pinyin']
            entry['pinyinNormalized'] = vm['pinyinNormalized']
            entry['definitionVi'] = vm['definitionVi']
            stats['defVi_vocab'] += 1

        # Source 2: makemeahanzi
        if char in mma:
            m = mma[char]
            entry['strokes'] = m.get('strokes', [])
            entry['strokeCount'] = len(entry['strokes']) or None
            entry['radical'] = m.get('radical') or None

            if not entry['pinyin']:
                pinyin_list = m.get('pinyin', [])
                if pinyin_list:
                    entry['pinyin'] = pinyin_list[0]
                    entry['pinyinNormalized'] = normalize_pinyin(pinyin_list[0])
                    stats['pinyin'] += 1

            if entry['radical']:
                stats['radical'] += 1

            if not entry['definitionVi']:
                en_def = m.get('definition', '')
                if en_def:
                    entry['definitionVi'] = re.split(r'[;,]', en_def)[0].strip()
                    stats['defVi_mma'] += 1
                else:
                    stats['missing_def'] += 1
        else:
            if not entry['pinyin']:
                stats['missing_def'] += 1

        entries.append(entry)

    print(f'Results ({len(entries)} chars):')
    print(f'  pinyin filled from mma: {stats["pinyin"]}')
    print(f'  radical filled: {stats["radical"]}')
    print(f'  definitionVi from vocab (VI): {stats["defVi_vocab"]}')
    print(f'  definitionVi from mma (EN, needs translation): {stats["defVi_mma"]}')
    print(f'  missing definitionVi: {stats["missing_def"]}')

    out_path = os.path.join(DATA_DIR, 'char_hsk4.json')
    if DRY_RUN:
        print(f'\n[dry-run] would write {out_path}')
    else:
        with open(out_path, 'w', encoding='utf-8') as f:
            json.dump(entries, f, ensure_ascii=False, indent=2)
        print(f'\n✓ Written: {out_path}')


if __name__ == '__main__':
    main()
