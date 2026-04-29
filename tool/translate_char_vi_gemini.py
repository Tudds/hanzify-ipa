#!/usr/bin/env python3
"""
Dịch definitionVi tiếng Anh → tiếng Việt trong char_hsk*.json dùng Gemini API.

Usage:
    GEMINI_API_KEYS="key1,key2" python3 tool/translate_char_vi_gemini.py [--level 4] [--dry-run]

Chỉ dịch các entry mà definitionVi trông như tiếng Anh (contains Latin chars > 50%).
"""

import argparse
import json
import os
import re
import shutil
import time
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path

ASSETS_DIR = Path(__file__).parent.parent / "assets" / "data"
BATCH_SIZE = 40
RETRY_MAX = 3
RETRY_DELAY = 15
BATCH_DELAY = 4
MODEL = "gemini-2.5-flash"
API_URL = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"

SYSTEM_PROMPT = """\
Bạn là chuyên gia từ điển Hoa-Việt. Dịch nghĩa tiếng Anh của chữ Hán sang tiếng Việt ngắn gọn, chuẩn mực.

Quy tắc:
- Trả về JSON array đúng thứ tự input, không thêm markdown.
- Mỗi phần tử là string nghĩa tiếng Việt ngắn (1-6 từ), ví dụ: "yêu thương", "học tập", "quốc gia".
- Không dịch tên riêng, giữ nguyên nếu không rõ nghĩa.
- Nếu là từ chức năng (của, và, thì...) → dịch sát nghĩa ngữ pháp.
"""


def is_english(text: str) -> bool:
    if not text:
        return False
    latin = sum(1 for c in text if c.isascii() and c.isalpha())
    return latin / max(len(text), 1) > 0.4


def get_keys() -> list:
    raw = os.environ.get("GEMINI_API_KEYS", os.environ.get("GEMINI_API_KEY", ""))
    return [k.strip() for k in raw.split(",") if k.strip()]


def call_gemini(prompt: str, keys: list, key_idx: int) -> tuple[str, int]:
    for attempt in range(RETRY_MAX):
        key = keys[key_idx % len(keys)]
        url = API_URL.format(model=MODEL) + f"?key={key}"
        body = json.dumps({
            "system_instruction": {"parts": [{"text": SYSTEM_PROMPT}]},
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.2, "maxOutputTokens": 2048},
        }).encode()
        try:
            req = urllib.request.Request(url, data=body,
                                         headers={"Content-Type": "application/json"})
            with urllib.request.urlopen(req, timeout=60) as r:
                resp = json.loads(r.read())
            text = resp["candidates"][0]["content"]["parts"][0]["text"].strip()
            return text, key_idx
        except urllib.error.HTTPError as e:
            if e.code == 429:
                key_idx += 1
                print(f"    429 — rotate key, retry {attempt+1}/{RETRY_MAX}")
                time.sleep(RETRY_DELAY)
            else:
                print(f"    HTTP {e.code}: {e.read()[:200]}")
                time.sleep(RETRY_DELAY)
        except Exception as ex:
            print(f"    Error: {ex}")
            time.sleep(RETRY_DELAY)
    return "", key_idx


def parse_response(text: str, expected: int) -> list:
    match = re.search(r'\[.*\]', text, re.DOTALL)
    if not match:
        return []
    try:
        result = json.loads(match.group())
        if isinstance(result, list) and len(result) == expected:
            return result
    except Exception:
        pass
    return []


def process_file(filename: str, keys: list, dry_run: bool):
    path = ASSETS_DIR / filename
    data = json.loads(path.read_text(encoding='utf-8'))

    to_translate = [(i, e) for i, e in enumerate(data)
                    if is_english(e.get('definitionVi', ''))]

    print(f"{filename} — {len(to_translate)} entries cần dịch / {len(data)} total")
    if not to_translate or dry_run:
        if dry_run:
            print("  [dry-run] skip")
        return

    # Backup
    bak = ASSETS_DIR / f"{filename.replace('.json', '')}.bak_charvi_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    shutil.copy(path, bak)
    print(f"  Backup → {bak.name}")

    key_idx = 0
    translated = 0

    for batch_start in range(0, len(to_translate), BATCH_SIZE):
        batch = to_translate[batch_start:batch_start + BATCH_SIZE]
        batch_num = batch_start // BATCH_SIZE + 1
        total_batches = (len(to_translate) + BATCH_SIZE - 1) // BATCH_SIZE
        print(f"  Batch {batch_num}/{total_batches} ({len(batch)} chars)...", end=' ', flush=True)

        items = [{"char": e['char'], "en": e['definitionVi']} for _, e in batch]
        prompt = (f"Dịch {len(items)} nghĩa tiếng Anh của chữ Hán sang tiếng Việt ngắn gọn.\n"
                  f"Input: {json.dumps(items, ensure_ascii=False)}\n"
                  f"Output: JSON array {len(items)} strings tiếng Việt, đúng thứ tự.")

        resp_text, key_idx = call_gemini(prompt, keys, key_idx)
        results = parse_response(resp_text, len(batch))

        if results:
            for (idx, _), vi in zip(batch, results):
                if vi and isinstance(vi, str):
                    data[idx]['definitionVi'] = vi.strip()
                    translated += 1
            print(f"✓ ({translated} done)")
        else:
            print(f"✗ parse fail — giữ nguyên batch này")

        # Save incremental
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')

        if batch_start + BATCH_SIZE < len(to_translate):
            time.sleep(BATCH_DELAY)

    print(f"  Saved {filename} — translated +{translated}, failed {len(to_translate)-translated}\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--level', default='4', help='HSK level or "all"')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()

    keys = get_keys()
    if not keys and not args.dry_run:
        print("ERROR: set GEMINI_API_KEYS env var")
        return

    levels = [1, 2, 3, 4] if args.level == 'all' else [int(args.level)]
    for lv in levels:
        process_file(f'char_hsk{lv}.json', keys, args.dry_run)


if __name__ == '__main__':
    main()
