# skill: harmony-to-kmp (~/.agents/skills/harmony-to-kmp)
# adapted from transform-harmony shots/compare pipeline; target UI = KMP/CMP OHOS
#!/usr/bin/env bash
# KMP/CMP OHOS 对拍入口（与 verify_harmony.sh 同实现）。
# 目标 UI 为 Compose Multiplatform on OHOS（harmonyApp 推包后的前台页），
# 视觉真值仍来自 SHOT_PLATFORM=android|ios 桌面截图。
# 用法同 verify_harmony.sh: verify_ohos.sh <页面名> <模块名> [--threshold 0.01]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
exec bash "$ROOT/verify_harmony.sh" "$@"
