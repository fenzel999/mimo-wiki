---
name: llm-wiki
description: "Karpathy LLM Wiki: 构建和查询互链 markdown 知识库。包含完整模板、摄入/查询/检查步骤和常见陷阱。当用户要求创建 wiki、摄入来源、查询 wiki、检查 wiki 健康度、或提到 wiki/知识库/笔记时使用。"
---

# Karpathy LLM Wiki — 详细操作手册

构建和维护一个持久化、不断增值的互链 markdown 知识库。
基于 [Andrej Karpathy 的 LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)。

与传统 RAG（每次查询从零开始重新发现知识）不同，Wiki 一次编译知识并保持更新。
交叉引用已经存在，矛盾已被标记，综合分析反映了所有已摄入的内容。

## 何时使用此技能

当用户做以下事情时使用：
- 要求创建、构建或开始一个 wiki 或知识库
- 要求摄入、添加或处理一个来源到 wiki
- 提出问题且已存在配置路径的 wiki
- 要求检查、审计或健康检查 wiki
- 在研究上下文中提到 wiki、知识库或"笔记"

## Wiki 位置

通过环境变量 `WIKI_PATH` 设置。如果未设置，默认 `~/wiki`。

## 三层架构

```
wiki/
├── SCHEMA.md           # 约定、结构规则、领域配置
├── index.md            # 分区内容目录，每页一行摘要
├── log.md              # 按时间顺序的操作日志（只追加，每年轮转）
├── raw/                # 第 1 层：不可变的原始来源
│   ├── articles/       # 网络文章、剪报
│   ├── papers/         # PDF、arxiv 论文
│   ├── transcripts/    # 会议笔记、访谈
│   └── assets/         # 图片、图表
├── entities/           # 第 2 层：实体页面（人物、组织、产品、模型）
├── concepts/           # 第 2 层：概念/主题页面
├── comparisons/        # 第 2 层：并排分析
├── overviews/          # 第 2 层：领域地图页面
└── queries/            # 第 2 层：值得保留的已归档查询结果
```

1. **原始来源层 (raw/)** — 不可变。代理读取但从不修改。
2. **Wiki 层 (entities/, concepts/, comparisons/, overviews/, queries/)** — 代理拥有的 markdown 文件，由代理创建、更新和交叉引用。
3. **模式层 (SCHEMA.md)** — 定义结构、约定和标签分类法。

## 恢复已有 Wiki（关键 — 每次会话都要做）

当用户有已有 wiki 时，**在做任何事之前必须先定向**：

① **读 `SCHEMA.md`** — 了解领域、约定和标签分类法。
② **读 `index.md`** — 了解有哪些页面和摘要。
③ **读 `log.md` 最后 20-30 条** — 了解近期活动。
④ **如果 qmd 已配置**，用它搜索当前主题而非 grep。

```bash
WIKI="${WIKI_PATH:-$HOME/wiki}"
read_file "$WIKI/SCHEMA.md"
read_file "$WIKI/index.md"
read_file "$WIKI/log.md" offset=<last 30 lines>

# 如果 qmd 已配置：
qmd query "当前主题" -c wiki 2>/dev/null
```

只有完成定向后才能摄入、查询或检查。这防止：
- 为已存在的实体创建重复页面
- 遗漏到已有内容的交叉引用
- 违反 SCHEMA 的约定
- 重复已记录的工作

对于大型 wiki（100+ 页面），qmd 搜索比 grep 更快更准。

## 两阶段编译

摄入来源时必须遵循两阶段编译流程：

### 阶段 1 — 概念提取

**先读完全部来源**，从每个来源中提取实体和概念，所有提取完成后才开始写页面。
这样代理能看到跨来源的概念重叠，避免为同一概念创建重复页面。

### 阶段 2 — 页面生成

基于提取的全局概念集合生成页面：
- 出现在多个来源中的概念 → 合并为**一个页面**，所有来源列在 `sources` 字段
- 只在一个来源中出现的概念 → 如果是该来源的核心主题才创建页面
- 各段落末尾追加引用标记，指向实际贡献该段内容的来源文件

两阶段分离消除了顺序依赖：阶段 1 的错误在写任何页面之前就能被发现，
跨来源合并是确定性的，来源被删除后对应页面标记为 orphaned 而非静默消失。

