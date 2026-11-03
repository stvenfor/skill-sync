#!/usr/bin/env bash
# skill: harmony-to-kmp (~/.agents/skills/harmony-to-kmp)
# KMP/CMP OHOS 对拍入口（与 verify_harmony.sh 同实现）。
# 视觉真值 = 鸿蒙原生 harmony-shots；候选 = 当前前台 KMP/CMP 包。
# 用法同 verify_harmony.sh: verify_ohos.sh <页面名> <模块名> [--threshold 0.01]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
exec bash "$ROOT/verify_harmony.sh" "$@"
