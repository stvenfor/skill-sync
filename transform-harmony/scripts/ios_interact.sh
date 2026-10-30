#!/usr/bin/env bash
# iOS 交互到达态（本轮薄封装 / 文档入口）。
# 稳定截图优先：深链打开目标态 → ios_capture.sh；或人工点到目标态再截。
# XCUITest / 坐标点击本轮不强制依赖（易碎、需工程内测试 target）。
# 用法（提示）:
#   ios_interact.sh help
set -euo pipefail

cmd="${1:-help}"
case "$cmd" in
  help|--help|-h)
    cat << 'HELP'
ios_interact.sh — iOS 到达态说明（stub）

推荐顺序：
  1. 深链 / debug Shot 入口直达目标态（与 shots-manifest open 一致）
  2. 人工在真机/模拟器点到目标态
  3. bash scripts/ios_capture.sh <page> <module>

不在本轮提供：通用 XCUITest tap/swipe Runner（需业务仓测试 target）。
多设备：export IOS_UDID=<udid>（或 IOS_SERIAL）。
视觉真值根：~/Desktop/ios-shots/<module>/（IOS_SHOTS_ROOT）。
HELP
    ;;
  *)
    echo "未知子命令: $cmd（仅 support: help）。请用深链或人工导航后 ios_capture.sh。" >&2
    exit 2
    ;;
esac