## 初始化新 Wiki

当用户要求创建/开始 wiki 时：

1. 确定 wiki 路径（从 `WIKI_PATH` 环境变量，或询问用户；默认 `~/wiki`）
2. 创建目录结构
3. 询问用户 wiki 覆盖的领域 — 要具体
4. 编写定制化的 `SCHEMA.md`（见下方模板）
5. 编写初始 `index.md`
6. 编写初始 `log.md`
7. 确认 wiki 已就绪并建议首批来源

### SCHEMA.md 模板

根据用户领域调整：

```markdown
# Wiki Schema

## 领域
[这个 wiki 覆盖什么 — 例如 "AI/ML 研究"、"个人健康"、"创业情报"]

## 约定
- 文件名：小写、连字符、无空格（如 `transformer-architecture.md`）
- 每个 wiki 页面以 YAML frontmatter 开头（见下方）
- 使用 `[[wikilinks]]` 在页面间链接（每页至少 2 个出站链接）
- 更新页面时始终更新 `updated` 日期
- 每个新页面必须添加到 `index.md` 的正确分区下
- 每个操作必须追加到 `log.md`

## Frontmatter
  ```yaml
  ---
  title: 页面标题
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  kind: concept | entity | comparison | overview | query | summary
  tags: [来自下方分类法]
  sources: [raw/articles/source-name.md]
  # 认识论元数据（可选但推荐）：
  confidence: 0.82            # 0-1 之间，低于 0.5 标记待审查
  provenanceState: extracted | merged | inferred | ambiguous
  contradictedBy:             # 与此页面冲突的页面
    - slug: other-page-slug
  aliases:                    # 别名，使 [[别名]] 也能解析到本页
    - MHA
    - multi-head self-attention
  ---
  ```

`confidence` 和 `provenanceState` 是可选但推荐的，用于观点密集或快速变化的主题。
检查时会标记 confidence < 0.5 和有 contradictedBy 的页面供用户审查，防止弱声明
悄悄固化为已接受的 wiki 事实。

### provenanceState 含义

- **extracted** — 直接从一个来源推导
- **merged** — 综合自多个来源（多来源合并到同一页面时始终设为 merged）
- **inferred** — LLM 推理出了来源中没有明确声明的结论
- **ambiguous** — 来源给出了冲突信号，页面反映编译器的最佳综合

### raw/ Frontmatter

原始来源也有一个小 frontmatter 块，以便重新摄入时检测漂移：

```yaml
---
source_url: https://example.com/article   # 原始 URL（如适用）
ingested: YYYY-MM-DD
sha256: <原始内容正文的十六进制摘要>
---
```

`sha256:` 让未来的重新摄入可以跳过未更改的内容，并在更改时标记漂移。
仅对正文计算（闭合 `---` 之后的所有内容），不包括 frontmatter 本身。

## 标签分类法
[为领域定义 10-20 个顶级标签。在使用新标签之前先在此添加。]

AI/ML 示例：
- 模型: model, architecture, benchmark, training
- 人物/组织: person, company, lab, open-source
- 技术: optimization, fine-tuning, inference, alignment, data
- 元: comparison, timeline, controversy, prediction

规则：页面上的每个标签都必须出现在此分类法中。如果需要新标签，
先在此添加，然后使用。这防止标签蔓延。

## 页面类型详解

### concept
独立的想法、技术或模式。这是默认类型，编译的最常见输出。
解释"它是什么"并链接到相关概念。

示例：`self-attention`、`knowledge-compilation`、`incremental-compilation`

### entity
具体的命名事物：人物、组织、产品、模型。关于特定实例而非抽象模式。
携带唯一标识信息，通常向外链接到其实例化的概念。

示例：`andrej-karpathy`、`gpt-4`、`anthropic`、`attention-is-all-you-need`

### comparison
两个或多个概念/实体的并排分析，沿共享维度比较。
链接到所比较的每个主题，使用平行结构。

示例：`rag-vs-llmwiki`、`transformer-vs-rnn`、`bm25-vs-dense-retrieval`

### overview
连接某个领域多个相关概念的地图页面。通常由 SCHEMA.md 种子生成，
而非直接从来源提取。提供主题集群入口，向外链接到属于该领域的概念和实体页面。

示例：`retrieval-augmented-generation-overview`、`attention-mechanisms-overview`

## 页面阈值
- **创建页面** 当一个实体/概念出现在 2+ 来源中 OR 是一个来源的核心主题
- **添加到已有页面** 当来源提到已覆盖的内容
- **不要创建页面** 用于附带提及、次要细节或领域之外的内容
- **拆分页面** 当超过 ~200 行 — 拆分为子主题并交叉链接
- **归档页面** 当内容完全被取代 — 移到 `_archive/`，从 index 移除

## 引用

### 段落级引用
段落末尾追加 `^[source-file.md]` 指示该段内容来自哪个来源：

```markdown
知识编译指的是将知识库预处理为支持高效查询的目标语言的一系列技术。^[knowledge-compilation.md]

