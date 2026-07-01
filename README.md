# mimo-wiki

为 [MiMo Code](https://mimo.xiaomi.com/zh/mimocode) 提供 Karpathy LLM Wiki 模式——
让你的 AI 编程助手持续积累和交叉引用知识，而非每次从零检索。

基于 [Andrej Karpathy 的 LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)。

## 它是什么

一套规则和技能，让 AI 代理把知识整理成互链的 markdown 页面，存在本地磁盘上。

每次摄入新来源，代理提取概念、创建/合并页面、交叉引用、记录来源。
下次你问同样的问题，代理直接读已有页面回答——不需要重新检索和综合。

wiki 越用越值钱：页面越多，交叉引用越密，查询越快。

## 和传统 RAG 的区别

|  | 传统 RAG | Wiki 模式 |
|--|---------|-----------|
| 查询 | 每次从零检索、从零综合 | 读已编译的页面直接回答 |
| 知识 | 临时的，会话结束即消失 | 持久化，页面和查询不断增殖 |
| 跨来源 | 分块独立竞争注意力 | 共享概念合并为一个页面 |
| 来源追溯 | 分块级 | 段落级 + claim 级行范围引用 |
| 会话间 | 无状态，重复劳动 | 有状态，越用越智能 |

## 安装

### 项目级 vs 全局

| | 项目级 | 全局 |
|--|--------|------|
| 安装到 | 当前目录 | `~/.config/mimocode/` |
| 作用范围 | 仅当前项目 | 所有项目 |
| 适合 | 特定领域的 wiki | 通用 wiki 规则 |

### 安装命令

| | Windows | macOS / Linux |
|--|---------|---------------|
| **项目级** | `irm .../install.ps1 \| iex` | `curl -sSL .../install.sh \| bash` |
| **全局** | `irm .../install-global.ps1 \| iex` | `curl -sSL .../install-global.sh \| bash` |
| **卸载项目级** | `irm .../uninstall.ps1 \| iex` | `curl -sSL .../uninstall.sh \| bash` |
| **卸载全局** | `irm .../uninstall-global.ps1 \| iex` | `curl -sSL .../uninstall-global.sh \| bash` |

完整 URL 前缀：`https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/`

## Wiki 目录结构

```
~/wiki/                          ← WIKI_PATH（可自定义，默认 ~/wiki）
├── SCHEMA.md                    # 约定、标签分类法
├── index.md                     # 内容目录（自动维护，按类型分区）
├── log.md                       # 操作日志（只追加，500 条轮转）
├── raw/                         # 原始来源（不可修改）
│   ├── articles/                #   网络文章
│   ├── papers/                  #   PDF、论文
│   ├── transcripts/             #   会议笔记
│   └── assets/                  #   本地化图片
├── concepts/                    # 概念页面
├── entities/                    # 实体页面
├── comparisons/                 # 比较页面
├── overviews/                   # 总览页面
└── queries/                     # 归档的深度查询结果
```

三层架构：**raw/**（不可变的原始来源）→ **wiki 页面**（代理编译维护）→ **SCHEMA.md**（约定和分类法）。

## Wiki 页面长什么样

每个 wiki 页面是一个 markdown 文件，带 frontmatter：

```markdown
---
title: Self-Attention
kind: concept
tags: [attention, transformer, neural-network]
sources: [attention-is-all-you-need.md, vaswani2017.md]
created: 2026-07-01
updated: 2026-07-02
confidence: 0.9
provenanceState: merged
aliases: [self-attention-mechanism, SAM]
---

# Self-Attention

注意力机制计算值的加权和，不依赖外部记忆。^[attention-is-all-you-need.md:12-18]

## 多头注意力

并行应用该机制 h 次，每个头学习不同的子空间表示。^[transformer-architecture.md:44-51]

## 相关

- [[multi-head-attention]] — Self-Attention 的并行扩展
- [[transformer]] — 基于 Self-Attention 的架构
- [[attention-overview]] — 注意力机制全景
```

### Frontmatter 字段

| 字段 | 必需 | 说明 |
|------|------|------|
| `title` | ✅ | 页面标题 |
| `kind` | ✅ | concept / entity / comparison / overview |
| `tags` | ✅ | SCHEMA.md 分类法中的标签 |
| `sources` | ✅ | 贡献此页面的 raw/ 文件名列表 |
| `created` | ✅ | 创建日期 |
| `updated` | ✅ | 最后更新日期 |
| `confidence` | ⚠️ | 0-1，低于 0.5 标记待审查（单来源/快速变化时必需） |
| `provenanceState` | ⚠️ | extracted / merged / inferred / ambiguous |
| `contradictedBy` | ⚠️ | 与此页面冲突的页面 slug 列表 |
| `aliases` | ❌ | 让 `[[别名]]` 也能解析到此页 |

### 引用语法

| 写法 | 含义 |
|------|------|
| `^[paper.md]` | 段落级：这段内容来自 paper.md |
| `^[paper.md:42-58]` | Claim 级：精确到第 42-58 行 |
| `[[slug]]` | Wikilink：链接到 slug 页面 |
| `[[slug\|显示标题]]` | 管道链接：显示标题和 slug 不同时 |

来源文件名用 bare filename（`attention-paper.md`），不加 `raw/` 前缀。

## 使用流程

### 1. 初始化

```
你：帮我创建一个新的 LLM Wiki，领域是 AI/ML 研究

代理：创建目录结构 → 询问领域细节 → 写 SCHEMA.md → 写 index.md → 写 log.md
```

SCHEMA.md 不需要一开始就完美——它是活文档，随着你摄入更多来源会不断进化。

### 2. 摄入来源

```
你：帮我把这篇摄入 wiki: https://arxiv.org/abs/1706.03762

代理：
  ① 保存原文到 raw/articles/（图片下载到 raw/assets/）
  ② 提取所有概念和实体（两阶段编译：先全部提取，再写页面）
  ③ 创建/合并页面：self-attention、multi-head-attention、transformer…
  ④ 每个页面加 frontmatter、引用标记、wikilinks
  ⑤ 更新 index.md + log.md
```

一次摄入可能触发 5-15 个页面更新——跨来源的共享概念会被合并，不会重复。

### 3. 查询

```
你：Flash Attention 和标准注意力的区别？

代理：读 index.md → 找到相关页面 → 读页面 → 综合回答，引用 [[flash-attention]] [[standard-attention]]
```

### 4. 跨会话复用

```
=== 会话 1 ===
你：帮我摄入这 3 篇论文
代理：创建了 12 个页面，更新了 5 个已有页面

=== 会话 2（全新会话）===
你：Flash Attention 和标准注意力的区别？
代理：页面已存在，直接综合回答——不需要重新检索和阅读论文
```

每次新会话，代理会先"定向"：读 SCHEMA.md → index.md → log.md 最后 20-30 条，恢复对 wiki 的记忆。

### 5. 健康检查

```
你：帮我检查 wiki 健康度

代理检查：
  - 孤儿页面（零入站链接）
  - 断裂 wikilinks
  - 来源失效（raw/ 文件删除了但页面还引用）
  - 来源漂移（sha256 不匹配）
  - 矛盾标记（contradictedBy）
  - 低置信度（confidence < 0.5）
  - 页面过大（> 200 行）
  - 索引不完整
```

## 四种页面类型

| 类型 | 回答什么 | 何时创建 | 内容结构 | 示例 |
|------|---------|---------|---------|------|
| **concept** | 这是什么？ | 2+ 来源或核心主题 | 原理 + 变体 + 应用 | `self-attention.md` |
| **entity** | 这个具体东西？ | 2+ 来源提到 | 元数据 + 背景 | `gpt-4.md` |
| **comparison** | A vs B？ | 用户提问 / 频繁共现 | 并排对比表 | `transformer-vs-rnn.md` |
| **overview** | 这个领域有什么？ | 领域概念 > 5 个 | 地图 + 链接 | `attention-overview.md` |

页面之间用 `[[wikilinks]]` 互链——从任何一个页面出发，可以跳到所有相关概念。

## 搜索

| wiki 规模 | 方式 | 命令 |
|----------|------|------|
| < 100 页面 | 读 index.md + 关键词 | 代理自动执行 |
| 100+ 页面 | BM25 语义搜索 | `node references/bm25-search.js "查询内容"` |

BM25 搜索为零依赖纯 Node.js 实现，不需要安装任何包。

## 安装后文件清单

| 文件 | 作用 |
|------|------|
| `AGENTS.md` | 规则——代理必须遵守的约束（"必须…"/"不要…"） |
| `skills/llm-wiki/SKILL.md` | 操作步骤——代理怎么执行各项任务 |
| `skills/llm-wiki/templates/` | SCHEMA.md / index.md / log.md 创建模板 |
| `skills/llm-wiki/references/` | 页面类型、引用语法、BM25 搜索等参考文档 |

## 参考

- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [MiMo Code 文档](https://mimo.xiaomi.com/zh/mimocode)
- [GitHub 仓库](https://github.com/fenzel999/mimo-wiki)
