#!/usr/bin/env python3
"""
Phase B/C — Import HSK vocab (raw, no API).
Dùng cho HSK2, HSK3, HSK4 — tương tự import_vocab_hsk1_raw.py.

Usage:
  python3 tool/import_vocab_raw.py --level 2 [--dry-run]
  python3 tool/import_vocab_raw.py --level 3 [--dry-run]
  python3 tool/import_vocab_raw.py --level 4 [--dry-run]
"""

import json, sys, os, re, csv, gzip, shutil
from datetime import datetime

DRY_RUN = '--dry-run' in sys.argv
LEVEL   = int(next((sys.argv[i+1] for i, a in enumerate(sys.argv) if a == '--level'), 0))

if not LEVEL or LEVEL not in (2, 3, 4):
    print('Usage: python3 tool/import_vocab_raw.py --level 2|3|4 [--dry-run]')
    sys.exit(1)

DATA_DIR  = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
CACHE_DIR = os.path.join(os.path.dirname(__file__), '.cache')
HSK30_CACHE  = os.path.join(CACHE_DIR, 'hsk30.csv')
CEDICT_CACHE = os.path.join(CACHE_DIR, 'cedict.txt.gz')

# Target counts per HSK 2021
TARGETS = {2: 772, 3: 973, 4: 1000}

# ── POS ───────────────────────────────────────────────────────────────────────

POS_MAP = {
    'V':'v','N':'n','Adj':'adj','Adv':'adv','Num':'num','M':'mw',
    'Pron':'pron','Prep':'prep','Conj':'conj','Part':'part',
    'Aux':'aux','Int':'interj','Prefix':'prefix','Suffix':'suffix',
}

def map_pos(pos_str):
    for p in pos_str.replace('/',',').split(','):
        if p.strip() in POS_MAP:
            return POS_MAP[p.strip()]
    return 'n'


# ── Pinyin ────────────────────────────────────────────────────────────────────

def normalize_pinyin(s):
    tone_map = str.maketrans('āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜ',
                              'aaaaeeeeiiiioooouuuuuuuu')
    return re.sub(r'\s+', '', s.lower().translate(tone_map))


# ── CC-CEDICT ─────────────────────────────────────────────────────────────────

SKIP_PREFIXES = ('surname ','variant of ','old variant of ','abbr. for ',
                 'see also ','erhua variant','also written')

def load_cedict():
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

def best_def(defs: list[str]) -> str:
    for d in defs:
        s = re.split(r'[;,]', d)[0].strip()
        if s and not any(s.lower().startswith(p) for p in SKIP_PREFIXES):
            return s
    return re.split(r'[;,]', defs[0])[0].strip() if defs else ''


# ── HSK30 ─────────────────────────────────────────────────────────────────────

def clean_hanzi(s: str) -> str:
    return re.split(r'[（(]', s)[0].strip()

def load_hsk30(level: int):
    rows, seen = [], set()
    with open(HSK30_CACHE, encoding='utf-8') as f:
        for r in csv.DictReader(f):
            if r['Level'] != str(level):
                continue
            simp   = clean_hanzi(r['Simplified'].split('|')[0])
            pinyin = r['Pinyin'].split('|')[0].strip()
            pos    = r['POS'].split('|')[0].strip()
            if simp and simp not in seen:
                seen.add(simp)
                rows.append((simp, pinyin, pos))
    return rows


# ── Build entry ───────────────────────────────────────────────────────────────

def build_entry(hanzi, pinyin, pos, en_defs, level):
    wt = map_pos(pos)
    en = best_def(en_defs) if en_defs else 'TODO_TRANSLATE'
    return {
        'id':               f'hsk{level}_{hanzi}',
        'hanzi':            hanzi,
        'pinyin':           pinyin,
        'pinyinNormalized': normalize_pinyin(pinyin),
        'characters':       list(hanzi),
        'meanings': [{'pos': wt, 'vi': en, 'en': en}],
        'exampleSentences': [],
        'level':    level,
        'wordType': wt,
    }


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print(f'=== Phase B/C — HSK{LEVEL} raw import ===')
    print('MODE: dry-run\n' if DRY_RUN else 'MODE: live\n')

    cedict   = load_cedict()
    hsk_all  = load_hsk30(LEVEL)
    out_file = f'hsk{LEVEL}.json'
    out_path = os.path.join(DATA_DIR, out_file)

    if os.path.exists(out_path):
        existing = json.load(open(out_path, encoding='utf-8'))
        existing_hanzi = {e['hanzi'] for e in existing}
    else:
        existing, existing_hanzi = [], set()

    new_words = [(h, p, pos) for h, p, pos in hsk_all if h not in existing_hanzi]
    no_cedict = [h for h, _, _ in new_words if h not in cedict]

    print(f'Existing :  {len(existing)} từ')
    print(f'HSK 2021 :  {len(hsk_all)} từ  (target: {TARGETS[LEVEL]})')
    print(f'To add   :  {len(new_words)} từ')
    print(f'No CEDICT:  {len(no_cedict)} từ')
    if no_cedict:
        print(f'  {no_cedict[:10]}{"..." if len(no_cedict)>10 else ""}')
    print()

    if DRY_RUN:
        print('Sample (first 3):')
        for h, p, pos in new_words[:3]:
            e = build_entry(h, p, pos, cedict.get(h, []), LEVEL)
            print(f'  {h} ({p}, {pos}) → {e["meanings"][0]["en"]!r}')
        return

    new_entries = [build_entry(h, p, pos, cedict.get(h, []), LEVEL) for h, p, pos in new_words]

    # Backup
    ts = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_dir = os.path.join(DATA_DIR + f'_backup_phaseB_{ts}')
    os.makedirs(backup_dir, exist_ok=True)
    if os.path.exists(out_path):
        shutil.copy(out_path, os.path.join(backup_dir, out_file))
        print(f'Backed up → {backup_dir}/{out_file}')

    combined = existing + new_entries
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(combined, f, ensure_ascii=False, indent=2)

    todo = sum(1 for e in new_entries if e['meanings'][0]['vi'] == 'TODO_TRANSLATE')
    print(f'✓ Wrote {out_file}  ({len(existing)} + {len(new_entries)} = {len(combined)} từ)')
    print(f'\n=== Summary ===')
    print(f'Added         : {len(new_entries)} từ')
    print(f'TODO_TRANSLATE: {todo} từ')
    print(f'EN placeholder: {len(new_entries)-todo} từ (cần dịch → VI)')


if __name__ == '__main__':
    main()
