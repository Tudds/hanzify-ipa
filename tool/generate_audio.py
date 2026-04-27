#!/usr/bin/env python3
"""
generate_audio.py — Pre-generate TTS audio for vocab, grammar, conversation.

Output structure (audio_out/v1/):
  vocab/{vocab_id}.mp3                — pinyin reading of vocab
  vocab/{vocab_id}_E{idx}.mp3         — example sentence(s)
  grammar/{grammar_id}_E{idx}.mp3     — grammar example sentences
  conv/{conv_id}_L{idx}.mp3           — conversation lines

Usage:
  tool/.venv/bin/python tool/generate_audio.py [--scope all|vocab|conv|grammar] [--levels 1,2,3,4] [--concurrency 5]
"""
import asyncio
import argparse
import json
import sys
from pathlib import Path
import edge_tts
from tqdm.asyncio import tqdm_asyncio

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "assets" / "data"
OUT = ROOT / "audio_out" / "v1"
LOG = ROOT / "audio_out" / "errors.log"

VOICE = "zh-CN-XiaoxiaoNeural"
RATE = "+0%"        # tốc độ chuẩn
VOLUME = "+0%"


def collect_jobs(scope: str, levels: list[int]) -> list[tuple[str, Path]]:
    """Trả về list (text, output_path) — bỏ qua nếu file đã tồn tại."""
    jobs = []

    # ── Vocab (pinyin + examples) ──
    if scope in ("all", "vocab"):
        for level in levels:
            f = DATA / f"hsk{level}.json"
            if not f.exists():
                continue
            for v in json.loads(f.read_text(encoding="utf-8")):
                vid = v["id"]
                # Đọc chính từ vựng (Hán tự với pinyin tự nhiên)
                jobs.append((v["hanzi"], OUT / "vocab" / f"{vid}.mp3"))
                # Câu ví dụ
                for i, ex in enumerate(v.get("exampleSentences", [])):
                    cn = ex.get("cn") or ex.get("zh", "")
                    if cn:
                        jobs.append((cn, OUT / "vocab" / f"{vid}_E{i}.mp3"))

    # ── Grammar examples ──
    if scope in ("all", "grammar"):
        for level in levels:
            f = DATA / f"grammar_hsk{level}.json"
            if not f.exists():
                continue
            for g in json.loads(f.read_text(encoding="utf-8")):
                gid = g["id"]
                for i, ex in enumerate(g.get("examples", [])):
                    zh = ex.get("zh") or ex.get("cn", "")
                    if zh:
                        jobs.append((zh, OUT / "grammar" / f"{gid}_E{i}.mp3"))

    # ── Conversation lines ──
    if scope in ("all", "conv"):
        f = DATA / "conversation.json"
        if f.exists():
            for c in json.loads(f.read_text(encoding="utf-8")):
                cid = c["id"]
                for i, line in enumerate(c.get("lines", [])):
                    zh = line.get("zh", "")
                    if zh:
                        jobs.append((zh, OUT / "conv" / f"{cid}_L{i}.mp3"))

    # Bỏ qua những job đã tồn tại
    pending = [(t, p) for t, p in jobs if not p.exists() or p.stat().st_size < 1000]
    skipped = len(jobs) - len(pending)
    print(f"📊 Total jobs: {len(jobs)} | Skipped (already exist): {skipped} | Pending: {len(pending)}")
    return pending


async def synthesize(text: str, out_path: Path, semaphore: asyncio.Semaphore,
                     errors: list, retries: int = 3):
    """Generate 1 file, có retry, an toàn semaphore."""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    async with semaphore:
        for attempt in range(1, retries + 1):
            try:
                com = edge_tts.Communicate(text, VOICE, rate=RATE, volume=VOLUME)
                await com.save(str(out_path))
                # Verify file size hợp lệ (>1KB)
                if out_path.stat().st_size < 1000:
                    raise RuntimeError(f"file too small ({out_path.stat().st_size}B)")
                return True
            except Exception as e:
                if attempt == retries:
                    errors.append(f"{out_path.name} | {text!r} | {e}")
                    return False
                await asyncio.sleep(2 ** attempt)  # exponential backoff


async def main_async(scope: str, levels: list[int], concurrency: int):
    OUT.mkdir(parents=True, exist_ok=True)
    LOG.parent.mkdir(parents=True, exist_ok=True)

    jobs = collect_jobs(scope, levels)
    if not jobs:
        print("✅ Không có gì để generate")
        return

    semaphore = asyncio.Semaphore(concurrency)
    errors: list[str] = []
    tasks = [synthesize(text, path, semaphore, errors) for text, path in jobs]

    print(f"🎙️  Generating {len(jobs)} files với concurrency={concurrency}, voice={VOICE}")
    results = await tqdm_asyncio.gather(*tasks, desc="TTS", ncols=80)

    success = sum(1 for r in results if r)
    fail = len(results) - success
    print(f"\n✅ Success: {success}/{len(jobs)}")
    if fail:
        print(f"❌ Fail: {fail} → log saved to {LOG}")
        LOG.write_text("\n".join(errors), encoding="utf-8")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--scope", choices=["all", "vocab", "conv", "grammar"], default="all")
    ap.add_argument("--levels", default="1,2,3,4",
                    help="Comma-separated levels, e.g. '1' or '1,2'")
    ap.add_argument("--concurrency", type=int, default=5)
    args = ap.parse_args()

    levels = [int(x) for x in args.levels.split(",")]
    asyncio.run(main_async(args.scope, levels, args.concurrency))


if __name__ == "__main__":
    main()
