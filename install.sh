#!/usr/bin/env bash
# mimo-wiki 安装脚本 (macOS / Linux)
# 用法:
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --global
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --dir ~/my-project

set -e

REPO="fenzel999/mimo-wiki"
BRANCH="master"
BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

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

# 解析参数
TARGET=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)  TARGET="$HOME/.mimocode"; shift ;;
    --dir)     TARGET="$2"; shift 2 ;;
    --help|-h)
      echo "用法:"
      echo "  curl -sSL $BASE/install.sh | bash              安装到当前目录"
      echo "  curl -sSL $BASE/install.sh | bash -s -- --global   安装到全局"
      echo "  curl -sSL $BASE/install.sh | bash -s -- --dir PATH  安装到指定目录"
      exit 0 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

TARGET="${TARGET:-$(pwd)}"
echo "mimo-wiki 安装到: $TARGET"
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
