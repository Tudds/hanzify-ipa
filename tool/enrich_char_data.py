#!/usr/bin/env python3
"""
A2 — Enrich char_hsk*.json with pinyin, pinyinNormalized, radical, definitionVi.

Sources (priority order):
  1. Vocab files (hsk*.json) — single-char entries → pinyin + Vietnamese meaning
  2. makemeahanzi dictionary.txt — pinyin + radical + English definition
     https://github.com/skishore/makemeahanzi

definitionVi strategy:
  - Single-char in vocab → first Vietnamese meaning (best quality)
  - Otherwise → English from makemeahanzi (marked for review)

Usage:
  python3 tool/enrich_char_data.py [--dry-run]
"""

import json
import sys
import os
import re
import urllib.request

DRY_RUN = '--dry-run' in sys.argv
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
CACHE_DIR = os.path.join(os.path.dirname(__file__), '.cache')
MMA_URL = 'https://raw.githubusercontent.com/skishore/makemeahanzi/master/dictionary.txt'
MMA_CACHE = os.path.join(CACHE_DIR, 'makemeahanzi_dictionary.txt')

os.makedirs(CACHE_DIR, exist_ok=True)


# ── Helpers ──────────────────────────────────────────────────────────────────

def load(f):
    with open(os.path.join(DATA_DIR, f), encoding='utf-8') as fh:
        return json.load(fh)


def save(f, data):
    path = os.path.join(DATA_DIR, f)
    if DRY_RUN:
        print(f'  [dry-run] would write {path}')
        return
    with open(path, 'w', encoding='utf-8') as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
    print(f'  ✓ {path}')


def normalize_pinyin(pinyin: str) -> str:
    """Strip tone marks and whitespace → lowercase ASCII."""
    tone_map = str.maketrans('āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜ',
                              'aaaaeeeeiiiioooouuuuuuuu')
    return re.sub(r'\s+', '', pinyin.lower().translate(tone_map))


def load_makemeahanzi() -> dict:
    """Download (or load from cache) makemeahanzi dictionary → {char: entry}."""
    if not os.path.exists(MMA_CACHE):
        print(f'Downloading makemeahanzi dictionary → {MMA_CACHE}')
        data = urllib.request.urlopen(MMA_URL, timeout=30).read()
        with open(MMA_CACHE, 'wb') as f:
            f.write(data)
        print(f'  Downloaded {len(data)//1024} KB')
    else:
        print(f'Using cached makemeahanzi ({MMA_CACHE})')

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


def build_vocab_char_map() -> dict:
    """Build map: single char → {pinyin, pinyinNormalized, definitionVi}."""
    char_map = {}
    for fname in ('hsk1.json', 'hsk2.json', 'hsk3.json'):
        for v in load(fname):
            if len(v['hanzi']) == 1:
                # Use first Vietnamese meaning as definition
                meanings = v.get('meanings', [])
                vi_def = meanings[0]['vi'] if meanings else ''
                char_map[v['hanzi']] = {
                    'pinyin': v['pinyin'],
                    'pinyinNormalized': v['pinyinNormalized'],
                    'definitionVi': vi_def,
                    'source': 'vocab',
                }
    return char_map


def enrich_entry(entry: dict, vocab_map: dict, mma: dict) -> dict:
    char = entry['char']

    # Already fully filled — skip
    if (entry.get('pinyin') and entry.get('radical')
            and entry.get('definitionVi') and entry.get('pinyinNormalized')):
        return entry

    # Source 1: vocab (highest quality for pinyin + Vietnamese def)
    if char in vocab_map:
        vm = vocab_map[char]
        entry['pinyin'] = entry.get('pinyin') or vm['pinyin']
        entry['pinyinNormalized'] = entry.get('pinyinNormalized') or vm['pinyinNormalized']
        entry['definitionVi'] = entry.get('definitionVi') or vm['definitionVi']

    # Source 2: makemeahanzi (pinyin if still missing, radical, English def fallback)
    if char in mma:
        mma_entry = mma[char]
        pinyin_list = mma_entry.get('pinyin', [])

        if not entry.get('pinyin') and pinyin_list:
            entry['pinyin'] = pinyin_list[0]

        if not entry.get('pinyinNormalized') and entry.get('pinyin'):
            entry['pinyinNormalized'] = normalize_pinyin(entry['pinyin'])

        if not entry.get('radical'):
            entry['radical'] = mma_entry.get('radical') or None

        # definitionVi fallback: English definition (marked for future translation)
        if not entry.get('definitionVi'):
            en_def = mma_entry.get('definition', '')
            if en_def:
                # Keep only the first clause (before comma or semicolon)
                short = re.split(r'[;,]', en_def)[0].strip()
                entry['definitionVi'] = short  # English — to be translated

    return entry


