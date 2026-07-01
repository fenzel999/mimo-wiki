#!/usr/bin/env bash
# mimo-wiki 安装到全局 (macOS / Linux)
# 用法: curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install-global.sh | bash

set -e

REPO="fenzel999/mimo-wiki"
BRANCH="master"
BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
TARGET="$HOME/.config/mimocode"

FILES=(
  "AGENTS.md"
  "skills/llm-wiki/SKILL.md"
  "skills/llm-wiki/templates/schema-template.md"
  "skills/llm-wiki/templates/index-template.md"
  "skills/llm-wiki/templates/log-template.md"
  "skills/llm-wiki/references/bm25-search.js"
  "skills/llm-wiki/references/bm25.md"
  "skills/llm-wiki/references/page-types.md"
  "skills/llm-wiki/references/citations.md"
)

echo "mimo-wiki 全局安装到: $TARGET"
echo ""

installed=0
skipped=0

for f in "${FILES[@]}"; do
  dest="$TARGET/$f"
  if [ -f "$dest" ]; then
    echo "  跳过（已存在）: $f"
    skipped=$((skipped + 1))
    continue
  fi
  mkdir -p "$(dirname "$dest")"
  curl -sSL "$BASE/$f" -o "$dest"
  echo "  安装: $f"
  installed=$((installed + 1))
done

echo ""
echo "完成: $installed 已安装, $skipped 跳过"
echo ""
echo "下一步: 在 MiMo Code 中说 \"帮我创建一个新的 LLM Wiki\""
