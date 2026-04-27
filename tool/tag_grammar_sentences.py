#!/usr/bin/env python3
"""
P1.2 — Thêm sentenceRefs[] vào grammar_hsk*.json.

sentenceRefs: list of sentenceId = "{convId}#L{lineIdx}" trỏ đến câu thực
trong conversation.json minh họa grammar đó.

Strategy:
  1. Từ conv_to_grammar.json: tìm các conv có grammar gId
  2. Lấy tất cả sentences từ các conv đó
  3. Dùng Gemini chọn 1-3 câu minh họa nhất cho mỗi grammar

Usage:
  GEMINI_API_KEYS="key" python3 tool/tag_grammar_sentences.py [--dry-run]
"""

import json
import os
import re
import shutil
import sys
import time
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path

DRY_RUN = '--dry-run' in sys.argv
DATA_DIR = Path(__file__).parent.parent / 'assets' / 'data'
GRAPH_DIR = DATA_DIR / 'graph' / 'inverted'
RETRY_MAX = 3
RETRY_DELAY = 15
MODEL = 'gemini-2.5-flash'
API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent'

SYSTEM_PROMPT = """\
Bạn là chuyên gia ngữ pháp tiếng Trung. Nhiệm vụ: chọn những câu tiếng Trung minh họa rõ nhất cho một điểm ngữ pháp cụ thể.

Quy tắc:
- Trả về JSON array các sentenceId (string), tối đa 3 câu tốt nhất.
- Chỉ chọn câu thực sự dùng cấu trúc ngữ pháp đó, không chọn câu chỉ liên quan chủ đề.
- Nếu không có câu nào phù hợp, trả về [].
- Không thêm markdown hay giải thích.
"""


def get_keys():
    raw = os.environ.get('GEMINI_API_KEYS', os.environ.get('GEMINI_API_KEY', ''))
    return [k.strip() for k in raw.split(',') if k.strip()]


def call_gemini(prompt, keys, key_idx):
    for attempt in range(RETRY_MAX):
        key = keys[key_idx % len(keys)]
        url = API_URL.format(model=MODEL) + f'?key={key}'
        body = json.dumps({
            'system_instruction': {'parts': [{'text': SYSTEM_PROMPT}]},
            'contents': [{'parts': [{'text': prompt}]}],
            'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 512},
        }).encode()
        try:
            req = urllib.request.Request(url, data=body,
                                         headers={'Content-Type': 'application/json'})
            with urllib.request.urlopen(req, timeout=60) as r:
                resp = json.loads(r.read())
            text = resp['candidates'][0]['content']['parts'][0]['text'].strip()
            return text, key_idx
        except urllib.error.HTTPError as e:
            if e.code == 429:
                key_idx += 1
                print(f'    429 — rotate, retry {attempt+1}')
                time.sleep(RETRY_DELAY)
            else:
                print(f'    HTTP {e.code}')
                time.sleep(5)
        except Exception as ex:
            print(f'    Error: {ex}')
            time.sleep(5)
    return '[]', key_idx


def parse_ids(text):
    m = re.search(r'\[.*?\]', text, re.DOTALL)
    if not m:
        return []
    try:
        result = json.loads(m.group())
        return [r for r in result if isinstance(r, str)]
    except Exception:
        return []


def main():
    keys = get_keys()
    if not keys and not DRY_RUN:
        print('ERROR: set GEMINI_API_KEYS')
        return

    # Load data
    convs = json.loads((DATA_DIR / 'conversation.json').read_text())
    conv_to_grammar = json.loads((GRAPH_DIR / 'conv_to_grammar.json').read_text())

    # Build sentenceId → {zh, vi} map
    sent_map = {}
    for conv in convs:
        for i, line in enumerate(conv.get('lines', [])):
            sid = f"{conv['id']}#L{i}"
            sent_map[sid] = {'zh': line['zh'], 'vi': line['vi']}

    # Build grammar → list of candidate sentenceIds
    grammar_to_candidates = {}
    for convId, gids in conv_to_grammar.items():
        conv = next((c for c in convs if c['id'] == convId), None)
        if not conv:
            continue
        for gId in gids:
            grammar_to_candidates.setdefault(gId, [])
            for i in range(len(conv.get('lines', []))):
                sid = f'{convId}#L{i}'
                if sid not in grammar_to_candidates[gId]:
                    grammar_to_candidates[gId].append(sid)

    print(f'Grammars with candidates: {len(grammar_to_candidates)}')

    # Load all grammar files
    all_grammar = {}
    for level in [1, 2, 3, 4]:
        fname = f'grammar_hsk{level}.json'
        path = DATA_DIR / fname
        if path.exists():
            entries = json.loads(path.read_text())
            for g in entries:
                g['_file'] = fname
                all_grammar[g['id']] = g

    # Process each grammar that has candidates
    key_idx = 0
    updated = 0

    for gId, candidates in grammar_to_candidates.items():
        if gId not in all_grammar:
            continue
        g = all_grammar[gId]

        # Skip if already tagged
        if g.get('sentenceRefs'):
            continue

        sents_text = '\n'.join(
            f'  {sid}: {sent_map[sid]["zh"]} ({sent_map[sid]["vi"]})'
            for sid in candidates if sid in sent_map
        )
        if not sents_text.strip():
            continue

        print(f'  {gId} ({g.get("title","")}) — {len(candidates)} candidates...', end=' ', flush=True)

        if DRY_RUN:
            print('[dry-run skip]')
            continue

        prompt = (
            f'Điểm ngữ pháp: {g.get("title", gId)}\n'
            f'Cấu trúc: {g.get("structure", "")}\n'
            f'Giải thích: {g.get("explanation", "")[:200]}\n\n'
            f'Các câu ứng viên (sentenceId: zh / vi):\n{sents_text}\n\n'
            f'Chọn tối đa 3 sentenceId minh họa rõ nhất cấu trúc này. '
            f'Output: JSON array của sentenceId strings.'
        )

        resp, key_idx = call_gemini(prompt, keys, key_idx)
        refs = parse_ids(resp)
        # Validate IDs exist
        refs = [r for r in refs if r in sent_map]

        g['sentenceRefs'] = refs
        updated += 1
        print(f'✓ {len(refs)} refs')
        time.sleep(2)

    if DRY_RUN:
        print('\n[dry-run] done')
        return

    # Save back to files
    files_updated = set()
    by_file = {}
    for g in all_grammar.values():
        fname = g.pop('_file')
        by_file.setdefault(fname, []).append(g)
        files_updated.add(fname)

    for fname in files_updated:
        path = DATA_DIR / fname
        bak = DATA_DIR / f'{fname.replace(".json","")}.bak_p12_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
        shutil.copy(path, bak)
        path.write_text(json.dumps(by_file[fname], ensure_ascii=False, indent=2))
        print(f'  ✓ {fname} saved (backup: {bak.name})')

    print(f'\nDone — {updated} grammars tagged with sentenceRefs')


if __name__ == '__main__':
    main()
