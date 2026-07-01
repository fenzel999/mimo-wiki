#!/usr/bin/env bash
# mimo-wiki 从全局卸载 (macOS / Linux)
# 用法: curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/uninstall-global.sh | bash

set -e

TARGET="$HOME/.config/mimocode"
echo "从 $TARGET 卸载 mimo-wiki"
echo ""

FILES=(
  "skills/llm-wiki/references/bm25-search.js"
  "skills/llm-wiki/references/bm25.md"
  "skills/llm-wiki/references/page-types.md"
  "skills/llm-wiki/references/citations.md"
  "skills/llm-wiki/templates/schema-template.md"
  "skills/llm-wiki/templates/index-template.md"
  "skills/llm-wiki/templates/log-template.md"
  "skills/llm-wiki/SKILL.md"
  "AGENTS.md"
)

removed=0
for f in "${FILES[@]}"; do
  dest="$TARGET/$f"
  if [ -f "$dest" ]; then
    rm "$dest"
    echo "  删除: $f"
    removed=$((removed + 1))
  fi
done

for dir in "skills/llm-wiki/references" "skills/llm-wiki/templates" "skills/llm-wiki" "skills"; do
  rmdir "$TARGET/$dir" 2>/dev/null && echo "  删除空目录: $dir" || true
done

echo ""
echo "完成: 删除了 $removed 个文件"
