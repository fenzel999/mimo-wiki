#!/usr/bin/env bash
# mimo-wiki 卸载脚本 (macOS / Linux)
# 用法:
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/uninstall.sh | bash
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/uninstall.sh | bash -s -- --global

set -e

TARGET=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)  TARGET="$HOME/.mimocode"; shift ;;
    --dir)     TARGET="$2"; shift 2 ;;
    *)         TARGET="$(pwd)"; break ;;
  esac
done
TARGET="${TARGET:-$(pwd)}"

echo "从 $TARGET 卸载 mimo-wiki"
echo ""

# 删除文件
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

# 清理空目录
for dir in "skills/llm-wiki/references" "skills/llm-wiki/templates" "skills/llm-wiki" "skills"; do
  rmdir "$TARGET/$dir" 2>/dev/null && echo "  删除空目录: $dir" || true
done

echo ""
echo "完成: 删除了 $removed 个文件"
echo "注意: wiki 数据目录（默认 ~/wiki）未删除，需要手动删除"
