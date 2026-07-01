---
name: llm-wiki
description: "Karpathy LLM Wiki: 构建和查询互链 markdown 知识库。当用户要求创建 wiki、摄入来源、查询 wiki、检查 wiki 健康度、或提到 wiki/知识库/笔记时使用。"
---

# Karpathy LLM Wiki

构建和维护一个持久化、不断增值的互链 markdown 知识库。
基于 [Karpathy 的 LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)。

与传统 RAG 不同，Wiki 一次编译知识并保持更新。交叉引用已存在，矛盾已标记。

## 何时使用

- 创建/构建 wiki 或知识库
- 摄入/添加来源到 wiki
- 提问且 wiki 已存在
- 检查/审计 wiki 健康度

## Wiki 位置

`WIKI_PATH` 环境变量，未设置则 `~/wiki`。

## 目录结构

```
wiki/
├── SCHEMA.md           # 约定、标签分类法（活文档）
├── index.md            # 分区内容目录
├── log.md              # 操作日志（只追加）
├── raw/                # 不可变的原始来源
│   ├── articles/       # 网络文章
│   ├── papers/         # PDF、论文
│   ├── transcripts/    # 会议笔记
│   └── assets/         # 图片
├── entities/           # 实体页面
├── concepts/           # 概念页面
├── comparisons/        # 比较页面
├── overviews/          # 总览页面
└── queries/            # 归档的查询结果
```

三层：raw/（不可变）→ wiki 页面（代理维护）→ SCHEMA.md（活文档，协同进化）。

## 搜索方式

| 规模 | 方式 |
|------|------|
| < 100 页面 | 读 index.md + `search_files` 关键词 |
| 100+ 页面 | BM25 搜索（Node.js 脚本，见 `references/bm25-search.js`） |

BM25 搜索使用纯 Node.js 实现，零外部依赖：
```bash
node references/bm25-search.js --reindex   # 首次或内容变化后
node references/bm25-search.js "查询内容"  # 搜索
```

## 恢复已有 Wiki（每次会话必做）

① 读 SCHEMA.md → ② 读 index.md → ③ 读 log.md 最后 20-30 条 → ④ 大型 wiki 用 BM25 搜当前主题。
完成定向后才能操作。防止重复页面、遗漏交叉引用、违反约定。

## 两阶段编译

**阶段 1 — 概念提取：** 先读完全部来源，提取所有实体和概念。全部提取完再写页面。
**阶段 2 — 页面生成：** 跨来源共享概念合并为一个页面，各段落追加引用标记。

## 初始化新 Wiki

1. 确定路径（`WIKI_PATH` 或询问用户，默认 `~/wiki`）
2. 创建目录结构
3. 询问领域 — 要具体
4. 写 SCHEMA.md（模板见 `templates/schema-template.md`）
5. 写 index.md（模板见 `templates/index-template.md`）
6. 写 log.md（模板见 `templates/log-template.md`）
7. 告诉用户：SCHEMA.md 是活文档，不需要一开始就完美

## 核心操作

### Ingest（摄入）

① 捕获来源（URL→`raw/articles/`，PDF→`raw/papers/`，文本→适当子目录）
   - 添加 raw frontmatter（source_url, ingested, sha256）
   - 图片下载到 `raw/assets/`，替换远程 URL
② 与用户讨论要点（自动化场景跳过）
③ 阶段 1：从所有来源提取概念，跨来源共享概念标记为合并候选
④ 阶段 2：写/更新页面 — 满足阈值才创建，交叉引用至少 2 个，引用标记段落来源
⑤ 更新 index.md（按 kind 分区，字母顺序）+ log.md
⑥ 报告变更

单个来源可能触发 5-15 个页面更新。这是正常的增值效应。

### Query（查询）

① 读 index.md 找相关页面 ② 搜索（search_files 或 BM25）③ 读页面 ④ 综合回答，引用 `[[页面]]`
⑤ 有价值的答案归档到 queries/ 或 comparisons/（简单查找不归档）⑥ 更新 log.md

### Lint（检查）

① 孤儿页面（零入站链接）② 断裂 wikilinks ③ 索引完整性 ④ Frontmatter 验证
⑤ 来源新鲜度（stale/orphaned）⑥ 矛盾页面 ⑦ 质量信号（confidence < 0.5）
⑧ 引用验证 ⑨ 来源漂移（sha256 不匹配）⑩ 页面大小（> 200 行）⑪ 标签审计
⑫ 日志轮转（> 500 条）⑬ 数据差距检测 ⑭ 建议新来源 ⑮ 报告发现 ⑯ 更新 log.md

## 页面阈值

- 创建：2+ 来源 OR 核心主题
- 不创建：附带提及、次要细节
- 拆分：> 200 行
- 归档：内容被取代 → `_archive/`

## 批量摄入

先读全部来源 → 一次性提取概念 → 一次性创建/更新页面 → 一次性更新 index → 一条日志

## 归档

移到 `_archive/`，从 index 移除，wikilink 改为纯文本 + "(已归档)"，记录操作

## 常见陷阱

- **永远不要修改 raw/** — 来源不可变，更正写在 wiki 页面
- **总是先定向** — 跳过会导致重复和遗漏交叉引用
- **必须两阶段编译** — 逐个来源处理会导致重复页面
- **总是更新 index + log** — 跳过会让 wiki 退化
- **不要为附带提及创建页面** — 遵循阈值
- **每个页面至少 2 个出站链接** — 孤立页面不可见
- **Frontmatter 必需** — 启用搜索、过滤、陈旧检测
- **标签必须来自分类法** — 先在 SCHEMA 添加再使用
- **显式处理矛盾** — 不要静默覆盖，标记 contradictedBy
- **多来源合并调 frontmatter** — confidence 取最小值，provenanceState 设 merged
- **sources 用 bare filename** — 不加 `raw/` 前缀
- **图片要本地化** — 下载到 raw/assets/ 替换远程 URL

## 模板和参考

- SCHEMA.md 模板：`templates/schema-template.md`
- index.md 模板：`templates/index-template.md`
- log.md 模板：`templates/log-template.md`
- 页面类型详解：`references/page-types.md`
- 引用语法详解：`references/citations.md`
- BM25 搜索脚本：`references/bm25-search.js`
- BM25 算法说明：`references/bm25.md`
