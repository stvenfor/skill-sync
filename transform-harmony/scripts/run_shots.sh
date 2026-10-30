#!/usr/bin/env bash
# 按 shots-manifest（简化：每行 module page state deep_link 或读 YAML 需 python）批量截图。
# 推荐：有 Instrumentation 用工程内 Runner；本脚本是 adb 快速通路。
# 用法:
#   run_shots.sh <module>                 # 对已停在前台的页，交互提示
#   run_shots.sh --page <name> <module>   # 单页（须已打开）
# 按 SHOT_PLATFORM=android|ios（默认 android）落盘对应桌面根，不做 git 管理。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
PLATFORM="${SHOT_PLATFORM:-android}"
case "$PLATFORM" in
  ios) SHOTS_ROOT="${IOS_SHOTS_ROOT:-$HOME/Desktop/ios-shots}"; CAP="$ROOT/ios_capture.sh" ;;
  android|*) PLATFORM=android; SHOTS_ROOT="${ANDROID_SHOTS_ROOT:-$HOME/Desktop/android-shots}"; CAP="$ROOT/capture.sh" ;;
esac

if [ "${1:-}" = "--page" ]; then
  PAGE="${2:?}"
  MODULE="${3:?}"
  exec "$CAP" "$PAGE" "$MODULE"
fi

MODULE="${1:?用法: run_shots.sh <module>  或  run_shots.sh --page <name> <module>}"
mkdir -p "$SHOTS_ROOT/$MODULE"
echo "SHOT_PLATFORM=$PLATFORM  模块目录: $SHOTS_ROOT/$MODULE"
echo "请在目标端打开目标态后执行: $CAP <page-state> $MODULE"
echo "清单模板见 skill templates/shots-manifest.example.yaml"
