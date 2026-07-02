#!/usr/bin/env bash
# mimo-wiki 安装/卸载 (macOS / Linux)
#
# 安装:
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --local
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --global
#
# 卸载:
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --uninstall
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --uninstall --local
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --uninstall --global

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

# ─── 解析参数 ──────────────────────────────────────────────
ACTION="install"  # install | uninstall
SCOPE=""          # local | global | "" = ask

for arg in "$@"; do
  case "$arg" in
    --local)    SCOPE="local" ;;
    --global)   SCOPE="global" ;;
    --uninstall) ACTION="uninstall" ;;
  esac
done

# ─── 未指定则交互 ──────────────────────────────────────────
if [ -z "$SCOPE" ]; then
  echo "========================================================"
  echo "  mimo-wiki ${ACTION^}er"
  echo "========================================================"
  echo ""
  echo "  1) 当前项目  → $(pwd)"
  echo "  2) 全局       → $HOME/.config/mimocode/"
  echo ""
  >&2 read -p "  选择 [1/2]: " CHOICE
  case "$CHOICE" in
    1|"1)")
      SCOPE="local"
      ;;
    2|"2)")
      SCOPE="global"
      ;;
    *)
      >&2 echo "  无效选择: $CHOICE (1=本地, 2=全局)"
      exit 1
      ;;
  esac
  if [ "$ACTION" = "uninstall" ]; then
    >&2 echo ""
    >&2 read -p "  确认卸载 $( [ "$SCOPE" = "local" ] && echo "$(pwd)" || echo "$HOME/.config/mimocode" ) 吗? [y/N]: " CONFIRM
    [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ] && { echo "  已取消"; exit 0; }
  fi
fi

# ─── 目标路径 ──────────────────────────────────────────────
if [ "$SCOPE" = "global" ]; then
  TARGET="$HOME/.config/mimocode"
else
  TARGET="$(pwd)"
fi

# ─── 安装 ──────────────────────────────────────────────────
install() {
  echo "mimo-wiki 安装到: $TARGET"
  echo ""
  local installed=0 skipped=0
  for f in "${FILES[@]}"; do
    local dest="$TARGET/$f"
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
}

# ─── 卸载 ──────────────────────────────────────────────────
uninstall() {
  echo "从 $TARGET 卸载 mimo-wiki"
  echo ""
  # 倒序删除（文件逆序→然后删除空目录）
  local removed=0
  for ((i=${#FILES[@]}-1; i>=0; i--)); do
    local dest="$TARGET/${FILES[i]}"
    if [ -f "$dest" ]; then
      rm "$dest"
      echo "  删除: ${FILES[i]}"
      removed=$((removed + 1))
    fi
  done
  for dir in "skills/llm-wiki/references" "skills/llm-wiki/templates" "skills/llm-wiki" "skills"; do
    rmdir "$TARGET/$dir" 2>/dev/null && echo "  删除空目录: $dir" || true
  done
  echo ""
  echo "完成: 删除了 $removed 个文件"
  echo "注意: wiki 数据目录（默认 ~/wiki）未删除，需要手动删除"
}

# ─── 执行 ──────────────────────────────────────────────────
case "$ACTION" in
  install)   install ;;
  uninstall) uninstall ;;
esac