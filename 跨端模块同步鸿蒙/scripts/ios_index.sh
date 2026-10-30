#!/usr/bin/env bash
# 从关键词反查 iOS 侧证据：类文件、界面文件、资源名。只读，不改任何 iOS 工程。
# 用法: ios_index.sh <关键词>
set -euo pipefail

KEY="${1:?用法: ios_index.sh <关键词>}"
PODS="${PODS_ROOT:-$HOME/Desktop/Pods}"
FULL="${IOS_SOURCE_ROOT:-$HOME/Desktop/少儿口语训练营-iOS源码/code}"
[ -d "$PODS" ] || [ -d "$FULL" ] || {
  echo "iOS 源码根不存在。设置 PODS_ROOT / IOS_SOURCE_ROOT" >&2
  exit 1
}

dedupe() {
  awk '{ key=$0; sub(/.*(Pods|code)\//, "", key); if (!(key in seen)) { seen[key]=1; print $0 } }'
}

ROOTS=()
[ -d "$PODS" ] && ROOTS+=("$PODS")
[ -d "$FULL" ] && ROOTS+=("$FULL")

FILES=$( { for r in "${ROOTS[@]}"; do
            grep -rl -i --include='*.h' --include='*.m' --include='*.mm' --include='*.swift' "$KEY" "$r" 2>/dev/null || true
          done; } | grep -i "$KEY" | dedupe | head -40 )

echo "### 1. 类文件"
echo "${FILES:-（无命中）}"

echo
echo "### 2. 界面文件（xib / storyboard）"
{ for r in "${ROOTS[@]}"; do
    find "$r" \( -iname "*${KEY}*.xib" -o -iname "*${KEY}*.storyboard" \) 2>/dev/null || true
  done; } | dedupe | head -20

echo
echo "### 3. 这些类引用到的资源名"
if [ -n "$FILES" ]; then
  { echo "$FILES" | tr '\n' ' ' | xargs grep -ohE '[A-Za-z]*Image\(@"[^"]+"\)' 2>/dev/null | sed -E 's/.*\(@"//; s/"\)//' || true
    echo "$FILES" | tr '\n' ' ' | xargs grep -ohE '@?"[A-Za-z0-9_./-]+\.(mp3|aiff|wav|gif|json|png|jpg)"' 2>/dev/null | sed -E 's/^@?"//; s/"$//' || true
  } | grep -v '^$' | sort -u | head -40
fi

echo
echo "### 4. 命中正文（确认页面归属）"
{ for r in "${ROOTS[@]}"; do
    grep -rn -i --include='*.m' --include='*.swift' -e 'interface' -e 'class ' "$r" 2>/dev/null || true
  done; } | grep -i "$KEY" | dedupe | head -30
