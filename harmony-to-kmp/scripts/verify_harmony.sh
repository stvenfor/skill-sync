#!/usr/bin/env bash
# skill: harmony-to-kmp (~/.agents/skills/harmony-to-kmp)
# DEVICE：对比 KMP/CMP（harmonyApp 前台）vs 鸿蒙原生真值（harmony-shots）
# 用法: verify_harmony.sh <页面名> <模块名> [--threshold 0.01]
# 前置：真值 PNG 已在 ~/Desktop/harmony-shots/<module>/<page>.png（先跑 harmony_shot / run_shots）
#       鸿蒙设备当前前台为【KMP/CMP 包】对应态
# 默认 SHOT_PLATFORM=harmony；禁把 android/ios 截图当对比源
# 超阈值 → 只改表内 KMP 文件；禁改真值 PNG / 禁改鸿蒙原生仓
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
PLATFORM="${SHOT_PLATFORM:-harmony}"
case "$PLATFORM" in
  ios)
    echo "本 skill DEVICE 对比源须为鸿蒙原生（SHOT_PLATFORM=harmony）；ios 截图不得作对比源" >&2
    exit 2
    ;;
  android)
    echo "本 skill DEVICE 对比源须为鸿蒙原生（SHOT_PLATFORM=harmony）；android 截图不得作对比源" >&2
    exit 2
    ;;
  harmony|ohos-native|*)
    SHOTS_ROOT="${HARMONY_SHOTS_ROOT:-$HOME/Desktop/harmony-shots}"
    ;;
esac
OUT="$SHOTS_ROOT/$MODULE"
A="$OUT/$PAGE.png"
[ -f "$A" ] || { echo "缺视觉真值(harmony): $A（先在鸿蒙原生前台跑 harmony_shot.sh / run_shots.sh）" >&2; exit 2; }

# 抓当前前台（应为 KMP）为候选；不覆盖真值
CAPTURE_AS=kmp FORCE_RECAPTURE=1 "$ROOT/harmony_shot.sh" "$PAGE" "$MODULE"
H="$OUT/$PAGE.kmp.png"
REPORT="$OUT/$PAGE.compare.json"
set +e
python3 "$ROOT/compare_shots.py" "$A" "$H" --threshold "$THRESHOLD" --out "$REPORT"
RC=$?
set -e
if [ "$RC" -ne 0 ]; then
  echo "差异超过阈值 → 同步优化：对照真值 $A vs KMP $H，按 mapping-table 回勾后只改表内 KMP 文件，再重跑本脚本。禁改真值 PNG / 原生仓。" >&2
fi
exit "$RC"
