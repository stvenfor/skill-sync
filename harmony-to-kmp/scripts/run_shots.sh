#!/usr/bin/env bash
# skill: harmony-to-kmp (~/.agents/skills/harmony-to-kmp)
# 默认 SHOT_PLATFORM=harmony：采集鸿蒙原生真值到 ~/Desktop/harmony-shots
# Android/iOS capture 仅旁证（显式 SHOT_PLATFORM=android|ios）
# 用法:
#   run_shots.sh <module>                 # 提示在真值端打开目标态后截
#   run_shots.sh --page <name> <module>   # 单页（须已打开鸿蒙原生对应态）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
PLATFORM="${SHOT_PLATFORM:-harmony}"
case "$PLATFORM" in
  ios) SHOTS_ROOT="${IOS_SHOTS_ROOT:-$HOME/Desktop/ios-shots}"; CAP="$ROOT/ios_capture.sh" ;;
  android) SHOTS_ROOT="${ANDROID_SHOTS_ROOT:-$HOME/Desktop/android-shots}"; CAP="$ROOT/capture.sh" ;;
  harmony|ohos-native|*) PLATFORM=harmony; SHOTS_ROOT="${HARMONY_SHOTS_ROOT:-$HOME/Desktop/harmony-shots}"; CAP="$ROOT/harmony_shot.sh" ;;
esac

if [ "${1:-}" = "--page" ]; then
  PAGE="${2:?}"
  MODULE="${3:?}"
  exec "$CAP" "$PAGE" "$MODULE"
fi

MODULE="${1:?用法: run_shots.sh <module>  或  run_shots.sh --page <name> <module>}"
mkdir -p "$SHOTS_ROOT/$MODULE"
echo "SHOT_PLATFORM=$PLATFORM  模块目录: $SHOTS_ROOT/$MODULE"
echo "请在【鸿蒙原生】打开目标态后执行: $CAP <page-state> $MODULE"
echo "清单模板见 skill templates/shots-manifest.example.yaml"
