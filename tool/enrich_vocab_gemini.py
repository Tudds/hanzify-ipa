#!/usr/bin/env python3
"""
Enrich HSK vocab — thêm tags[] và exampleSentences[] bằng Gemini API.

Usage:
    GEMINI_API_KEYS="key1,key2" python3 tool/enrich_vocab_gemini.py --level 1
    GEMINI_API_KEYS="key1,key2" python3 tool/enrich_vocab_gemini.py --level all
    python3 tool/enrich_vocab_gemini.py --level 1 --dry-run

- Tags: chọn 1-3 từ TAXONOMY cố định (cho Context Graph).
- Example: 1 câu tiếng Trung tự nhiên dùng từ mục tiêu + pinyin + dịch VI.
- Chỉ enrich những field đang thiếu, không ghi đè dữ liệu có sẵn.
- Save incremental mỗi batch, auto-backup trước khi chạy, multi-key rotation khi 429.
"""

import argparse
import copy
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
BATCH_SIZE = 25
RETRY_MAX = 3
RETRY_DELAY = 15
BATCH_DELAY = 4
MODEL = "gemini-2.5-flash"
API_URL = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"

# Taxonomy cố định — 28 topic tags cho Context Graph
TAGS_TAXONOMY = [
    "gia đình", "học tập", "công việc", "sức khỏe", "thời gian", "địa điểm",
    "giao thông", "ẩm thực", "mua sắm", "du lịch", "thời tiết", "sở thích",
    "thể thao", "âm nhạc", "cảm xúc", "tính cách", "nghề nghiệp", "tài chính",
    "công nghệ", "giáo dục", "nghệ thuật", "thiên nhiên", "động vật", "màu sắc",
    "số lượng", "hành động", "giao tiếp", "văn hóa",
]

SYSTEM_PROMPT = f"""\
Bạn là chuyên gia biên soạn giáo trình tiếng Trung cho người Việt.
Nhiệm vụ: với mỗi từ tiếng Trung, sinh tags chủ đề + 1 câu ví dụ tự nhiên.

TAGS TAXONOMY (chỉ chọn từ danh sách này, 1-3 tag mỗi từ):
{", ".join(TAGS_TAXONOMY)}

VÍ DỤ (exampleSentences[0]):
- cn: câu tiếng Trung giản thể 6-15 chữ, tự nhiên, chứa từ mục tiêu.
- pinyin: pinyin có dấu thanh, viết tách từ.
- vi: dịch tiếng Việt ngắn gọn, chuẩn.

Trả về ĐÚNG JSON object, không markdown, không giải thích.
Format: {{"<id>": {{"tags": ["..."], "example": {{"cn": "...", "pinyin": "...", "vi": "..."}}}}, ...}}
Nếu entry đã có sẵn example (marked SKIP_EX), bỏ qua field example, chỉ trả tags.
"""


def needs_enrich(word: dict) -> tuple[bool, bool]:
    """Return (need_tags, need_example)."""
    need_tags = not word.get("tags")
    need_example = not word.get("exampleSentences")
    return need_tags, need_example


def build_prompt(batch: list[dict]) -> str:
    items = []
    for item in batch:
        flag = " [SKIP_EX]" if not item["need_example"] else ""
        meaning = "; ".join(m.get("vi", "") for m in item["meanings"][:2])
        items.append(
            f'{item["id"]}: {item["hanzi"]} ({item["pinyin"]}) = "{meaning}"{flag}'
        )
    return (
        "Enrich các từ sau. Trả JSON object {id: {tags, example?}}:\n\n"
        + "\n".join(items)
    )


_key_state = {"idx": 0}


def call_gemini(api_keys: list[str], prompt: str, dry_run: bool) -> dict:
    if dry_run:
        return {}

    body = {
        "systemInstruction": {"parts": [{"text": SYSTEM_PROMPT}]},
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.3,
            "responseMimeType": "application/json",
        },
    }
    data = json.dumps(body).encode("utf-8")

    total_attempts = RETRY_MAX * max(1, len(api_keys))
    for attempt in range(1, total_attempts + 1):
        key = api_keys[_key_state["idx"] % len(api_keys)]
        url = API_URL.format(model=MODEL) + f"?key={key}"
        try:
            req = urllib.request.Request(
                url, data=data, headers={"Content-Type": "application/json"}
            )
            with urllib.request.urlopen(req, timeout=120) as resp:
                payload = json.loads(resp.read().decode("utf-8"))

            text = payload["candidates"][0]["content"]["parts"][0]["text"].strip()
            text = re.sub(r"^```(?:json)?\s*", "", text)
            text = re.sub(r"\s*```$", "", text)
            return json.loads(text)
        except urllib.error.HTTPError as e:
            err_body = e.read().decode("utf-8", errors="replace")[:200]
            key_tag = f"key#{_key_state['idx'] % len(api_keys) + 1}"
            print(f"  [warn] HTTP {e.code} ({key_tag}, attempt {attempt}): {err_body}")
            if e.code == 429 and len(api_keys) > 1:
                _key_state["idx"] += 1
                print(f"  [info] Rotate → key#{_key_state['idx'] % len(api_keys) + 1}")
            if attempt < total_attempts:
                time.sleep(RETRY_DELAY if e.code != 429 else RETRY_DELAY * 2)
        except json.JSONDecodeError as e:
            print(f"  [warn] JSON parse error (attempt {attempt}): {e}")
            if attempt < total_attempts:
                time.sleep(RETRY_DELAY)
        except Exception as e:
            print(f"  [warn] API error (attempt {attempt}): {e}")
            if attempt < total_attempts:
                time.sleep(RETRY_DELAY)

    print("  [error] All retries failed — skipping batch")
    return {}


