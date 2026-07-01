#!/bin/bash
# BM25 搜索 — 纯 bash + sqlite3，零外部依赖
# 用法: bash bm25-search.sh "查询内容"
#       bash bm25-search.sh --reindex  (重建索引)

set -e

WIKI_PATH="${WIKI_PATH:-$HOME/wiki}"
DB="$WIKI_PATH/.wiki-index.db"

# 排除的目录
EXCLUDE_DIRS=("raw" ".obsidian" "_archive" ".git" "node_modules")

reindex() {
    echo "重建索引: $WIKI_PATH"

    # 删除旧索引
    rm -f "$DB"

    # 创建 FTS5 虚拟表
    sqlite3 "$DB" <<'SQL'
CREATE VIRTUAL TABLE IF NOT EXISTS wiki_fts USING fts5(
    path,
    title,
    content,
    tags,
    kind,
    tokenize='unicode61'
);
SQL

    # 遍历 wiki 目录，收集 .md 文件
    local count=0
    while IFS= read -r -d '' file; do
        local rel="${file#$WIKI_PATH/}"

        # 读取文件内容
        local content
        content=$(cat "$file" 2>/dev/null) || continue

        # 提取 frontmatter
        local title="" tags="" kind="" body=""
        if [[ "$content" == ---* ]]; then
            local fm
            fm=$(echo "$content" | sed -n '2,/^---$/p' | head -n -1)
            title=$(echo "$fm" | grep -oP '^title:\s*\K.*' || echo "")
            tags=$(echo "$fm" | grep -oP '^tags:\s*\K.*' || echo "")
            kind=$(echo "$fm" | grep -oP '^kind:\s*\K.*' || echo "")
            body=$(echo "$content" | sed -n '/^---$/,$ p' | tail -n +2)
        else
            body="$content"
            title=$(echo "$content" | head -1 | sed 's/^#\s*//')
        fi

        # 清理 body：去掉 wikilink 语法、引用标记
        body=$(echo "$body" | sed 's/\[\[\([^]|]*\)\(|[^]]*\)\?\]\]/\1/g' | sed 's/\^\[[^]]*\]//g')

        # 转义单引号
        rel="${rel//\'/\'\'}"
        title="${title//\'/\'\'}"
        body="${body//\'/\'\'}"
        tags="${tags//\'/\'\'}"
        kind="${kind//\'/\'\'}"

        sqlite3 "$DB" "INSERT INTO wiki_fts(path, title, content, tags, kind) VALUES('$rel', '$title', '$body', '$tags', '$kind');"

        count=$((count + 1))
    done < <(find "$WIKI_PATH" -name '*.md' -print0 $(printf -- '-not -path "*/%s/*" ' "${EXCLUDE_DIRS[@]}") 2>/dev/null)

    echo "索引完成: $count 个页面"
}

search() {
    local query="$1"

    if [ ! -f "$DB" ]; then
        echo "索引不存在，先重建..."
        reindex
        echo ""
    fi

    # FTS5 BM25 搜索，rank 越小越相关
    echo "查询: $query"
    echo "结果:"
    echo ""

    sqlite3 -separator '|' "$DB" <<SQL
SELECT
    path,
    title,
    kind,
    printf('%.2f', rank) as score
FROM wiki_fts
WHERE wiki_fts MATCH '$(echo "$query" | sed "s/'/''/g")'
ORDER BY rank
LIMIT 10;
SQL
}

# 主逻辑
case "${1:-}" in
    --reindex)
        reindex
        ;;
    --help|-h)
        echo "用法:"
        echo "  bash bm25-search.sh '查询内容'     搜索 wiki"
        echo "  bash bm25-search.sh --reindex      重建索引"
        echo "  bash bm25-search.sh --help         显示帮助"
        echo ""
        echo "环境变量:"
        echo "  WIKI_PATH    wiki 目录路径（默认 ~/wiki）"
        ;;
    "")
        echo "用法: bash bm25-search.sh '查询内容'"
        echo "      bash bm25-search.sh --reindex"
        exit 1
        ;;
    *)
        search "$1"
        ;;
esac
