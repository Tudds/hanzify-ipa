#!/usr/bin/env python3
"""
Phase B — Import HSK1 vocab từ 152 → 500 (no API, raw data, review later).

Vietnamese meanings: lấy từ CC-CEDICT English (marked TODO_TRANSLATE).
Example sentences: empty array (điền sau).

Usage:
  python3 tool/import_vocab_hsk1_raw.py [--dry-run]
"""

import json, sys, os, re, csv, gzip, shutil
from datetime import datetime

DRY_RUN = '--dry-run' in sys.argv

DATA_DIR  = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
CACHE_DIR = os.path.join(os.path.dirname(__file__), '.cache')
HSK30_CACHE  = os.path.join(CACHE_DIR, 'hsk30.csv')
CEDICT_CACHE = os.path.join(CACHE_DIR, 'cedict.txt.gz')

# ── POS ───────────────────────────────────────────────────────────────────────

POS_MAP = {
    'V':'v','N':'n','Adj':'adj','Adv':'adv','Num':'num','M':'mw',
    'Pron':'pron','Prep':'prep','Conj':'conj','Part':'part',
    'Aux':'aux','Int':'interj','Prefix':'prefix','Suffix':'suffix',
}

def map_pos(pos_str):
    for p in pos_str.replace('/',',').split(','):
        p = p.strip()
        if p in POS_MAP:
            return POS_MAP[p]
    return 'n'


# ── Pinyin ────────────────────────────────────────────────────────────────────

def normalize_pinyin(s):
    tone_map = str.maketrans('āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜ',
                              'aaaaeeeeiiiioooouuuuuuuu')
    return re.sub(r'\s+', '', s.lower().translate(tone_map))


# ── Loaders ───────────────────────────────────────────────────────────────────

def load_cedict():
    """Load CC-CEDICT — gộp tất cả entries cho cùng 1 simplified char."""
    pat = re.compile(r'^(\S+)\s+(\S+)\s+\[([^\]]+)\]\s+/(.+)/$')
    cedict: dict[str, list[str]] = {}
    with gzip.open(CEDICT_CACHE, 'rt', encoding='utf-8') as f:
        for line in f:
            m = pat.match(line)
            if m:
                _, simp, _, defs = m.groups()
                clean = [d for d in defs.split('/') if d and not d.startswith('CL:')]
                if clean:
                    cedict.setdefault(simp, []).extend(clean)
    return cedict


def clean_hanzi(s: str) -> str:
    """Strip parenthetical notes: '第（第二）' → '第', '们（朋友们）' → '们'."""
    return re.split(r'[（(]', s)[0].strip()


def load_hsk30_hsk1():
    rows = []
    seen = set()
    with open(HSK30_CACHE, encoding='utf-8') as f:
        for r in csv.DictReader(f):
            if r['Level'] != '1':
                continue
            simp    = clean_hanzi(r['Simplified'].split('|')[0])
            pinyin  = r['Pinyin'].split('|')[0].strip()
            pos     = r['POS'].split('|')[0].strip()
            if simp and simp not in seen:
                seen.add(simp)
                rows.append((simp, pinyin, pos))
    return rows


# ── Build entry ───────────────────────────────────────────────────────────────

SKIP_PREFIXES = ('surname ', 'variant of ', 'old variant of ', 'abbr. for ',
                 'see also ', 'erhua variant', 'also written')

def best_def(en_defs: list[str]) -> str:
    """Chọn def tốt nhất — bỏ qua surname/variant entries."""
    for d in en_defs:
        first = re.split(r'[;,]', d)[0].strip()
        if not any(first.lower().startswith(p) for p in SKIP_PREFIXES):
            return first
    # fallback — lấy cái đầu tiên dù sao
    return re.split(r'[;,]', en_defs[0])[0].strip() if en_defs else ''


def make_vi_meaning(en_defs: list[str]) -> str:
    short = best_def(en_defs)
    return short if short else 'TODO_TRANSLATE'


def build_entry(hanzi, pinyin, pos, en_defs):
    wt = map_pos(pos)
    vi = make_vi_meaning(en_defs)
    en = best_def(en_defs) if en_defs else ''
    return {
        'id':               f'hsk1_{hanzi}',
        'hanzi':            hanzi,
        'pinyin':           pinyin,
        'pinyinNormalized': normalize_pinyin(pinyin),
        'characters':       list(hanzi),
        'meanings': [{
            'pos': wt,
            'vi':  vi,   # English placeholder — cần dịch sang tiếng Việt
            'en':  en,
        }],
        'exampleSentences': [],  # điền sau
        'level':    1,
        'wordType': wt,
    }


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print('=== Phase B — HSK1 raw import (no API) ===')
    print('MODE: dry-run\n' if DRY_RUN else 'MODE: live\n')

    cedict   = load_cedict()
    existing = json.load(open(os.path.join(DATA_DIR, 'hsk1.json'), encoding='utf-8'))
    existing_hanzi = {e['hanzi'] for e in existing}
    hsk1_all = load_hsk30_hsk1()

    new_words = [(h, p, pos) for h, p, pos in hsk1_all if h not in existing_hanzi]

    print(f'Existing :  {len(existing)} từ')
    print(f'HSK 2021 :  {len(hsk1_all)} từ')
    print(f'To add   :  {len(new_words)} từ')

    no_cedict = [h for h, _, _ in new_words if h not in cedict]
    print(f'No CEDICT:  {len(no_cedict)} từ → sẽ dùng TODO_TRANSLATE')
    if no_cedict:
        print(f'  {no_cedict[:20]}')
    print()

    if DRY_RUN:
        print('Sample entries:')
        for h, p, pos in new_words[:5]:
            e = build_entry(h, p, pos, cedict.get(h, []))
            print(json.dumps(e, ensure_ascii=False, indent=2))
        return

    # Build new entries
    new_entries = [build_entry(h, p, pos, cedict.get(h, [])) for h, p, pos in new_words]

    # Backup + save
    out_path = os.path.join(DATA_DIR, 'hsk1.json')
    ts = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_dir = DATA_DIR + f'_backup_phaseB_{ts}'
    os.makedirs(backup_dir, exist_ok=True)
    shutil.copy(out_path, os.path.join(backup_dir, 'hsk1.json'))
    print(f'Backed up → {backup_dir}/hsk1.json')

    combined = existing + new_entries
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(combined, f, ensure_ascii=False, indent=2)

    print(f'✓ Wrote hsk1.json  ({len(existing)} + {len(new_entries)} = {len(combined)} từ)')

    # Stats
    todo = sum(1 for e in new_entries if 'TODO_TRANSLATE' in e['meanings'][0]['vi'])
    print(f'\n=== Summary ===')
    print(f'Added: {len(new_entries)} từ')
    print(f'TODO_TRANSLATE: {todo} từ (thiếu CEDICT)')
    print(f'Has English placeholder: {len(new_entries) - todo} từ (cần dịch → VI)')


if __name__ == '__main__':
    main()