def sanitize_tags(raw_tags) -> list[str]:
    if not isinstance(raw_tags, list):
        return []
    valid = set(TAGS_TAXONOMY)
    out = []
    for t in raw_tags:
        if isinstance(t, str) and t.strip() in valid and t.strip() not in out:
            out.append(t.strip())
    return out[:3]


def enrich_file(level: int, api_keys: list[str], dry_run: bool) -> tuple[int, int]:
    path = ASSETS_DIR / f"hsk{level}.json"
    if not path.exists():
        print(f"File not found: {path}")
        return 0, 0

    data = json.load(open(path, encoding="utf-8"))

    pending = []
    for wi, word in enumerate(data):
        need_tags, need_example = needs_enrich(word)
        if need_tags or need_example:
            pending.append({
                "word_idx": wi,
                "id": word["id"],
                "hanzi": word["hanzi"],
                "pinyin": word["pinyin"],
                "meanings": word.get("meanings", []),
                "need_tags": need_tags,
                "need_example": need_example,
            })

    total = len(pending)
    need_tag_count = sum(1 for p in pending if p["need_tags"])
    need_ex_count = sum(1 for p in pending if p["need_example"])
    print(f"\nhsk{level}.json — {total} từ cần enrich / {len(data)} total")
    print(f"  need_tags={need_tag_count}, need_example={need_ex_count}")

    if total == 0:
        return 0, 0

    if dry_run:
        print("  [dry-run] Sample:")
        for item in pending[:3]:
            print(f"    {item['id']} {item['hanzi']} tags={item['need_tags']} ex={item['need_example']}")
        return 0, 0

    backup_path = path.with_suffix(f".bak_enrich_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
    shutil.copy(path, backup_path)
    print(f"  Backup → {backup_path.name}")

    result_data = copy.deepcopy(data)
    tags_filled = 0
    examples_filled = 0
    failed = 0

    for batch_start in range(0, total, BATCH_SIZE):
        batch = pending[batch_start: batch_start + BATCH_SIZE]
        batch_num = batch_start // BATCH_SIZE + 1
        total_batches = (total + BATCH_SIZE - 1) // BATCH_SIZE
        print(f"  Batch {batch_num}/{total_batches} ({len(batch)} từ)...", end=" ", flush=True)

        result = call_gemini(api_keys, build_prompt(batch), dry_run)

        for item in batch:
            entry = result.get(item["id"])
            if not isinstance(entry, dict):
                failed += 1
                continue

            word = result_data[item["word_idx"]]

            if item["need_tags"]:
                tags = sanitize_tags(entry.get("tags"))
                if tags:
                    word["tags"] = tags
                    tags_filled += 1

            if item["need_example"]:
                ex = entry.get("example")
                if isinstance(ex, dict) and ex.get("cn") and ex.get("pinyin") and ex.get("vi"):
                    word["exampleSentences"] = [{
                        "cn": ex["cn"].strip(),
                        "pinyin": ex["pinyin"].strip(),
                        "vi": ex["vi"].strip(),
                    }]
                    examples_filled += 1

        print(f"✓ (tags={tags_filled}, ex={examples_filled}, fail={failed})")

        with open(path, "w", encoding="utf-8") as f:
            json.dump(result_data, f, ensure_ascii=False, indent=2)

        if batch_start + BATCH_SIZE < total:
            time.sleep(BATCH_DELAY)

    print(f"  Saved {path.name} — tags +{tags_filled}, examples +{examples_filled}, failed {failed}")
    return tags_filled, examples_filled


def main():
    parser = argparse.ArgumentParser(description="Enrich HSK vocab with tags + examples")
    parser.add_argument("--level", default="all", help="1, 2, 3, 4, or 'all'")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    keys_env = os.environ.get("GEMINI_API_KEYS") or os.environ.get("GEMINI_API_KEY") or ""
    api_keys = [k.strip() for k in keys_env.split(",") if k.strip()]
    if not api_keys and not args.dry_run:
        print("Error: set GEMINI_API_KEY hoặc GEMINI_API_KEYS (comma-sep)")
        return
    if api_keys:
        print(f"  [info] Using {len(api_keys)} API key(s)")

    levels = [1, 2, 3, 4] if args.level == "all" else [int(args.level)]

    total_tags = 0
    total_ex = 0
    for level in levels:
        t, e = enrich_file(level, api_keys, args.dry_run)
        total_tags += t
        total_ex += e

    print(f"\nHoàn thành — tags +{total_tags}, examples +{total_ex}")


if __name__ == "__main__":
    main()
