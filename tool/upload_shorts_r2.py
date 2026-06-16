#!/usr/bin/env python3
"""
upload_shorts_r2.py — Upload nội dung "rich" của Shorts (manifest + audio + ảnh)
lên Cloudflare R2, prefix `shorts/`.

Dùng chung credentials với upload_r2.py: file `tool/.r2.env`
  R2_ACCOUNT_ID=xxx
  R2_ACCESS_KEY=xxx
  R2_SECRET_KEY=xxx
  R2_BUCKET=hanzify-audio
  R2_PUBLIC_BASE=https://pub-xxx.r2.dev   # tùy chọn, để in URL mẫu

Bố cục thư mục nguồn (mặc định `tool/shorts_content/upload/`), MIRROR đúng đường dẫn
trong manifest:
  upload/
    manifest.json              → shorts/manifest.json
    audio/dialogue_cafe.mp3     → shorts/audio/dialogue_cafe.mp3
    images/scene_market.webp    → shorts/images/scene_market.webp

Quy tắc:
  - media (mp3/webp/jpg/png/...) → CacheControl immutable 1 năm; bỏ qua nếu R2 đã có
    file cùng size (đỡ upload lại).
  - manifest.json → CacheControl no-cache (must-revalidate) + LUÔN upload đè (để bản
    mới hiển thị ngay, không kẹt cache).

Usage:
  tool/.venv/bin/python tool/upload_shorts_r2.py --src tool/shorts_content/upload [--dry-run]

Yêu cầu: boto3, tqdm (cài trong tool/.venv giống pipeline audio).
"""
import argparse
import mimetypes
import sys
from pathlib import Path

import boto3
from botocore.config import Config
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

ROOT = Path(__file__).resolve().parent.parent
ENV_FILE = ROOT / "tool" / ".r2.env"
DEFAULT_SRC = ROOT / "tool" / "shorts_content" / "upload"

MANIFEST_NAME = "manifest.json"
IMMUTABLE_CACHE = "public, max-age=31536000, immutable"
MANIFEST_CACHE = "public, max-age=0, must-revalidate"

# ContentType theo đuôi file (R2 không tự đoán).
CONTENT_TYPES = {
    ".mp3": "audio/mpeg",
    ".m4a": "audio/mp4",
    ".aac": "audio/aac",
    ".webp": "image/webp",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".json": "application/json; charset=utf-8",
}


def load_env():
    if not ENV_FILE.exists():
        sys.exit(
            f"❌ Thiếu file credentials: {ENV_FILE}\n"
            f"   Tạo theo template trong docstring upload_r2.py / upload_shorts_r2.py"
        )
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
    paginator = client.get_paginator("list_objects_v2")
    existing = {}
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            existing[obj["Key"]] = obj["Size"]
    return existing


def content_type_for(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix in CONTENT_TYPES:
        return CONTENT_TYPES[suffix]
    guessed, _ = mimetypes.guess_type(path.name)
    return guessed or "application/octet-stream"


def upload_one(client, bucket, local: Path, key: str):
    is_manifest = local.name == MANIFEST_NAME
    client.upload_file(
        Filename=str(local),
        Bucket=bucket,
        Key=key,
        ExtraArgs={
            "ContentType": content_type_for(local),
            "CacheControl": MANIFEST_CACHE if is_manifest else IMMUTABLE_CACHE,
        },
    )
    return key


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--src",
        default=str(DEFAULT_SRC),
        help=f"Thư mục nguồn (default: {DEFAULT_SRC})",
    )
    ap.add_argument("--prefix", default="shorts", help="Prefix bucket (default: shorts)")
    ap.add_argument("--concurrency", type=int, default=20)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    src = Path(args.src).resolve()
    if not src.is_dir():
        sys.exit(f"❌ Không thấy thư mục nguồn: {src}")

    manifest = src / MANIFEST_NAME
    if not manifest.exists():
        print(f"⚠️  Cảnh báo: không thấy {MANIFEST_NAME} trong {src}")

    files = sorted(p for p in src.rglob("*") if p.is_file())
    if not files:
        sys.exit(f"❌ Thư mục nguồn rỗng: {src}")
    print(f"📁 Local files: {len(files)} ở {src}")

    env = load_env()
    client = make_s3_client(env)
    bucket = env["R2_BUCKET"]

    print("☁️  Liệt kê objects đã có trên R2...")
    existing = list_existing(client, bucket, args.prefix)
    print(f"   Đã có: {len(existing)} objects (prefix '{args.prefix}/')")

    pending = []
    for f in files:
        rel = f.relative_to(src)
        key = f"{args.prefix}/{rel.as_posix()}"
        # Manifest luôn upload đè; media bỏ qua nếu size khớp.
        if f.name == MANIFEST_NAME:
            pending.append((f, key))
        elif existing.get(key) != f.stat().st_size:
            pending.append((f, key))

    print(f"📤 Cần upload: {len(pending)} files")
    if args.dry_run:
        for f, k in pending:
            print(f"   {f.relative_to(src)} → {k}  [{content_type_for(f)}]")
        return

    if not pending:
        print("✅ Đã đồng bộ.")
        return

    failed = []
    with ThreadPoolExecutor(max_workers=args.concurrency) as ex:
        futures = {
            ex.submit(upload_one, client, bucket, f, k): (f, k)
            for f, k in pending
        }
        for fut in tqdm(
            as_completed(futures), total=len(pending), ncols=80, desc="Upload"
        ):
            try:
                fut.result()
            except Exception as e:  # noqa: BLE001
                f, k = futures[fut]
                failed.append((k, str(e)))

    print(f"\n✅ Uploaded: {len(pending) - len(failed)}/{len(pending)}")
    if failed:
        print(f"❌ Failed: {len(failed)}")
        for k, e in failed[:10]:
            print(f"   {k}: {e}")

    base = env.get("R2_PUBLIC_BASE")
    if base:
        print(f"\n🌐 Manifest URL: {base.rstrip('/')}/{args.prefix}/{MANIFEST_NAME}")
        print(
            "   Build app với:\n"
            f"   flutter build web --wasm --dart-define=SHORTS_CONTENT_URL="
            f"{base.rstrip('/')}/{args.prefix}/{MANIFEST_NAME}"
        )


if __name__ == "__main__":
    main()
