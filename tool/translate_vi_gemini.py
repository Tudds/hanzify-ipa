#!/usr/bin/env python3
"""
Translate HSK vocab meanings (vi field) from English to Vietnamese using Gemini API.

Usage:
    export GEMINI_API_KEY=your_key_here
    python3 tool/translate_vi_gemini.py --level 1
    python3 tool/translate_vi_gemini.py --level all
    python3 tool/translate_vi_gemini.py --level 1 --dry-run   # preview only, no write

Dịch field `vi` trong meanings[] sang tiếng Việt thật.
Chỉ dịch những entry mà vi == en (placeholder) hoặc vi trống.
Ghi đè file JSON gốc sau khi dịch xong (backup tự động).
"""

import argparse
import copy
import json
import os
import re
import shutil
import time
from datetime import datetime
from pathlib import Path

import urllib.request
import urllib.error

# ── Config ────────────────────────────────────────────────────────────────────
ASSETS_DIR = Path(__file__).parent.parent / "assets" / "data"
BATCH_SIZE = 60          # từ mỗi request
RETRY_MAX = 3
RETRY_DELAY = 15         # giây giữa retry (429 cần chờ lâu hơn)
BATCH_DELAY = 4          # giây giữa batch (tránh RPM limit free tier)
MODEL = "gemini-2.5-flash"
API_URL = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"

# pos labels để Gemini hiểu từ loại
POS_LABELS = {
    "n": "danh từ",
    "v": "động từ",
    "adj": "tính từ",
    "adv": "trạng từ",
    "prep": "giới từ",
    "conj": "liên từ",
    "pron": "đại từ",
    "num": "số từ",
    "mw": "lượng từ",
    "interj": "thán từ",
    "part": "trợ từ",
    "aux": "trợ động từ",
    "idiom": "thành ngữ",
    "phrase": "cụm từ",
}

SYSTEM_PROMPT = """\
Bạn là chuyên gia dịch thuật từ điển Hoa-Việt. Nhiệm vụ: dịch nghĩa tiếng Anh của từ tiếng Trung sang tiếng Việt ngắn gọn, chuẩn mực, phù hợp từ điển học tiếng Trung cho người Việt.

Quy tắc:
- Trả về ĐÚNG định dạng JSON như yêu cầu, không thêm markdown, không giải thích.
- Mỗi nghĩa: 1–5 từ tiếng Việt, có thể liệt kê 2–3 từ đồng nghĩa cách nhau dấu phẩy.
- Dùng từ phổ thông, không dùng từ Hán Việt nếu có từ thuần Việt tương đương.
- Giữ đúng từ loại (động từ → "làm gì đó", danh từ → "cái/người/việc...", v.v.)
- Không dịch lại từ gốc Hán mà viết nguyên âm Hán Việt; hãy dịch nghĩa thực tế.
"""


def needs_translation(meaning: dict) -> bool:
    vi = meaning.get("vi", "")
    en = meaning.get("en", "")
    return not vi or vi == en or vi.strip() == ""


def build_prompt(batch: list[dict]) -> str:
    """batch: list of {idx, hanzi, pinyin, pos, en}"""
    items = []
    for item in batch:
        pos_vi = POS_LABELS.get(item["pos"], item["pos"])
        items.append(
            f'{item["idx"]}. {item["hanzi"]} ({item["pinyin"]}) [{pos_vi}] — "{item["en"]}"'
        )

    return (
        "Dịch các nghĩa tiếng Anh sau sang tiếng Việt. "
        "Trả về JSON object: {\"idx\": \"bản dịch tiếng Việt\", ...}\n\n"
        + "\n".join(items)
    )


_key_state = {"idx": 0}

