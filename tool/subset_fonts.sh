#!/usr/bin/env bash
#
# Regenerates the self-hosted subset fonts in assets/fonts/.
#
# Why: the app previously pulled Manrope/Inter/Noto Sans SC from the Google
# Fonts CDN via a render-blocking <link> in web/index.html. Under the COEP
# `require-corp` policy in web/_headers, those cross-origin font requests are
# blocked, so the deployed web app silently fell back to system fonts. Self
# hosting subset fonts fixes correctness AND cuts the CJK payload from ~40MB
# to ~2.2MB (Noto Sans SC 17M -> ~0.9M, Noto Serif SC 24M -> ~1.3M) by keeping
# only the Hanzi that actually appear in assets/data.
#
# Requirements: python3 with fonttools + brotli (see VENV below), curl.
# Usage: tool/subset_fonts.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV="${FONT_VENV:-/tmp/fontvenv}"
SRC="$(mktemp -d)"
OUT="$ROOT/assets/fonts"
CHARSET="$(mktemp)"

# 1. Tooling --------------------------------------------------------------
if [ ! -x "$VENV/bin/pyftsubset" ]; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --quiet fonttools brotli
fi
PYF="$VENV/bin/pyftsubset"
PY="$VENV/bin/python"

# 2. Extract the exact Hanzi (CJK) charset used anywhere in assets/data ----
"$PY" - "$ROOT/assets/data" "$CHARSET" <<'PY'
import os, sys
root, out = sys.argv[1], sys.argv[2]
def is_cjk(cp):
    return (0x3400 <= cp <= 0x4DBF or 0x4E00 <= cp <= 0x9FFF or
            0xF900 <= cp <= 0xFAFF or 0x3000 <= cp <= 0x303F or
            0xFF00 <= cp <= 0xFFEF)
chars = set()
for dp, _, fs in os.walk(root):
    for f in fs:
        try:
            txt = open(os.path.join(dp, f), encoding="utf-8").read()
        except (UnicodeDecodeError, OSError):
            continue
        chars.update(c for c in txt if is_cjk(ord(c)))
open(out, "w", encoding="utf-8").write("".join(sorted(chars)))
print(f"CJK glyphs: {len(chars)}")
PY

# 3. Download source variable fonts from the Google Fonts repo -------------
base="https://github.com/google/fonts/raw/main/ofl"
curl -sL "$base/manrope/Manrope%5Bwght%5D.ttf"          -o "$SRC/Manrope.ttf"
curl -sL "$base/inter/Inter%5Bopsz,wght%5D.ttf"          -o "$SRC/Inter.ttf"
curl -sL "$base/notosanssc/NotoSansSC%5Bwght%5D.ttf"     -o "$SRC/NotoSansSC.ttf"
curl -sL "$base/notoserifsc/NotoSerifSC%5Bwght%5D.ttf"   -o "$SRC/NotoSerifSC.ttf"

# 4. Subset (keep wght axis so weights interpolate from one file) ----------
# Latin: Basic/Latin-1, Ext-A/B, Vietnamese, pinyin tone marks, punctuation, ₫.
LATIN="U+0000-00FF,U+0100-024F,U+0259,U+0300-036F,U+01CD-01DC,U+1E00-1EFF,U+2000-206F,U+2070-209F,U+20A0-20BF,U+2122,U+2190-2193,U+2212,U+25CA,U+FB00-FB04"
CJKRANGE="U+0020-007E,U+3000-303F,U+FF00-FFEF,U+2000-206F"
COMMON="--layout-features=* --no-hinting --desubroutinize --drop-tables+=DSIG --recalc-bounds"

mkdir -p "$OUT"
# shellcheck disable=SC2086
for fam in Manrope Inter; do
  $PYF "$SRC/$fam.ttf" --unicodes="$LATIN" $COMMON --output-file="$OUT/$fam-subset.ttf"
done
# shellcheck disable=SC2086
for fam in NotoSansSC NotoSerifSC; do
  $PYF "$SRC/$fam.ttf" --text-file="$CHARSET" --unicodes="$CJKRANGE" $COMMON --output-file="$OUT/$fam-subset.ttf"
done

echo "Done. Subset fonts written to $OUT:"
du -h "$OUT"/*.ttf
