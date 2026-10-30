#!/usr/bin/env bash
# 抓当前 Android 前台页：截图 + 控件树 + dp 测量表。
# 【仅 Android】iOS 请用 ios_capture.sh；派单用 SHOT_PLATFORM=android|ios 选定真值端。
# 真机或模拟器均可（目标须已安装应用，且 adb 在线）。
# 用法: capture.sh <页面名> [模块名]
# 落盘: $ANDROID_SHOTS_ROOT/<module>/  默认 ~/Desktop/android-shots/<module>/
# 已有非空 PNG 默认 SKIP_EXISTING；FORCE_RECAPTURE=1 强制重截。
# 产物不做 git 管理；PNG 截后自动无损压缩。
set -euo pipefail

PAGE="${1:?用法: capture.sh <页面名> [模块名]}"
MODULE="${2:-$PAGE}"
SHOTS_ROOT="${ANDROID_SHOTS_ROOT:-$HOME/Desktop/android-shots}"
OUT="$SHOTS_ROOT/$MODULE"
mkdir -p "$OUT"

# 已有非空 PNG 默认复用
if [ -f "$OUT/$PAGE.png" ] && [ -s "$OUT/$PAGE.png" ] && [ "${FORCE_RECAPTURE:-0}" != "1" ]; then
  echo "SKIP_EXISTING -> $OUT/$PAGE.png（设 FORCE_RECAPTURE=1 强制重截）"
  exit 0
fi

ADB_BIN="${ADB_BIN:-$(command -v adb || true)}"
if [ -z "${ADB_BIN}" ] && [ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]; then
  ADB_BIN="$HOME/Library/Android/sdk/platform-tools/adb"
fi
[ -n "${ADB_BIN}" ] && [ -x "$ADB_BIN" ] || { echo "找不到 adb（可 export ADB_BIN=/path/to/adb）" >&2; exit 1; }

SERIAL_ARGS=()
if [ -n "${ANDROID_SERIAL:-}" ]; then
  SERIAL_ARGS=(-s "$ANDROID_SERIAL")
fi

"$ADB_BIN" "${SERIAL_ARGS[@]}" get-state >/dev/null 2>&1 || {
  echo "设备未连接或未授权。真机/模拟器均可；多设备请 export ANDROID_SERIAL=<serial>" >&2
  "$ADB_BIN" devices -l >&2 || true
  exit 1
}

FOCUS="$("$ADB_BIN" "${SERIAL_ARGS[@]}" shell dumpsys window 2>/dev/null | grep -m1 mCurrentFocus | sed 's/.* //;s/}$//' || true)"
DPI="$("$ADB_BIN" "${SERIAL_ARGS[@]}" shell wm density | grep -o '[0-9]\+' | tail -1)"
SIZE="$("$ADB_BIN" "${SERIAL_ARGS[@]}" shell wm size | sed 's/.*: //')"
SERIAL="$("$ADB_BIN" "${SERIAL_ARGS[@]}" get-serialno 2>/dev/null || echo unknown)"

"$ADB_BIN" "${SERIAL_ARGS[@]}" exec-out screencap -p > "$OUT/$PAGE.png"

# 无损压缩截图
"$(dirname "$0")/compress_png.sh" "$OUT/$PAGE.png" || true
if ! "$ADB_BIN" "${SERIAL_ARGS[@]}" shell uiautomator dump /sdcard/qpy_ui.xml >/dev/null 2>&1; then
  echo "uiautomator dump 失败：该页面可能禁止抓取，只用截图目测" >&2
  rm -f "$OUT/$PAGE.xml" "$OUT/$PAGE.measure.md"
else
  "$ADB_BIN" "${SERIAL_ARGS[@]}" exec-out cat /sdcard/qpy_ui.xml > "$OUT/$PAGE.xml"
  python3 "$(dirname "$0")/measure.py" "$OUT/$PAGE.xml" "$DPI" "$PAGE" > "$OUT/$PAGE.measure.md"
fi

{
  echo "- serial: $SERIAL"
  echo "- Activity: $FOCUS"
  echo "- 屏幕: $SIZE @ ${DPI}dpi（dp = px * 160 / dpi）"
  echo "- 抓取: $(date '+%Y-%m-%d %H:%M %Z')"
  echo "- 落盘: $OUT（不做 git 管理）"
} > "$OUT/$PAGE.meta.txt"

# append index line
INDEX="$OUT/00-index.md"
if [ ! -f "$INDEX" ]; then
  echo "# android-shots · $MODULE" > "$INDEX"
  echo "" >> "$INDEX"
  echo "| 文件 | 页面/态 | serial | 备注 |" >> "$INDEX"
  echo "|---|---|---|---|" >> "$INDEX"
fi
if ! grep -q "| \`$PAGE.png\` |" "$INDEX" 2>/dev/null; then
  echo "| \`$PAGE.png\` | $PAGE | $SERIAL | |" >> "$INDEX"
fi

echo "OK -> $OUT/$PAGE.{png,xml,measure.md,meta.txt}"
echo "Activity: $FOCUS  serial: $SERIAL"
