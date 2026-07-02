#!/usr/bin/env bash
# mimo-wiki 安装/卸载 (macOS / Linux)
#
# 安装（交互选择位置）:
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash
#
# 指定参数跳过交互:
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --local
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --global
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --hermes
#
# 卸载:
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --uninstall
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --uninstall --local
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --uninstall --global
#   curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --uninstall --hermes

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
ACTION="install"
SCOPE=""

for arg in "$@"; do
  case "$arg" in
    --local)    SCOPE="local" ;;
    --global)   SCOPE="global" ;;
    --hermes)   SCOPE="hermes" ;;
    --uninstall) ACTION="uninstall" ;;
  esac
done

# ─── 未指定则交互 ──────────────────────────────────────────
if [ -z "$SCOPE" ]; then
  echo "========================================================"
  echo "  mimo-wiki ${ACTION^}er"
  echo "========================================================"
  echo ""
  echo "  1) 当前项目 (MiMo / Claude Code / Codex)"
  echo "  2) 所有项目  → ~/.config/mimocode/"
  echo "  3) Hermes     → ~/.hermes/skills/ (项目级仍需AGENTS.md)"
  echo ""
  >&2 read -p "  选择 [1/2/3]: " CHOICE
  case "$CHOICE" in
    1|"1") SCOPE="local" ;;
    2|"2") SCOPE="global" ;;
    3|"3") SCOPE="hermes" ;;
    *)
      >&2 echo "  无效选择: $CHOICE (1=当前项目, 2=全局, 3=Hermes)"
      exit 1
      ;;
  esac
  if [ "$ACTION" = "uninstall" ]; then
    case "$SCOPE" in
      local)  TARGET_LABEL="$(pwd)" ;;
      global) TARGET_LABEL="$HOME/.config/mimocode" ;;
      hermes) TARGET_LABEL="$HOME/.hermes/skills/llm-wiki" ;;
    esac
    >&2 echo ""
    >&2 read -p "  确认卸载 $TARGET_LABEL 吗? [y/N]: " CONFIRM
    [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ] && { echo "  已取消"; exit 0; }
  fi
fi

# ─── 目标路径 ──────────────────────────────────────────────
case "$SCOPE" in
  global) TARGET="$HOME/.config/mimocode" ;;
  hermes) TARGET="$HOME/.hermes" ;;
  *)      TARGET="$(pwd)" ;;
esac

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
  case "$SCOPE" in
    hermes)
      echo "Hermes: skill 已装到 ~/.hermes/skills/llm-wiki/，/reload-skills 刷新即可。"
      echo "AGENTS.md 需放在项目根目录（Hermes 只读当前工作目录下的 AGENTS.md）。"
      ;;
    global)
      echo "下一步: 在 MiMo Code 中说 \"帮我创建一个新的 LLM Wiki\""
      ;;
    *)
      echo "下一步: 在 MiMo Code 中说 \"帮我创建一个新的 LLM Wiki\""
      ;;
  esac
}

# ─── 卸载 ──────────────────────────────────────────────────
uninstall() {
  echo "从 $TARGET 卸载 mimo-wiki"
  echo ""
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

case "$ACTION" in
  install)   install ;;
  uninstall) uninstall ;;
esac