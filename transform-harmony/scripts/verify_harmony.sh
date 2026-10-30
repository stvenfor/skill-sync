#!/usr/bin/env bash
# 鸿蒙真机还原验证：对同一 page 截鸿蒙图，与「选定视觉真值端」PNG 比差异。
# 用法: verify_harmony.sh <页面名> <模块名> [--threshold 0.01]
# 前置：鸿蒙设备已打开对应态；真值 PNG 已在选定平台桌面根（SHOT_PLATFORM=android|ios）。
# SHOT_PLATFORM 默认 android → ~/Desktop/android-shots；ios → ~/Desktop/ios-shots。
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
PLATFORM="${SHOT_PLATFORM:-android}"
case "$PLATFORM" in
  ios) SHOTS_ROOT="${IOS_SHOTS_ROOT:-$HOME/Desktop/ios-shots}" ;;
  android|*) PLATFORM=android; SHOTS_ROOT="${ANDROID_SHOTS_ROOT:-$HOME/Desktop/android-shots}" ;;
esac
OUT="$SHOTS_ROOT/$MODULE"
A="$OUT/$PAGE.png"
[ -f "$A" ] || { echo "缺视觉真值($PLATFORM): $A（先 capture/ios_capture 或确认已有截图）" >&2; exit 2; }

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
