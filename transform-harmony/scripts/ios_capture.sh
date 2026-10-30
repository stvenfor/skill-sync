#!/usr/bin/env bash
# 抓当前 iOS 前台页截图（物理真机或已启动模拟器）。
# 本脚本只负责 iOS；Android 请用 capture.sh。
# 用法: ios_capture.sh <页面名> [模块名]
# 落盘: $IOS_SHOTS_ROOT/<module>/  默认 ~/Desktop/ios-shots/<module>/
# 环境: SHOT_PLATFORM=ios（派单约定）；IOS_UDID 或 IOS_SERIAL 钉死设备；FORCE_RECAPTURE=1 强制重截
# 产物不做 git 管理；PNG 截后自动无损压缩。
# 前置：Xcode；真机须信任本机、开启开发者模式；idevicescreenshot 需 libimobiledevice（可选）。
set -euo pipefail

PAGE="${1:?用法: ios_capture.sh <页面名> [模块名]}"
MODULE="${2:-$PAGE}"
SHOTS_ROOT="${IOS_SHOTS_ROOT:-$HOME/Desktop/ios-shots}"
OUT="$SHOTS_ROOT/$MODULE"
mkdir -p "$OUT"

PNG="$OUT/$PAGE.png"

# 已有非空 PNG 默认复用（与 Android capture 一致）
if [ -f "$PNG" ] && [ -s "$PNG" ] && [ "${FORCE_RECAPTURE:-0}" != "1" ]; then
  echo "SKIP_EXISTING -> $PNG（设 FORCE_RECAPTURE=1 强制重截）"
  exit 0
fi

UDID="${IOS_UDID:-${IOS_SERIAL:-}}"

pick_udid_if_empty() {
  if [ -n "$UDID" ]; then
    return 0
  fi
  # 优先物理设备（devicectl），再 idevice_id，再已启动模拟器
  if command -v xcrun >/dev/null 2>&1; then
    local listed
    listed="$(xcrun devicectl list devices 2>/dev/null || true)"
    # 取第一行含 Identifier / UDID 形态的已连接设备（启发式）
    UDID="$(printf '%s\n' "$listed" | grep -Eo '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}|[0-9A-Fa-f]{40}' | head -1 || true)"
  fi
  if [ -z "$UDID" ] && command -v idevice_id >/dev/null 2>&1; then
    UDID="$(idevice_id -l 2>/dev/null | head -1 || true)"
  fi
  if [ -z "$UDID" ] && command -v xcrun >/dev/null 2>&1; then
    UDID="$(xcrun simctl list devices booted 2>/dev/null | grep -Eo '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}' | head -1 || true)"
    if [ -z "$UDID" ]; then
      # booted 关键字行
      if xcrun simctl list devices 2>/dev/null | grep -q '(Booted)'; then
        UDID="booted"
      fi
    fi
  fi
  if [ -z "$UDID" ]; then
    echo "找不到 iOS 设备。请：连接并信任真机，或启动模拟器；多设备时 export IOS_UDID=<udid>（或 IOS_SERIAL）。" >&2
    if command -v xcrun >/dev/null 2>&1; then
      xcrun devicectl list devices 2>&1 || true
      xcrun simctl list devices booted 2>&1 || true
    fi
    command -v idevice_id >/dev/null 2>&1 && idevice_id -l 2>&1 || true
    exit 1
  fi
}

is_simulator_udid() {
  local u="$1"
  [ "$u" = "booted" ] && return 0
  # 模拟器 UUID 通常含连字符；40 位无连字符多为物理设备
  if [[ "$u" == *-* ]] && command -v xcrun >/dev/null 2>&1; then
    if xcrun simctl list devices 2>/dev/null | grep -q "$u"; then
      return 0
    fi
  fi
  return 1
}

take_screenshot() {
  local dest="$1"
  local err=""

  # a) Xcode devicectl（物理设备优先尝试）
  if command -v xcrun >/dev/null 2>&1 && ! is_simulator_udid "$UDID"; then
    # 尝试若干已知子命令；任一成功即返回
    if xcrun devicectl device info screenshot --device "$UDID" --output "$dest" >/dev/null 2>&1; then
      return 0
    fi
    if xcrun devicectl device process screenshot --device "$UDID" --output "$dest" >/dev/null 2>&1; then
      return 0
    fi
    # 部分 Xcode：xcdevice
    if xcrun xcdevice take-screenshot --device "$UDID" --output "$dest" >/dev/null 2>&1; then
      return 0
    fi
    err="${err}devicectl/xcdevice 截图失败；"
  fi

  # b) idevicescreenshot（libimobiledevice，物理真机）
  if command -v idevicescreenshot >/dev/null 2>&1 && ! is_simulator_udid "$UDID"; then
    if idevicescreenshot -u "$UDID" "$dest" >/dev/null 2>&1 || idevicescreenshot "$dest" >/dev/null 2>&1; then
      return 0
    fi
    err="${err}idevicescreenshot 失败；"
  fi

  # c) 模拟器：simctl io screenshot
  if command -v xcrun >/dev/null 2>&1; then
    local sim_target="$UDID"
    if is_simulator_udid "$UDID" || [ "$UDID" = "booted" ]; then
      if xcrun simctl io "$sim_target" screenshot "$dest" >/dev/null 2>&1; then
        return 0
      fi
      err="${err}simctl screenshot 失败；"
    elif [ -z "${err}" ]; then
      # 未识别为模拟器且物理通路都失败时，仍试 booted 模拟器一次
      if xcrun simctl list devices 2>/dev/null | grep -q '(Booted)'; then
        if xcrun simctl io booted screenshot "$dest" >/dev/null 2>&1; then
          UDID="booted"
          return 0
        fi
      fi
    fi
  fi

  echo "iOS 截图失败（udid=$UDID）。已尝试: ${err:-无可用工具}" >&2
  echo "请确认：1) Xcode 已装且命令行工具可用  2) 真机已信任/开发者模式  3) 可选 brew install libimobiledevice  4) 模拟器已 Booted" >&2
  exit 1
}

pick_udid_if_empty
take_screenshot "$PNG"

[ -f "$PNG" ] && [ -s "$PNG" ] || { echo "截图文件为空: $PNG" >&2; exit 1; }

"$(dirname "$0")/compress_png.sh" "$PNG" || true

{
  echo "- platform: ios"
  echo "- udid: $UDID"
  echo "- 抓取: $(date '+%Y-%m-%d %H:%M %Z')"
  echo "- 落盘: $OUT（不做 git 管理）"
  echo "- SHOT_PLATFORM: ${SHOT_PLATFORM:-ios}"
} > "$OUT/$PAGE.meta.txt"

INDEX="$OUT/00-index.md"
if [ ! -f "$INDEX" ]; then
  echo "# ios-shots · $MODULE" > "$INDEX"
  echo "" >> "$INDEX"
  echo "| 文件 | 页面/态 | udid | 备注 |" >> "$INDEX"
  echo "|---|---|---|---|" >> "$INDEX"
fi
if ! grep -q "| \`$PAGE.png\` |" "$INDEX" 2>/dev/null; then
  echo "| \`$PAGE.png\` | $PAGE | $UDID | |" >> "$INDEX"
fi

echo "OK -> $OUT/$PAGE.{png,meta.txt}"
echo "platform: ios  udid: $UDID"
