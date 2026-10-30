#!/usr/bin/env bash
# 抓鸿蒙侧同一页面，与 Android 截图并排判收。
# 用法: harmony_shot.sh <页面名> [模块名]
# 落盘: 同模块桌面目录，文件名 <page>.harmony.png（不做 git 管理）
set -euo pipefail

PAGE="${1:?用法: harmony_shot.sh <页面名> [模块名]}"
MODULE="${2:-$PAGE}"
SHOTS_ROOT="${ANDROID_SHOTS_ROOT:-$HOME/Desktop/android-shots}"
OUT="$SHOTS_ROOT/$MODULE"
mkdir -p "$OUT"

HDC_BIN="${HDC_BIN:-$(command -v hdc || true)}"
if [ -z "${HDC_BIN}" ] && [ -x /Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc ]; then
  HDC_BIN=/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc
fi
[ -n "${HDC_BIN}" ] && [ -x "$HDC_BIN" ] || { echo "找不到 hdc" >&2; exit 1; }
"$HDC_BIN" list targets 2>/dev/null | grep -qv '^\[Empty\]$' || { echo "鸿蒙设备未连接" >&2; exit 1; }

"$HDC_BIN" shell rm -f /data/local/tmp/qpy_shot.png >/dev/null 2>&1 || true
"$HDC_BIN" shell snapshot_display -f /data/local/tmp/qpy_shot.png >/dev/null
"$HDC_BIN" file recv /data/local/tmp/qpy_shot.png "$OUT/$PAGE.harmony.png"
"$HDC_BIN" shell rm -f /data/local/tmp/qpy_shot.png >/dev/null 2>&1 || true

echo "OK -> $OUT/$PAGE.harmony.png（对照 $OUT/$PAGE.png）"
