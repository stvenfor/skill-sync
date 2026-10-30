#!/usr/bin/env bash
# 对 PNG 做无损压缩（不改像素）；截图后自动调用。
# 用法: compress_png.sh <file.png> [file2.png ...]
# 工具优先级: oxipng → optipng → pngcrush → python3+Pillow(optimize+compress_level=9)
set -euo pipefail

compress_one() {
  local f="$1"
  [ -f "$f" ] || { echo "跳过（不存在）: $f" >&2; return 0; }
  case "$f" in
    *.png|*.PNG) ;;
    *) echo "跳过（非 PNG）: $f" >&2; return 0 ;;
  esac
  local before after
  before=$(wc -c < "$f" | tr -d ' ')
  if command -v oxipng >/dev/null 2>&1; then
    oxipng -o max --strip safe -q "$f"
  elif command -v optipng >/dev/null 2>&1; then
    optipng -o7 -quiet "$f"
  elif command -v pngcrush >/dev/null 2>&1; then
    local tmp="${f}.crush.tmp"
    pngcrush -q -brute "$f" "$tmp" && mv "$tmp" "$f" || rm -f "$tmp"
  else
    python3 - "$f" << 'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
try:
    from PIL import Image
except ImportError:
    print("无 oxipng/optipng/pngcrush/Pillow，跳过压缩: " + str(p), file=sys.stderr)
    sys.exit(0)
im = Image.open(p)
# 保留模式；仅重存 optimize
kwargs = {"optimize": True, "compress_level": 9}
if im.mode in ("RGBA", "RGB", "L", "P"):
    im.save(p, format="PNG", **kwargs)
else:
    im.convert("RGBA").save(p, format="PNG", **kwargs)
PY
  fi
  after=$(wc -c < "$f" | tr -d ' ')
  if [ "$after" -lt "$before" ]; then
    echo "compress OK $f  ${before} → ${after} bytes"
  else
    echo "compress keep $f  ${before} bytes（已最优或无工具增益）"
  fi
}

[ $# -ge 1 ] || { echo "用法: compress_png.sh <file.png> ..." >&2; exit 1; }
for f in "$@"; do compress_one "$f"; done
