#!/usr/bin/env bash
# 按 shots-manifest（简化：每行 module page state deep_link 或读 YAML 需 python）批量截图。
# 推荐：有 Instrumentation 用工程内 Runner；本脚本是 adb 快速通路。
# 用法:
#   run_shots.sh <module>                 # 对已停在前台的页，交互提示
#   run_shots.sh --page <name> <module>   # 单页（须已打开）
# 落盘 ~/Desktop/android-shots/<module>/ ，不做 git 管理。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ "${1:-}" = "--page" ]; then
  PAGE="${2:?}"
  MODULE="${3:?}"
  exec "$ROOT/capture.sh" "$PAGE" "$MODULE"
fi

MODULE="${1:?用法: run_shots.sh <module>  或  run_shots.sh --page <name> <module>}"
SHOTS_ROOT="${ANDROID_SHOTS_ROOT:-$HOME/Desktop/android-shots}"
mkdir -p "$SHOTS_ROOT/$MODULE"
echo "模块目录: $SHOTS_ROOT/$MODULE"
echo "请在真机/模拟器打开目标态后执行: $ROOT/capture.sh <page-state> $MODULE"
echo "清单模板见 skill templates/shots-manifest.example.yaml"