两阶段编译流水线将概念提取与页面生成分离，使跨来源合并确定性地发生。^[architecture-notes.md]
```

文件名相对于 raw/ 目录，使用 bare filename（不加 raw/ 前缀）。

### Claim 级引用
对具体数字、技术断言、直接引述，精确定位到行范围，两种等价语法：

```markdown
系统使用两阶段编译流水线。^[architecture-notes.md:42-58]

系统使用两阶段编译流水线。^[architecture-notes.md#L42-L58]
```

Claim 级引用越多，来源追溯越精确。综合了 3+ 来源的页面必须使用引用标记。

### 来源合并时的引用
多来源合并到同一页面时，各段落继续指向实际贡献该段内容的来源文件：

```markdown
注意力机制计算值的加权和。^[attention-paper.md:12-18]

多头注意力并行应用该机制 h 次。^[transformer-architecture.md:44-51]
```

## Wikilinks 和别名

- 使用 `[[slug]]` 简单链接，或 `[[slug|显示标题]]` 管道语法
- 管道语法在页面文件名与显示标题不同时保持链接稳定
- 页面 frontmatter 中声明 `aliases` 字段，使 `[[别名]]` 也能解析到该页面：

```yaml
---
title: Multi-Head Attention
aliases:
  - multi-head self-attention
  - MHA
---
```

- 别名在 Obsidian、qmd 和 MCP 工具中同样生效

### index.md 模板

索引按类型分区。每个条目一行：wikilink + 摘要。

```markdown
# Wiki Index

> 内容目录。每个 wiki 页面列在其类型下，附带一行摘要。
> 先读这个来找到任何查询的相关页面。
> 最后更新: YYYY-MM-DD | 总页面数: N

## 实体
<!-- 分区内按字母顺序 -->

## 概念

## 比较

## 总览

## 查询
```

**扩展规则：** 当任何分区超过 50 个条目时，按首字母或子领域拆分为子分区。
当索引超过 200 个条目时，创建 `_meta/topic-map.md` 按主题分组页面以便更快导航。

### log.md 模板

```markdown
# Wiki Log

> 所有 wiki 操作的按时间顺序记录。只追加。
> 格式：`## [YYYY-MM-DDThh:mm:ssZ] operation | description`
> 操作：ingest, compile, update, query, lint, create, archive, delete
> 当此文件超过 500 条时，轮转：重命名为 log-YYYY.md，重新开始。

## [2026-06-05T09:14:02Z] ingest | Attention Is All You Need
- 摄入来源: https://arxiv.org/abs/1706.03762
- 页面: [[self-attention]], [[multi-head-attention]], [[transformer]]

## [2026-06-05T09:15:30Z] query | What is multi-head attention?
- 页面: [[multi-head-attention]], [[self-attention]]
- 已归档: 是
```

因为只有标题以 `## [` 开头，可以用标准 shell 工具提取近期操作：
```bash
grep "^## \[" log.md | tail -5
```

## 核心操作

### 1. Ingest（摄入）

当用户提供来源（URL、文件、粘贴文本）时：

① **捕获原始来源：**
   - URL → 用网络工具获取 markdown，保存到 `raw/articles/`
   - PDF → 保存到 `raw/papers/`
   - 粘贴文本 → 保存到适当的 `raw/` 子目录
   - 描述性命名：`raw/articles/karpathy-llm-wiki-2026.md`
   - **添加 raw frontmatter**（`source_url`、`ingested`、正文的 `sha256`）。
     重新摄入同一 URL 时：重新计算 sha256，与存储值比较 —
     相同则跳过，不同则标记漂移并更新。

② **与用户讨论要点** — 什么有趣，什么对领域重要。（自动化/cron 场景跳过此步。）

③ **阶段 1：概念提取** — 从所有来源中提取实体、概念和比较关系。
   全部提取完成后再进入阶段 2。跨来源共享的概念标记为合并候选。

④ **阶段 2：页面生成** — 基于提取结果写或更新 wiki 页面：
   - **新实体/概念：** 仅在满足页面阈值时创建
   - **已有页面：** 添加新信息，更新事实，更新 `updated` 日期。
     当新信息与已有内容矛盾时，遵循冲突处理策略。
   - **跨来源合并：** 多来源共享的概念合并为一个页面，
     confidence 取最小值，provenanceState 设为 merged
   - **交叉引用：** 每个页面必须通过 `[[wikilinks]]` 链接到至少 2 个其他页面
   - **标签：** 仅使用 SCHEMA.md 分类法中的标签
   - **引用：** 各段落末尾追加 `^[source.md]`，具体断言使用行范围 `^[source.md:42-58]`
   - **置信度：** 设置 confidence 数值（0-1），观点密集/单来源声明 < 0.5

⑤ **更新导航：**
   - 将新页面添加到 `index.md` 的正确分区下（按 kind 分区），按字母顺序
   - 更新 index 头部的 "总页面数" 和 "最后更新" 日期
   - 追加到 `log.md`：`## [YYYY-MM-DDThh:mm:ssZ] ingest | Source Title`
   - 在日志条目中列出每个创建或更新的页面（用 [[wikilinks]] 链接）

⑥ **更新 qmd 索引**（如果已配置）：
   ```bash
   qmd update && qmd embed
   ```

⑦ **报告变更** — 向用户列出每个创建或更新的文件。

单个来源可能触发 5-15 个 wiki 页面的更新。这是正常且理想的 — 这是增值效应。

### 2. Query（查询）

当用户提出关于 wiki 领域的问题时：

① **读 `index.md`** 识别相关页面。
② **如果 qmd 已配置**，用 `qmd query` 搜索 — 它混合 BM25 + 向量搜索 + LLM 重排，
   比单纯 grep 或读索引更准更快：
   ```bash
   qmd query "用户的问题" -c wiki
   ```
③ **如果 qmd 未配置**（wiki 小于 ~100 页面），搜索所有 `.md` 文件查找关键词。
④ **读相关页面**。
⑤ **综合回答** 从编译的知识中。引用你借鉴的 wiki 页面：
   "基于 [[page-a]] 和 [[page-b]]..."
⑥ **归档有价值的答案** — 如果答案是一个实质性的比较、深度分析或新颖综合，
   在 `queries/` 或 `comparisons/` 中创建页面。
   不要归档简单的查找 — 只归档重新推导会很痛苦的答案。
⑦ **更新 log.md** 记录查询以及是否归档。

### 3. Lint（检查）

当用户要求检查、健康检查或审计 wiki 时：

① **孤儿页面：** 找到没有来自其他页面的入站 `[[wikilinks]]` 的页面。
   扫描所有 .md 文件，提取所有 `[[wikilinks]]`，构建入站链接映射。
   零入站链接的页面是孤儿。

② **断裂的 wikilinks：** 找到指向不存在页面的 `[[links]]`。

③ **索引完整性：** 每个 wiki 页面应该出现在 `index.md` 中。
   比较文件系统与索引条目。

④ **Frontmatter 验证：** 每个 wiki 页面必须有所有必填字段
   （title, created, updated, kind, tags, sources）。标签必须在分类法中。

⑤ **来源新鲜度：**
   - **Stale** — 页面记录的来源 sha256 与磁盘上文件不匹配
   - **Orphaned** — 页面记录的所有来源已从 raw/ 中删除

⑥ **矛盾：** 同一主题的页面有冲突声明。标记所有有 `contradictedBy` frontmatter 的页面供用户审查。

⑦ **质量信号：** 列出 confidence < 0.5 的页面以及任何只引用单一来源
   但没有设置 confidence 字段的页面 — 这些是寻找佐证或降级的候选。

⑧ **引用验证：**
   - `^[...]` 中的文件名在 raw/ 中不存在 → 错误
   - 引用语法不可解析 → 错误
   - 行范围不可能（起始行 0 或结束行 < 起始行）→ 错误
   - 行范围超出源文件长度 → 警告

⑨ **来源漂移：** 对于 `raw/` 中每个有 `sha256:` frontmatter 的文件，重新计算
   哈希并标记不匹配。

⑩ **页面大小：** 标记超过 200 行的页面 — 拆分候选。

⑪ **标签审计：** 列出所有使用中的标签，标记任何不在 SCHEMA.md 分类法中的。

⑫ **日志轮转：** 如果 log.md 超过 500 条，轮转它。

⑬ **报告发现** 附带具体文件路径和建议操作，按严重性分组
   （断链 > 引用错误 > 孤儿 > 来源漂移 > 矛盾页面 > 陈旧内容 > 样式问题）。

⑭ **追加到 log.md：** `## [YYYY-MM-DDThh:mm:ssZ] lint | N issues found`

## 批量摄入

一次摄入多个来源时，批量更新：
1. 先读所有来源
2. 识别所有来源中的所有实体和概念
3. 检查所有已有页面（qmd 或一次搜索，不是 N 次）
4. 一次性创建/更新页面（避免冗余更新）
5. 最后一次性更新 index.md
6. 写一个覆盖整个批次的日志条目
7. 如果 qmd 已配置，运行 `qmd update && qmd embed`

## 归档

当内容完全被取代或领域范围变化时：
1. 创建 `_archive/` 目录（如果不存在）
2. 将页面移到 `_archive/` 并保留原始路径（如 `_archive/entities/old-page.md`）
3. 从 `index.md` 移除
4. 更新任何链接到它的页面 — 将 wikilink 替换为纯文本 + "(已归档)"
5. 记录归档操作

## 可选工具：qmd

[qmd](https://github.com/tobi/qmd) 是一个本地 markdown 搜索引擎，Karpathy 本人推荐。
当 wiki 增长到 100+ 页面时，`index.md` + grep 就不够用了——qmd 提供混合搜索（BM25 + 语义向量 + LLM 重排），全部离线运行。

### 什么时候用 qmd

| Wiki 规模 | 推荐方式 |
|-----------|---------|
| 0-50 页面 | `index.md` 足够 |
| 50-100 页面 | `index.md` + grep/搜索 |
| 100+ 页面 | 安装 qmd |

### 安装

```bash
# Node.js >= 22 或 Bun >= 1.0
npm install -g @tobilu/qmd
# 或
bun install -g @tobilu/qmd
```

首次使用时会自动下载 3 个 GGUF 模型（共 ~2GB）：
- embeddinggemma-300M — 向量嵌入
- qwen3-reranker-0.6B — 结果重排
- qmd-query-expansion-1.7B — 查询扩展

### 配置 wiki 为 qmd collection

```bash
# 添加 wiki 为 collection
qmd collection add ~/wiki --name wiki

# 添加上下文描述，帮助搜索理解内容
qmd context add qmd://wiki "LLM Wiki 知识库：实体、概念、比较和领域地图"
qmd context add qmd://wiki/entities "实体页面：人物、组织、产品"
qmd context add qmd://wiki/concepts "概念页面：技术、模式、理论"

# 生成向量嵌入
qmd embed
```

### 常用搜索命令

```bash
# 快速关键词搜索
qmd search "transformer"

# 语义搜索（理解意思，不只是关键词）
qmd vsearch "如何让模型更高效地利用长文本"

# 混合搜索（最佳质量）：BM25 + 向量 + 查询扩展 + LLM 重排
qmd query "multi-head attention 的工作原理"

# 限定制 collection
qmd query "主题" -c wiki

# 获取搜索结果对应的完整文档
qmd get "concepts/self-attention.md"
qmd get "#abc123"             # 用 docid（搜索结果中显示）

# JSON 输出（给代理用）
qmd query "主题" --json -n 10

# 列出文件匹配项（给代理用）
qmd query "主题" --all --files --min-score 0.3
```

### 搜索后更新索引

摄入新来源后运行：
```bash
qmd update       # 重新扫描文件系统
qmd embed        # 生成新文档的向量嵌入
```

也可以一步到位：
```bash
qmd update && qmd embed
```

### 中日韩多语言支持

默认嵌入模型（embeddinggemma）对 CJK 覆盖有限。切换到多语言模型：

```bash
export QMD_EMBED_MODEL="hf:Qwen/Qwen3-Embedding-0.6B-GGUF/Qwen3-Embedding-0.6B-Q8_0.gguf"
qmd embed -f    # 切换后必须重新嵌入
```

### MCP Server（给 MiMo Code 用）

qmd 可以作为 MCP 服务器运行，让 MiMo Code 直接调用搜索工具：
`query`、`get`、`multi_get`、`status`。

```bash
# 标准输入输出模式（MiMo Code 启动子进程）
qmd mcp

# HTTP 模式（共享长连接，避免重复加载模型）
qmd mcp --http              # localhost:8181
qmd mcp --http --port 8080  # 自定义端口

# 后台守护进程模式
qmd mcp --http --daemon
qmd mcp stop                 # 停止
qmd status                   # 查看状态
```

在 MiMo Code 配置 MCP 服务器指向 `qmd mcp` 即可。

### 三种搜索的区别

| 命令 | 方式 | 速度 | 质量 | 需要 LLM |
|------|------|------|------|---------|
| `qmd search` | BM25 关键词 | 最快 | 基础 | 否 |
| `qmd vsearch` | 语义向量 | 中等 | 较好 | 嵌入模型 |
| `qmd query` | 混合 + 重排 | 最慢 | 最好 | 三个模型全部 |

## 可选工具：Obsidian

Obsidian 是一个 markdown 笔记应用，可以用 Graph View 可视化 wiki 的链接网络。
Wiki 目录开箱即用作为 Obsidian vault——直接打开 wiki/ 文件夹即可。

推荐设置：
- 附件文件夹设为 `raw/assets/`
- 启用 Wikilinks（通常默认开启）
- 安装 Dataview 插件查询 frontmatter

Obsidian 是**可选的浏览工具**——wiki 本身就是纯 markdown 目录，不需要任何特殊软件。

## 常见陷阱

- **永远不要修改 raw/ 中的文件** — 来源是不可变的。更正写在 wiki 页面中。
- **总是先定向** — 在新会话中做任何操作之前读 SCHEMA + index + 最近日志。
  跳过这步会导致重复和遗漏交叉引用。
- **必须两阶段编译** — 先提取全部概念再写页面。逐个来源顺序处理会导致重复页面和遗漏合并。
- **总是更新 index.md 和 log.md** — 跳过这步会让 wiki 退化。这些是导航骨架。
- **不要为附带提及创建页面** — 遵循页面阈值。在脚注中出现一次的名字不值得创建实体页面。
- **不要创建没有交叉引用的页面** — 孤立页面是不可见的。每个页面必须链接到至少 2 个其他页面。
- **Frontmatter 是必需的** — 它启用搜索、过滤和陈旧检测。
- **标签必须来自分类法** — 自由格式标签会退化为噪声。先在 SCHEMA.md 添加新标签，然后使用。
- **保持页面可扫描** — 一个 wiki 页面应该可以在 30 秒内读完。超过 200 行的页面拆分。将详细分析移到专门的深度页面。
- **批量更新前先询问** — 如果一次摄入会影响 10+ 个已有页面，先与用户确认范围。
- **轮转日志** — log.md 超过 500 条时，重命名为 `log-YYYY.md` 并重新开始。
- **显式处理矛盾** — 不要静默覆盖。记录两个声明并标注日期，在 frontmatter 中标记 contradictedBy，标记供用户审查。
- **多来源合并调 frontmatter** — confidence 取最小值，provenanceState 设 merged，contradictedBy 取去重并集。
- **使用 claim 级引用** — 对具体数字和技术断言，用 `^[file.md:42-58]` 精确到行范围，不要只写文件级引用。
- **qmd 不是必需的** — wiki < 100 页面时 index.md 够用，不要为了搜索工具而增加初始复杂度。
- **摄入后更新 qmd** — 新页面写入后要 `qmd update && qmd embed`，否则搜索不到新内容。
- **CJK 换嵌入模型** — 中文/日文/韩文内容切换 Qwen3-Embedding 后要 `qmd embed -f` 全量重新嵌入。