def call_gemini(api_keys: list[str], prompt: str, dry_run: bool) -> dict[str, str]:
    if dry_run:
        return {}

    body = {
        "systemInstruction": {"parts": [{"text": SYSTEM_PROMPT}]},
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.2,
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
            result = json.loads(text)
            return {str(k): v for k, v in result.items()}
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

    print("  [error] All retries failed for this batch — skipping")
    return {}


def translate_file(level: int, api_keys: list[str], dry_run: bool) -> int:
    path = ASSETS_DIR / f"hsk{level}.json"
    if not path.exists():
        print(f"File not found: {path}")
        return 0

    data = json.load(open(path, encoding="utf-8"))

    # Collect items that need translation
    pending = []  # {idx_str, word_idx, meaning_idx, hanzi, pinyin, pos, en}
    for wi, word in enumerate(data):
        for mi, meaning in enumerate(word.get("meanings", [])):
            if needs_translation(meaning):
                idx_str = f"{wi}_{mi}"
                pending.append({
                    "idx": idx_str,
                    "word_idx": wi,
                    "meaning_idx": mi,
                    "hanzi": word["hanzi"],
                    "pinyin": word["pinyin"],
                    "pos": meaning.get("pos", ""),
                    "en": meaning.get("en", ""),
                })

    total = len(pending)
    print(f"\nhsk{level}.json — {total} meanings cần dịch / {len(data)} từ")

    if total == 0:
        return 0

    if dry_run:
        print("  [dry-run] Sample batch:")
        for item in pending[:5]:
            print(f"    {item['hanzi']} ({item['pinyin']}) [{item['pos']}] = {item['en']!r}")
        return 0

    # Backup
    backup_path = path.with_suffix(f".bak_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
    shutil.copy(path, backup_path)
    print(f"  Backup → {backup_path.name}")

    # Translate in batches
    result_data = copy.deepcopy(data)
    translated = 0
    failed = 0

    for batch_start in range(0, total, BATCH_SIZE):
        batch = pending[batch_start: batch_start + BATCH_SIZE]
        batch_num = batch_start // BATCH_SIZE + 1
        total_batches = (total + BATCH_SIZE - 1) // BATCH_SIZE
        print(f"  Batch {batch_num}/{total_batches} ({len(batch)} từ)...", end=" ", flush=True)

        translations = call_gemini(api_keys, build_prompt(batch), dry_run)

        for item in batch:
            vi_text = translations.get(item["idx"], "")
            if vi_text:
                result_data[item["word_idx"]]["meanings"][item["meaning_idx"]]["vi"] = vi_text
                translated += 1
            else:
                failed += 1

        print(f"✓ ({translated}/{total} done)")

        # Save incremental (không mất progress nếu hit quota giữa chừng)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(result_data, f, ensure_ascii=False, indent=2)

        if batch_start + BATCH_SIZE < total:
            time.sleep(BATCH_DELAY)

    print(f"  Saved {path.name} — {translated} dịch OK, {failed} thất bại")
    return translated


def main():
    parser = argparse.ArgumentParser(description="Translate HSK meanings to Vietnamese")
    parser.add_argument("--level", default="all", help="1, 2, 3, 4, or 'all'")
    parser.add_argument("--dry-run", action="store_true", help="Preview only, no API calls")
    args = parser.parse_args()

    keys_env = os.environ.get("GEMINI_API_KEYS") or os.environ.get("GEMINI_API_KEY") or ""
    api_keys = [k.strip() for k in keys_env.split(",") if k.strip()]
    if not api_keys and not args.dry_run:
        print("Error: set GEMINI_API_KEY (single) hoặc GEMINI_API_KEYS (comma-sep)")
        return
    if api_keys:
        print(f"  [info] Using {len(api_keys)} API key(s)")

    levels = [1, 2, 3, 4] if args.level == "all" else [int(args.level)]

    total_translated = 0
    for level in levels:
        total_translated += translate_file(level, api_keys, args.dry_run)

    print(f"\nHoàn thành — tổng {total_translated} meanings đã dịch.")


if __name__ == "__main__":
    main()
