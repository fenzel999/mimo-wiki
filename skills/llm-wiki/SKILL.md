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
└── queries/            # 第 2 层：值得保留的已归档查询结果
```

1. **原始来源层 (raw/)** — 不可变。代理读取但从不修改。
2. **Wiki 层 (entities/, concepts/, comparisons/, queries/)** — 代理拥有的 markdown 文件，由代理创建、更新和交叉引用。
3. **模式层 (SCHEMA.md)** — 定义结构、约定和标签分类法。

## 恢复已有 Wiki（关键 — 每次会话都要做）

当用户有已有 wiki 时，**在做任何事之前必须先定向**：

① **读 `SCHEMA.md`** — 了解领域、约定和标签分类法。
② **读 `index.md`** — 了解有哪些页面和摘要。
③ **读 `log.md` 最后 20-30 条** — 了解近期活动。

```bash
WIKI="${WIKI_PATH:-$HOME/wiki}"
read_file "$WIKI/SCHEMA.md"
read_file "$WIKI/index.md"
read_file "$WIKI/log.md" offset=<last 30 lines>
```

只有完成定向后才能摄入、查询或检查。这防止：
- 为已存在的实体创建重复页面
- 遗漏到已有内容的交叉引用
- 违反 SCHEMA 的约定
- 重复已记录的工作

对于大型 wiki（100+ 页面），在创建任何新内容前还要搜索当前主题。

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
- **来源标记：** 在综合 3+ 来源的页面上，在段落末尾追加 `^[raw/articles/source-file.md]`
  标记来自特定来源的声明。这让读者可以追溯每个声明而无需重读整个原始文件。
  在单来源页面上可选，因为 `sources:` frontmatter 已足够。

## Frontmatter
  ```yaml
  ---
  title: 页面标题
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  type: entity | concept | comparison | query | summary
  tags: [来自下方分类法]
  sources: [raw/articles/source-name.md]
  # 可选质量信号：
  confidence: high | medium | low        # 声明的支持程度
  contested: true                        # 页面有未解决的矛盾时设置
  contradictions: [other-page-slug]      # 与此页面冲突的页面
  ---
  ```

`confidence` 和 `contested` 是可选但推荐的，用于观点密集或快速变化的主题。
检查时会标记 `contested: true` 和 `confidence: low` 的页面供用户审查，防止弱声明
悄悄固化为已接受的 wiki 事实。

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

## 页面阈值
- **创建页面** 当一个实体/概念出现在 2+ 来源中 OR 是一个来源的核心主题
- **添加到已有页面** 当来源提到已覆盖的内容
- **不要创建页面** 用于附带提及、次要细节或领域之外的内容
- **拆分页面** 当超过 ~200 行 — 拆分为子主题并交叉链接
- **归档页面** 当内容完全被取代 — 移到 `_archive/`，从 index 移除

## 实体页面
每个值得注意的实体一个页面。包括：
- 概述 / 它是什么
- 关键事实和日期
- 与其他实体的关系（[[wikilinks]]）
- 来源引用

## 概念页面
每个概念或主题一个页面。包括：
- 定义 / 解释
- 当前知识状态
- 开放问题或争论
- 相关概念（[[wikilinks]]）

## 比较页面
并排分析。包括：
- 比较什么以及为什么
- 比较维度（优先使用表格格式）
- 结论或综合
- 来源

## 更新策略
当新信息与已有内容冲突时：
1. 检查日期 — 较新的来源通常取代较旧的
2. 如果确实矛盾，记录两个立场并标注日期和来源
3. 在 frontmatter 中标记矛盾：`contradictions: [page-name]`
4. 在检查报告中标记供用户审查
```

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

## 查询
```

**扩展规则：** 当任何分区超过 50 个条目时，按首字母或子领域拆分为子分区。
当索引超过 200 个条目时，创建 `_meta/topic-map.md` 按主题分组页面以便更快导航。

### log.md 模板

```markdown
# Wiki Log

> 所有 wiki 操作的按时间顺序记录。只追加。
> 格式：`## [YYYY-MM-DD] action | subject`
> 操作：ingest, update, query, lint, create, archive, delete
> 当此文件超过 500 条时，轮转：重命名为 log-YYYY.md，重新开始。

## [YYYY-MM-DD] create | Wiki initialized
- 领域: [domain]
- 创建了 SCHEMA.md, index.md, log.md
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

③ **检查已有内容** — 搜索 index.md 并搜索所有 .md 文件找到
   被提到的实体/概念的已有页面。这是不断增值的 wiki 和一堆重复之间的区别。

④ **写或更新 wiki 页面：**
   - **新实体/概念：** 仅在满足 SCHEMA.md 中的页面阈值时创建
     （2+ 来源提及，或一个来源的核心主题）
   - **已有页面：** 添加新信息，更新事实，更新 `updated` 日期。
     当新信息与已有内容矛盾时，遵循更新策略。
   - **交叉引用：** 每个新或更新的页面必须通过 `[[wikilinks]]` 链接到至少 2 个
     其他页面。检查已有页面是否链接回来。
   - **标签：** 仅使用 SCHEMA.md 分类法中的标签
   - **来源标记：** 在综合 3+ 来源的页面上，追加 `^[raw/articles/source.md]`
     标记可追溯到特定来源的段落。
   - **置信度：** 对于观点密集、快速变化或单来源声明，设置
     `confidence: medium` 或 `low`。不要标记 `high` 除非声明得到多个来源的良好支持。

