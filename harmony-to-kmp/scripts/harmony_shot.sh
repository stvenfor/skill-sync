#!/usr/bin/env bash
# skill: harmony-to-kmp (~/.agents/skills/harmony-to-kmp)
# 本脚本采集【视觉真值】：鸿蒙原生（ArkTS/ArkUI）前台页 → harmony-shots
# DEVICE 对拍由 verify_ohos / verify_harmony 完成：KMP 前台 vs 本脚本落下的真值 PNG
# 用法:
#   harmony_shot.sh <页面名> [模块名]              # 真值 → <page>.png
#   CAPTURE_AS=kmp harmony_shot.sh <页面名> [模块名]  # 候选 → <page>.kmp.png（仅 verify 内部用）
# 落盘: ~/Desktop/harmony-shots/<module>/（不做 git 管理；禁改已有真值凑绿）
# SHOT_PLATFORM=harmony|ohos-native（默认 harmony）；旁证 android|ios 不走本脚本主路径
set -euo pipefail

PAGE="${1:?用法: harmony_shot.sh <页面名> [模块名]}"
MODULE="${2:-$PAGE}"
PLATFORM="${SHOT_PLATFORM:-harmony}"
case "$PLATFORM" in
  android) SHOTS_ROOT="${ANDROID_SHOTS_ROOT:-$HOME/Desktop/android-shots}" ;;
  ios) SHOTS_ROOT="${IOS_SHOTS_ROOT:-$HOME/Desktop/ios-shots}" ;;
  harmony|ohos-native|*) SHOTS_ROOT="${HARMONY_SHOTS_ROOT:-$HOME/Desktop/harmony-shots}" ;;
esac
OUT="$SHOTS_ROOT/$MODULE"
mkdir -p "$OUT"

AS="${CAPTURE_AS:-truth}"
case "$AS" in
  kmp|candidate) DEST="$OUT/$PAGE.kmp.png" ;;
  truth|*) DEST="$OUT/$PAGE.png" ;;
esac

# 真值已存在且未强制重截 → 复用（仅 truth）
if [ "$AS" = "truth" ] || [ "$AS" = "" ]; then
  if [ -s "$DEST" ] && [ "${FORCE_RECAPTURE:-0}" != "1" ]; then
    echo "REUSE -> $DEST"
    exit 0
  fi
fi

HDC_BIN="${HDC_BIN:-$(command -v hdc || true)}"
if [ -z "${HDC_BIN}" ] && [ -x /Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc ]; then
  HDC_BIN=/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc
fi
[ -n "${HDC_BIN}" ] && [ -x "$HDC_BIN" ] || { echo "找不到 hdc" >&2; exit 1; }
"$HDC_BIN" list targets 2>/dev/null | grep -qv '^\[Empty\]$' || { echo "鸿蒙设备未连接" >&2; exit 1; }

"$HDC_BIN" shell rm -f /data/local/tmp/qpy_shot.png >/dev/null 2>&1 || true
"$HDC_BIN" shell snapshot_display -f /data/local/tmp/qpy_shot.png >/dev/null
"$HDC_BIN" file recv /data/local/tmp/qpy_shot.png "$DEST"
"$(dirname "$0")/compress_png.sh" "$DEST" || true
"$HDC_BIN" shell rm -f /data/local/tmp/qpy_shot.png >/dev/null 2>&1 || true

echo "OK ($AS) -> $DEST"
