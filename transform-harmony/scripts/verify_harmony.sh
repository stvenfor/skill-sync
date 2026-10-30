#!/usr/bin/env bash
# 鸿蒙真机还原验证：对同一 page 截鸿蒙图，与 Android 真值比差异。
# 用法: verify_harmony.sh <页面名> <模块名> [--threshold 0.01]
# 前置：鸿蒙设备已打开对应态；Android 真值已存在于桌面模块目录。
# 差异 > 阈值 → exit 1，并提示进入「同步优化」（按对照点表只改表内文件）。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
PAGE="${1:?用法: verify_harmony.sh <页面名> <模块名>}"
MODULE="${2:?}"
THRESHOLD=0.01
shift 2 || true
while [ $# -gt 0 ]; do
  case "$1" in
    --threshold) THRESHOLD="${2:?}"; shift 2 ;;
    *) shift ;;
  esac
done
SHOTS_ROOT="${ANDROID_SHOTS_ROOT:-$HOME/Desktop/android-shots}"
OUT="$SHOTS_ROOT/$MODULE"
A="$OUT/$PAGE.png"
[ -f "$A" ] || { echo "缺 Android 真值: $A（先 capture 或确认已有截图）" >&2; exit 2; }

"$ROOT/harmony_shot.sh" "$PAGE" "$MODULE"
H="$OUT/$PAGE.harmony.png"
REPORT="$OUT/$PAGE.compare.json"
set +e
python3 "$ROOT/compare_shots.py" "$A" "$H" --threshold "$THRESHOLD" --out "$REPORT"
RC=$?
set -e
if [ "$RC" -ne 0 ]; then
  echo "差异超过阈值 → 同步优化：对照 $A vs $H，按 mapping-table 回勾后只改表内鸿蒙文件，再重跑本脚本。" >&2
fi
exit "$RC"