⑤ **更新导航：**
   - 将新页面添加到 `index.md` 的正确分区下，按字母顺序
   - 更新 index 头部的 "总页面数" 和 "最后更新" 日期
   - 追加到 `log.md`：`## [YYYY-MM-DD] ingest | Source Title`
   - 在日志条目中列出每个创建或更新的文件

⑥ **报告变更** — 向用户列出每个创建或更新的文件。

单个来源可能触发 5-15 个 wiki 页面的更新。这是正常且理想的 — 这是增值效应。

### 2. Query（查询）

当用户提出关于 wiki 领域的问题时：

① **读 `index.md`** 识别相关页面。
② **对于 100+ 页面的 wiki**，还要搜索所有 `.md` 文件
   查找关键词 — 仅靠索引可能遗漏相关内容。
③ **读相关页面**。
④ **综合回答** 从编译的知识中。引用你借鉴的 wiki 页面：
   "基于 [[page-a]] 和 [[page-b]]..."
⑤ **归档有价值的答案** — 如果答案是一个实质性的比较、深度分析或新颖综合，
   在 `queries/` 或 `comparisons/` 中创建页面。
   不要归档简单的查找 — 只归档重新推导会很痛苦的答案。
⑥ **更新 log.md** 记录查询以及是否归档。

### 3. Lint（检查）

当用户要求检查、健康检查或审计 wiki 时：

① **孤儿页面：** 找到没有来自其他页面的入站 `[[wikilinks]]` 的页面。
   扫描所有 .md 文件，提取所有 `[[wikilinks]]`，构建入站链接映射。
   零入站链接的页面是孤儿。

② **断裂的 wikilinks：** 找到指向不存在页面的 `[[links]]`。

③ **索引完整性：** 每个 wiki 页面应该出现在 `index.md` 中。
   比较文件系统与索引条目。

④ **Frontmatter 验证：** 每个 wiki 页面必须有所有必填字段
   （title, created, updated, type, tags, sources）。标签必须在分类法中。

⑤ **陈旧内容：** 页面的 `updated` 日期比提到相同实体的最新来源
   旧 90+ 天。

⑥ **矛盾：** 同一主题的页面有冲突声明。寻找共享标签/实体但陈述不同事实的
   页面。标记所有 `contested: true` 或 `contradictions:` frontmatter 的页面供用户审查。

⑦ **质量信号：** 列出 `confidence: low` 的页面以及任何只引用单一来源
   但没有设置 confidence 字段的页面 — 这些是寻找佐证或降级为 `confidence: medium` 的候选。

⑧ **来源漂移：** 对于 `raw/` 中每个有 `sha256:` frontmatter 的文件，重新计算
   哈希并标记不匹配。不匹配表明原始文件被编辑（不应发生 — raw/ 不可变）
   或从已更改的 URL 摄入。不是硬错误，但值得报告。

⑨ **页面大小：** 标记超过 200 行的页面 — 拆分候选。

⑩ **标签审计：** 列出所有使用中的标签，标记任何不在 SCHEMA.md 分类法中的。

⑪ **日志轮转：** 如果 log.md 超过 500 条，轮转它。

⑫ **报告发现** 附带具体文件路径和建议操作，按严重性分组
   （断链 > 孤儿 > 来源漂移 > 矛盾页面 > 陈旧内容 > 样式问题）。

⑬ **追加到 log.md：** `## [YYYY-MM-DD] lint | N issues found`

## 批量摄入

一次摄入多个来源时，批量更新：
1. 先读所有来源
2. 识别所有来源中的所有实体和概念
3. 检查所有已有页面（一次搜索，不是 N 次）
4. 一次性创建/更新页面（避免冗余更新）
5. 最后一次性更新 index.md
6. 写一个覆盖整个批次的日志条目

## 归档

当内容完全被取代或领域范围变化时：
1. 创建 `_archive/` 目录（如果不存在）
2. 将页面移到 `_archive/` 并保留原始路径（如 `_archive/entities/old-page.md`）
3. 从 `index.md` 移除
4. 更新任何链接到它的页面 — 将 wikilink 替换为纯文本 + "(已归档)"
5. 记录归档操作

## 常见陷阱

- **永远不要修改 raw/ 中的文件** — 来源是不可变的。更正写在 wiki 页面中。
- **总是先定向** — 在新会话中做任何操作之前读 SCHEMA + index + 最近日志。
  跳过这步会导致重复和遗漏交叉引用。
- **总是更新 index.md 和 log.md** — 跳过这步会让 wiki 退化。这些是导航骨架。
- **不要为附带提及创建页面** — 遵循 SCHEMA.md 中的页面阈值。在脚注中出现一次的名字不值得创建实体页面。
- **不要创建没有交叉引用的页面** — 孤立页面是不可见的。每个页面必须链接到至少 2 个其他页面。
- **Frontmatter 是必需的** — 它启用搜索、过滤和陈旧检测。
- **标签必须来自分类法** — 自由格式标签会退化为噪声。先在 SCHEMA.md 添加新标签，然后使用。
- **保持页面可扫描** — 一个 wiki 页面应该可以在 30 秒内读完。超过 200 行的页面拆分。将详细分析移到专门的深度页面。
- **批量更新前先询问** — 如果一次摄入会影响 10+ 个已有页面，先与用户确认范围。
- **轮转日志** — log.md 超过 500 条时，重命名为 `log-YYYY.md` 并重新开始。
  代理应在检查时检查日志大小。
- **显式处理矛盾** — 不要静默覆盖。记录两个声明并标注日期，在 frontmatter 中标记，标记供用户审查。