def process_file(filename: str, vocab_map: dict, mma: dict) -> dict:
    data = load(filename)
    stats = {'total': len(data), 'pinyin': 0, 'radical': 0, 'defVi': 0,
             'src_vocab': 0, 'src_mma': 0, 'missing_pinyin': 0,
             'missing_radical': 0, 'missing_def': 0}

    enriched = []
    for entry in data:
        char = entry['char']
        original_pinyin = entry.get('pinyin', '')
        original_radical = entry.get('radical')

        new_entry = enrich_entry(dict(entry), vocab_map, mma)
        enriched.append(new_entry)

        if new_entry.get('pinyin') and not original_pinyin:
            stats['pinyin'] += 1
        if new_entry.get('radical') and not original_radical:
            stats['radical'] += 1
        if new_entry.get('definitionVi'):
            stats['defVi'] += 1
        if char in vocab_map:
            stats['src_vocab'] += 1
        elif char in mma:
            stats['src_mma'] += 1

        # Track still-missing
        if not new_entry.get('pinyin'):
            stats['missing_pinyin'] += 1
        if not new_entry.get('radical'):
            stats['missing_radical'] += 1
        if not new_entry.get('definitionVi'):
            stats['missing_def'] += 1

    save(filename, enriched)
    return stats


def main():
    print('=== A2 — Enrich char data ===')
    if DRY_RUN:
        print('MODE: dry-run\n')

    mma = load_makemeahanzi()
    vocab_map = build_vocab_char_map()
    print(f'Vocab single-char entries: {len(vocab_map)}')
    print()

    total_stats = {'total': 0, 'pinyin': 0, 'radical': 0, 'defVi': 0,
                   'missing_pinyin': 0, 'missing_radical': 0, 'missing_def': 0}

    for filename in ('char_hsk1.json', 'char_hsk2.json', 'char_hsk3.json'):
        print(f'── {filename} ──')
        stats = process_file(filename, vocab_map, mma)
        print(f'  total: {stats["total"]} chars')
        print(f'  pinyin filled: +{stats["pinyin"]}')
        print(f'  radical filled: +{stats["radical"]}')
        print(f'  definitionVi filled: {stats["defVi"]}/{stats["total"]}')
        print(f'  still missing → pinyin:{stats["missing_pinyin"]} radical:{stats["missing_radical"]} def:{stats["missing_def"]}')
        for k in ('total', 'pinyin', 'radical', 'defVi', 'missing_pinyin', 'missing_radical', 'missing_def'):
            total_stats[k] += stats[k]
        print()

    print('=== Summary ===')
    t = total_stats
    print(f'Total chars: {t["total"]}')
    print(f'Pinyin filled this run: +{t["pinyin"]}')
    print(f'Radical filled this run: +{t["radical"]}')
    print(f'definitionVi coverage: {t["defVi"]}/{t["total"]} ({t["defVi"]/t["total"]*100:.0f}%)')
    print()
    if t['missing_pinyin'] or t['missing_radical'] or t['missing_def']:
        print('⚠ Still missing:')
        print(f'  pinyin: {t["missing_pinyin"]}')
        print(f'  radical: {t["missing_radical"]}')
        print(f'  definitionVi: {t["missing_def"]} (need manual Vietnamese translation)')
    else:
        print('✓ All fields filled')

    print()
    note_count = sum(
        1 for fname in ('char_hsk1.json', 'char_hsk2.json', 'char_hsk3.json')
        for c in load(fname)
        if c.get('definitionVi') and c['char'] not in vocab_map
    )
    if not DRY_RUN:
        print(f'ℹ {note_count} entries have English definitionVi (from makemeahanzi)')
        print('  → These should be reviewed & translated to Vietnamese in Phase B/C')


if __name__ == '__main__':
    main()
