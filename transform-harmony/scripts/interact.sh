#!/usr/bin/env bash
# Android 交互：点击 / 滑动 / 长按（uiautomator 坐标或比例）。
# 用法:
#   interact.sh tap <x> <y>
#   interact.sh tap_pct <x%> <y%>          # 0-100 相对屏幕
#   interact.sh swipe <x1> <y1> <x2> <y2> [ms]
#   interact.sh swipe_pct <x1%> <y1%> <x2%> <y2%> [ms]
#   interact.sh longpress <x> <y> [ms]
# 评估：adb shell input 可覆盖绝大多数点击与拖动；复杂手势（多指/系统返回除外）优先写进 shots-manifest.actions[]，由 Runner 执行。
set -euo pipefail
ADB_BIN="${ADB_BIN:-$(command -v adb || true)}"
if [ -z "${ADB_BIN}" ] && [ -x "$HOME/Library/Android/sdk/platform-tools/adb" ]; then
  ADB_BIN="$HOME/Library/Android/sdk/platform-tools/adb"
fi
[ -n "${ADB_BIN}" ] && [ -x "$ADB_BIN" ] || { echo "找不到 adb" >&2; exit 1; }
SERIAL_ARGS=(); [ -n "${ANDROID_SERIAL:-}" ] && SERIAL_ARGS=(-s "$ANDROID_SERIAL")

size_xy() {
  local s
  s="$("$ADB_BIN" "${SERIAL_ARGS[@]}" shell wm size | sed 's/.*: //' | tr -d '\r')"
  W="${s%x*}"; H="${s#*x}"
}

CMD="${1:?用法: interact.sh tap|tap_pct|swipe|swipe_pct|longpress ...}"
shift
case "$CMD" in
  tap)
    "$ADB_BIN" "${SERIAL_ARGS[@]}" shell input tap "${1:?}" "${2:?}"
    ;;
  tap_pct)
    size_xy
    X=$(python3 -c "print(int($W * float('$1') / 100))")
    Y=$(python3 -c "print(int($H * float('$2') / 100))")
    "$ADB_BIN" "${SERIAL_ARGS[@]}" shell input tap "$X" "$Y"
    ;;
  swipe)
    "$ADB_BIN" "${SERIAL_ARGS[@]}" shell input swipe "${1:?}" "${2:?}" "${3:?}" "${4:?}" "${5:-300}"
    ;;
  swipe_pct)
    size_xy
    X1=$(python3 -c "print(int($W * float('$1') / 100))")
    Y1=$(python3 -c "print(int($H * float('$2') / 100))")
    X2=$(python3 -c "print(int($W * float('$3') / 100))")
    Y2=$(python3 -c "print(int($H * float('$4') / 100))")
    "$ADB_BIN" "${SERIAL_ARGS[@]}" shell input swipe "$X1" "$Y1" "$X2" "$Y2" "${5:-300}"
    ;;
  longpress)
    "$ADB_BIN" "${SERIAL_ARGS[@]}" shell input swipe "${1:?}" "${2:?}" "$1" "$2" "${3:-800}"
    ;;
  *)
    echo "未知命令: $CMD" >&2; exit 1
    ;;
esac
echo "OK $CMD $*"
