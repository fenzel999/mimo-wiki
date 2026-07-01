# Karpathy LLM Wiki 规则

## Wiki 模式

本项目使用 Karpathy LLM Wiki 模式管理知识库。Wiki 是由互链 markdown 文件组成的持久化知识库，
一次编译知识并持续更新，而非每次查询从零检索。交叉引用已经存在，矛盾已被标记，
综合分析反映所有已摄入的内容。

分工：人类策划来源并指导分析方向，代理负责摘要、交叉引用、归档和维护一致性。

## Wiki 位置

Wiki 路径通过环境变量 `WIKI_PATH` 设置，未设置时默认 `~/wiki`。

## 目录结构

```
wiki/
├── SCHEMA.md           # 约定、结构规则、标签分类法
├── index.md            # 内容目录，每页一行摘要
├── log.md              # 操作日志（只追加，超 500 条轮转）
├── raw/                # 原始来源（不可变，只读）
│   ├── articles/
│   ├── papers/
│   ├── transcripts/
│   └── assets/
├── entities/           # 实体页面
├── concepts/           # 概念页面
├── comparisons/        # 比较页面
└── queries/            # 归档的查询结果
```

## 规则

### 会话开始时

1. 先读 `SCHEMA.md` 了解领域约定和标签分类法
2. 再读 `index.md` 了解已有页面
3. 然后读 `log.md` 最后 20-30 条了解近期活动
4. 对于 100+ 页面的 wiki，在创建任何新内容之前还要搜索当前主题
5. 以上步骤完成后才能执行任何操作

### raw/ 目录

- raw/ 中的文件是不可变的原始来源，永远不要修改
- 更正和补充写在 wiki 页面中，不写回 raw/
- 每个原始来源文件必须有 frontmatter：source_url、ingested、sha256
- 重新摄入同一 URL 时，重新计算 sha256 与存储值比较：相同则跳过，不同则标记漂移并更新

### 页面创建

- 一个实体/概念出现在 2+ 来源中，或是一个来源的核心主题时，才创建页面
- 附带提及、次要细节不创建页面
- 每个页面必须有至少 2 个出站 `[[wikilinks]]`
- 每个页面必须有 frontmatter：title、created、updated、type、tags、sources
- 页面超过 200 行时拆分为子主题页面
- 对于观点密集、快速变化或单来源声明，设置 confidence: medium 或 low
- 综合了 3+ 来源的页面，在段落末尾追加来源标记：`^[raw/articles/source-file.md]`

### 标签

- 标签只能使用 SCHEMA.md 分类法中已定义的标签
- 需要新标签时，先在 SCHEMA.md 中添加，然后才能使用

### 摄入来源时

1. 将原始内容保存到 raw/ 对应子目录，计算 sha256
2. 与用户讨论要点（自动化/cron 场景跳过此步）
3. 搜索 index.md 检查已有相关页面
4. 创建新页面或更新已有页面
5. 更新 index.md 和 log.md
6. 报告所有创建或更新的文件

### 信息冲突时

- 不要静默覆盖已有内容
- 检查日期，较新的来源通常取代较旧的
- 记录两个声明并标注日期和来源
- 在 frontmatter 中标记：contradictions: [page-name]

### 索引扩展

- 任何分区超过 50 个条目时，按首字母或子领域拆分为子分区
- 索引超过 200 个条目时，创建 `_meta/topic-map.md` 按主题分组

### 日志和索引

- 每次操作都必须追加到 log.md
- 每个新页面必须添加到 index.md 的正确分区下，按字母顺序
- log.md 超过 500 条时，重命名为 log-YYYY.md 并重新开始

### 批量操作

- 一次摄入会影响 10+ 个已有页面时，先与用户确认范围
- 批量摄入时先读所有来源，一次搜索检查已有页面，一次性创建/更新，最后统一更新索引

### 归档

- 内容完全被取代时，移到 `_archive/` 并保留原始路径
- 从 index.md 移除，更新链接到它的页面

### 详细操作模板

完整的 SCHEMA.md 模板、index.md 模板、log.md 模板、frontmatter 规范、
ingest/query/lint 的逐步操作步骤、Obsidian 集成和常见陷阱，加载 `llm-wiki` 技能获取：
```
skill({ name: "llm-wiki" })
```
