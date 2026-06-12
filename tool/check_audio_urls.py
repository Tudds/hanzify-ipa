#!/usr/bin/env python3
"""Spot-check audio MP3 trên R2 CDN theo convention URL của app.

Chạy tay khi nghi ngờ thiếu audio (không nằm trong CI):
    python3 tool/check_audio_urls.py [--per-level N]

Kiểm tra 3 convention mà AudioUrls (lib/core/audio/audio_urls.dart) suy ra:
  - vocab/{vocabId}.mp3            (phát âm từ)
  - vocab/{vocabId}_E0.mp3         (câu ví dụ đầu — dictation fallback)
  - conv/{convId}_L{index}.mp3     (line hội thoại — dictation chính)
"""

from __future__ import annotations

import argparse
import json
import random
import sys
import urllib.parse
import urllib.request
from pathlib import Path

BASE = "https://pub-7d5fb452d3c14b469b1d630f885dfa87.r2.dev/audio/v1"
ROOT = Path(__file__).resolve().parent.parent / "assets" / "data"

# Cloudflare chặn User-Agent mặc định "Python-urllib" (403) — giả lập browser.
HEADERS = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) hanzify-audio-check"}


def head_ok(path: str) -> bool:
    # vocab id chứa chữ Hán → phải percent-encode phần path.
    url = f"{BASE}/{urllib.parse.quote(path)}"
    request = urllib.request.Request(url, method="HEAD", headers=HEADERS)
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            return response.status == 200
    except Exception:
        return False


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--per-level", type=int, default=10,
                        help="số vocab lấy mẫu mỗi level (mặc định 10)")
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()
    rng = random.Random(args.seed)

    failures: list[str] = []
    checked = 0

    for level in (1, 2, 3, 4):
        vocab = json.loads((ROOT / f"hsk{level}.json").read_text())
        sample = rng.sample(vocab, min(args.per_level, len(vocab)))
        for item in sample:
            for url in (
                f"vocab/{item['id']}.mp3",
                f"vocab/{item['id']}_E0.mp3",
            ):
                checked += 1
                if not head_ok(url):
                    failures.append(url)
        print(f"HSK{level}: đã kiểm tra {len(sample)} vocab")

    conversations = json.loads((ROOT / "conversation.json").read_text())
    conv_sample = rng.sample(conversations, min(10, len(conversations)))
    for conv in conv_sample:
        lines = conv.get("lines", [])
        if not lines:
            continue
        index = rng.randrange(len(lines))
        url = f"conv/{conv['id']}_L{index}.mp3"
        checked += 1
        if not head_ok(url):
            failures.append(url)
    print(f"conv: đã kiểm tra {len(conv_sample)} line")

    print(f"\nTổng: {checked} URL, lỗi: {len(failures)}")
    for url in failures:
        print(f"  404/ERR: {url}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
