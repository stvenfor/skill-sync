# skill: harmony-to-kmp (~/.agents/skills/harmony-to-kmp)
# adapted from transform-harmony shots/compare pipeline; target UI = KMP/CMP OHOS
#!/usr/bin/env bash
# 对 PNG 做无损压缩（不改像素）；截图后自动调用。
# 用法: compress_png.sh <file.png> [file2.png ...]
# 工具优先级: oxipng（本机默认已装）→ optipng → pngcrush → python3+Pillow
#
# 速度（墙钟）：
#   - 默认 oxipng -o ${OXIPNG_LEVEL:-2}（截图够用；比 -o max 快一个数量级）
#   - 体积极致：export OXIPNG_LEVEL=max
#   - 跳过：export SKIP_COMPRESS=1
#   - 多文件一次 oxipng 调用（比逐张开进程快）
set -euo pipefail

if [ "${SKIP_COMPRESS:-0}" = "1" ]; then
  echo "SKIP_COMPRESS=1 → 跳过压缩: $*"
  exit 0
fi

[ $# -ge 1 ] || { echo "用法: compress_png.sh <file.png> ..." >&2; exit 1; }

OXIPNG_LEVEL="${OXIPNG_LEVEL:-2}"

# 收集存在的 PNG
pngs=()
for f in "$@"; do
  [ -f "$f" ] || { echo "跳过（不存在）: $f" >&2; continue; }
  case "$f" in
    *.png|*.PNG) pngs+=("$f") ;;
    *) echo "跳过（非 PNG）: $f" >&2 ;;
  esac
done
[ ${#pngs[@]} -ge 1 ] || exit 0

report_one() {
  local f="$1" before="$2" after
  after=$(wc -c < "$f" | tr -d ' ')
  if [ "$after" -lt "$before" ]; then
    echo "compress OK $f  ${before} → ${after} bytes"
  else
    echo "compress keep $f  ${before} bytes（已最优或无工具增益）"
  fi
}

if command -v oxipng >/dev/null 2>&1; then
  declare -a befores=()
  for f in "${pngs[@]}"; do
    befores+=("$(wc -c < "$f" | tr -d ' ')")
  done
  # 一次调用压全部；-q 安静；--strip safe 去安全元数据；不改像素
  oxipng -o "$OXIPNG_LEVEL" --strip safe -q "${pngs[@]}"
  i=0
  for f in "${pngs[@]}"; do
    report_one "$f" "${befores[$i]}"
    i=$((i + 1))
  done
  exit 0
fi

compress_one_fallback() {
  local f="$1" before after
  before=$(wc -c < "$f" | tr -d ' ')
  if command -v optipng >/dev/null 2>&1; then
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
kwargs = {"optimize": True, "compress_level": 9}
if im.mode in ("RGBA", "RGB", "L", "P"):
    im.save(p, format="PNG", **kwargs)
else:
    im.convert("RGBA").save(p, format="PNG", **kwargs)
PY
  fi
  report_one "$f" "$before"
}

for f in "${pngs[@]}"; do compress_one_fallback "$f"; done
