#!/usr/bin/env python3
"""
upload_r2.py — Upload audio files to Cloudflare R2 bucket.

Setup:
  1. Tạo bucket R2 trên Cloudflare dashboard (vd: hanzify-audio)
  2. Tạo R2 API token với quyền Object Read & Write
  3. Bật Public Access (Settings → R2.dev subdomain hoặc custom domain)
  4. Tạo file `tool/.r2.env` với nội dung:
       R2_ACCOUNT_ID=xxx
       R2_ACCESS_KEY=xxx
       R2_SECRET_KEY=xxx
       R2_BUCKET=hanzify-audio
       R2_PUBLIC_BASE=https://pub-xxx.r2.dev   # hoặc custom domain

Usage:
  tool/.venv/bin/python tool/upload_r2.py [--prefix audio/v1] [--dry-run]
"""
import argparse
import os
import sys
from pathlib import Path
import boto3
from botocore.config import Config
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

ROOT = Path(__file__).resolve().parent.parent
LOCAL_DIR = ROOT / "audio_out" / "v1"
ENV_FILE = ROOT / "tool" / ".r2.env"


def load_env():
    if not ENV_FILE.exists():
        sys.exit(f"❌ Thiếu file credentials: {ENV_FILE}\n"
                 f"   Tạo theo template trong docstring upload_r2.py")
    env = {}
    for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        k, _, v = line.partition("=")
        env[k.strip()] = v.strip()
    required = ["R2_ACCOUNT_ID", "R2_ACCESS_KEY", "R2_SECRET_KEY", "R2_BUCKET"]
    missing = [k for k in required if not env.get(k)]
    if missing:
        sys.exit(f"❌ Thiếu credentials: {missing}")
    return env


def make_s3_client(env):
    endpoint = f"https://{env['R2_ACCOUNT_ID']}.r2.cloudflarestorage.com"
    return boto3.client(
        "s3",
        endpoint_url=endpoint,
        aws_access_key_id=env["R2_ACCESS_KEY"],
        aws_secret_access_key=env["R2_SECRET_KEY"],
        config=Config(signature_version="s3v4", retries={"max_attempts": 3}),
        region_name="auto",
    )


def list_existing(client, bucket, prefix):
    """Lấy {key: size} của tất cả objects đã có trên R2."""
    paginator = client.get_paginator("list_objects_v2")
    existing = {}
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            existing[obj["Key"]] = obj["Size"]
    return existing


def upload_one(client, bucket, local: Path, key: str):
    client.upload_file(
        Filename=str(local),
        Bucket=bucket,
        Key=key,
        ExtraArgs={
            "ContentType": "audio/mpeg",
            "CacheControl": "public, max-age=31536000, immutable",  # 1 năm
        },
    )
    return key


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prefix", default="audio/v1",
                    help="Prefix trong bucket (default: audio/v1)")
    ap.add_argument("--concurrency", type=int, default=20)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    env = load_env()
    client = make_s3_client(env)
    bucket = env["R2_BUCKET"]

    # Liệt kê file local
    files = sorted(LOCAL_DIR.rglob("*.mp3"))
    print(f"📁 Local files: {len(files)} ở {LOCAL_DIR}")

    # Liệt kê đã có trên R2
    print(f"☁️  Liệt kê objects đã upload trên R2...")
    existing = list_existing(client, bucket, args.prefix)
    print(f"   Đã có: {len(existing)} objects")

    # Lọc những file CHƯA upload (hoặc size khác)
    pending = []
    for f in files:
        rel = f.relative_to(LOCAL_DIR)
        key = f"{args.prefix}/{rel.as_posix()}"
        local_size = f.stat().st_size
        if existing.get(key) != local_size:
            pending.append((f, key))

    print(f"📤 Cần upload: {len(pending)} files")
    if args.dry_run:
        for f, k in pending[:10]:
            print(f"   {f.name} → {k}")
        if len(pending) > 10:
            print(f"   ... và {len(pending)-10} file khác")
        return

    if not pending:
        print("✅ Đã đồng bộ.")
        return

    # Upload song song
    failed = []
    with ThreadPoolExecutor(max_workers=args.concurrency) as ex:
        futures = {ex.submit(upload_one, client, bucket, f, k): (f, k)
                   for f, k in pending}
        for fut in tqdm(as_completed(futures), total=len(pending), ncols=80, desc="Upload"):
            try:
                fut.result()
            except Exception as e:
                f, k = futures[fut]
                failed.append((k, str(e)))

    print(f"\n✅ Uploaded: {len(pending)-len(failed)}/{len(pending)}")
    if failed:
        print(f"❌ Failed: {len(failed)}")
        for k, e in failed[:10]:
            print(f"   {k}: {e}")

    if env.get("R2_PUBLIC_BASE"):
        sample_key = pending[0][1] if pending else next(iter(existing))
        print(f"\n🌐 Public URL example: {env['R2_PUBLIC_BASE']}/{sample_key}")


if __name__ == "__main__":
    main()
