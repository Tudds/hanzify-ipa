#!/usr/bin/env python3
"""
Phase A data migration:
  A1 — Remove legacy `meaning` field from vocab JSON
  A4 — Re-ID vocab: hsk{L}_NNNN → hsk{L}_{hanzi}
  A3 — Fix 13 broken conv→grammar alias refs
       (new grammar entries are in separate files, this fixes refs only)

Usage:
  python3 tool/migrate_phase_a.py [--dry-run]
"""

import json
import sys
import os
import shutil
from datetime import datetime

DRY_RUN = '--dry-run' in sys.argv
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data')
BACKUP_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data_backup')


def load(filename):
    with open(os.path.join(DATA_DIR, filename), encoding='utf-8') as f:
        return json.load(f)


def save(filename, data):
    path = os.path.join(DATA_DIR, filename)
    if DRY_RUN:
        print(f'  [dry-run] would write {path}')
        return
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f'  ✓ wrote {path}')


def backup_data():
    if DRY_RUN:
        print('[dry-run] would backup assets/data → assets/data_backup')
        return
    ts = datetime.now().strftime('%Y%m%d_%H%M%S')
    dest = BACKUP_DIR + '_' + ts
    shutil.copytree(DATA_DIR, dest)
    print(f'✓ Backed up to {dest}')


# ── Grammar alias map: broken ref → correct existing ID ──────────────────────
GRAMMAR_ALIASES = {
    'g_bu_negation':   'g_neg_bu',
    'g_de_complement': 'g_de_comp',
    'g_degree_taile':  'g_tai_le',
    'g_le_change':     'g_le2',
    'g_le_completion': 'g_le1',
    'g_ma_question':   'g_ma',
    'g_num':           'g_numbers',
    'g_shi_equation':  'g_shi',
    'g_time_when':     'g_time_word',
    'g_yīnwèi_suǒyǐ': 'g_yinwei_suoyi',
    'g_zai_location':  'g_zai',
    'g_de_modifier':   'g_de_attr',
    'g_huanshi':       'g_haishi',
    'g_zěnme':         'g_zenme',   # tone-mark variant → canonical
}


def migrate_vocab(filename, level):
    print(f'\n── {filename} (Level {level}) ──')
    data = load(filename)
    old_ids = {}
    new_data = []
    remapped = 0
    legacy_removed = 0

    for entry in data:
        old_id = entry['id']
        hanzi = entry['hanzi']
        new_id = f'hsk{level}_{hanzi}'

        if old_id != new_id:
            old_ids[old_id] = new_id
            remapped += 1

        new_entry = {k: v for k, v in entry.items() if k != 'meaning'}
        if 'meaning' in entry:
            legacy_removed += 1
        new_entry['id'] = new_id
        new_data.append(new_entry)

    print(f'  IDs remapped: {remapped}')
    print(f'  legacy `meaning` removed: {legacy_removed}')
    save(filename, new_data)
    return old_ids


def fix_conversation_refs(old_vocab_ids_by_level):
    print('\n── conversation.json ──')
    conv = load('conversation.json')
    grammar_fixes = 0
    new_conv = []

    for c in conv:
        # Fix relatedGrammar aliases
        new_grammar_refs = []
        for ref in c.get('relatedGrammar', []):
            if ref in GRAMMAR_ALIASES:
                new_ref = GRAMMAR_ALIASES[ref]
                print(f'  conv {c["id"]}: grammar ref {ref} → {new_ref}')
                grammar_fixes += 1
                new_grammar_refs.append(new_ref)
            else:
                new_grammar_refs.append(ref)
        c['relatedGrammar'] = new_grammar_refs
        new_conv.append(c)

    print(f'  Grammar refs fixed: {grammar_fixes}')
    save('conversation.json', new_conv)


def check_remaining_broken_refs():
    print('\n── Post-migration validation ──')
    g1 = load('grammar_hsk1.json')
    g2 = load('grammar_hsk2.json')
    g3 = load('grammar_hsk3.json')
    all_ids = {g['id'] for g in g1 + g2 + g3}

    conv = load('conversation.json')
    broken = []
    for c in conv:
        for ref in c.get('relatedGrammar', []):
            if ref not in all_ids:
                broken.append((c['id'], ref))

    if broken:
        print(f'  ⚠ Still broken grammar refs ({len(broken)}):')
        for cid, ref in broken:
            print(f'    {cid} → {ref}  (needs new grammar entry)')
    else:
        print('  ✓ All grammar refs resolved')
    return broken


def main():
    print('=== Phase A Migration ===')
    if DRY_RUN:
        print('MODE: dry-run (no files written)\n')
    else:
        print('MODE: live\n')
        backup_data()

    # A1 + A4: vocab files
    all_old_ids = {}
    for fname, level in [('hsk1.json', 1), ('hsk2.json', 2), ('hsk3.json', 3)]:
        old_ids = migrate_vocab(fname, level)
        all_old_ids.update(old_ids)

    # A3: fix conversation grammar refs
    fix_conversation_refs(all_old_ids)

    # Validation
    remaining = check_remaining_broken_refs()

    print('\n=== Summary ===')
    print(f'Vocab IDs migrated: {len(all_old_ids)}')
    print(f'Grammar aliases fixed: {len(GRAMMAR_ALIASES)} types')
    print(f'Remaining broken refs (need new grammar entries): {len(remaining)}')
    if remaining:
        missing_ids = sorted({ref for _, ref in remaining})
        print(f'  Missing IDs: {missing_ids}')


if __name__ == '__main__':
    main()
