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

<details>
<summary>谁适合用</summary>

- 用 AI 编程助手做研究、读论文、追踪技术演进的人
- 经常跨会话问同一领域问题、厌倦每次重新检索的人
- 需要多个来源交叉验证、标注置信度的人
- 构建领域知识库并希望它持续增值的人

</details>

<details>
<summary>前置条件</summary>

- [MiMo Code](https://mimo.xiaomi.com/zh/mimocode)（或其他支持 AGENTS.md / SKILL.md 的 AI 代理）
- 浏览器（安装脚本用 PowerShell / curl 下载文件）
- Node.js（仅 BM25 搜索需要，wiki < 100 页面时不需要）

</details>

## 工作原理

安装后项目里多两个东西：

```
AGENTS.md              ← 规则：代理必须遵守的约束
skills/llm-wiki/       ← 技能：代理怎么执行各项任务
```

AI 代理读 AGENTS.md 知道"必须怎么做、不能怎么做"，读 SKILL.md 知道"具体步骤是什么"。
两者配合，代理就能按照统一标准构建和维护 wiki。

## 安装

### 一行命令，脚本会提示你选择

| 平台 | 命令 | 说明 |
|------|------|------|
| **Windows** | `irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 \| iex` | 脚本提示 1=项目 2=全局 |
| **macOS / Linux** | `curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh \| bash` | 脚本提示 1=项目 2=全局 |

运行后脚本会问两个问题：安装到哪？ 1（当前项目）或 2（全局 `~/.config/mimocode/`）。

### 卸载

同样的脚本，加 `--uninstall` 参数：

**Windows：**
```powershell
irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex -args '-Uninstall'
```

**macOS / Linux：**
```bash
curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash -s -- --uninstall
```

脚本提示选择卸载位置，并确认后才执行。

### Hermes 安装

全局安装后 Hermes 自动识别 AGENTS.md + SKILL.md。

如果 Hermes 只索引 `~/.hermes/skills/` 而非 `~/.config/mimocode/skills/`，请将全局安装到的 `.config` 改为 `.hermes`：

```
~/.hermes/mimocode/
```

## Wiki 目录结构

```
~/wiki/                          ← WIKI_PATH（可自定义，默认 ~/wiki）
├── SCHEMA.md                    # 领域约定 + 标签分类法
├── index.md                     # 内容目录（按类型分区，字母排序）
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

<details>
<summary>raw/ 不可变性 + 矛盾处理</summary>

raw/ 里的文件一旦写入就不可修改。更正和补充只写在 wiki 页面中。
这样保证来源可追溯——任何页面的引用都能回到原始文本验证。

如果两个来源说法冲突，代理不会静默覆盖，而是：
- 两个声明都保留，标注日期
- 在 frontmatter 中用 `contradictedBy` 标记冲突关系
- `confidence` 取最低值提醒你审查

</details>

<details>
<summary>SCHEMA.md 的作用</summary>

SCHEMA.md 定义两件事：

1. **标签分类法**——wiki 只能用 SCHEMA 中已定义的标签，新标签需你确认后才写入
2. **领域约定**——特定领域的命名规则、缩写、概念边界

它不需要一开始就完美。随着你摄入更多来源，你告诉代理调整，它协同进化。

</details>

<details>
<summary>index.md 的组织方式</summary>

按页面类型分区，每个分区内按字母顺序排列：

```markdown
## Concepts

- [[self-attention]] — 注意力值的加权和机制
- [[transformer]] — 基于自注意力的序列模型

## Entities

- [[gpt-4]] — OpenAI 多模态大模型

## Comparisons

- [[transformer-vs-rnn]] — 序列建模范式对比
```

分区超 50 条目时拆分子分区，总条目超 200 时创建 topic-map。

</details>

<details>
<summary>log.md 格式</summary>

每次操作追加一条，只追加，不修改：

```markdown
## [2026-07-02T10:30:00Z] ingest | 摄入 3 篇论文，创建 12 页面，更新 5 页面
## [2026-07-02T11:00:00Z] query | 回答"Flash Attention vs 标准"→ 归档为 comparison 页面
## [2026-07-02T11:15:00Z] lint | 健康检查：2 个孤儿页面，1 个断裂链接
```

超过 500 条时轮转（旧日志移到 `_archive/`）。

</details>

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

<details>
<summary>Frontmatter 字段详解</summary>

| 字段 | 必需 | 说明 |
|------|------|------|
| `title` | ✅ | 页面标题 |
| `kind` | ✅ | concept / entity / comparison / overview |
| `tags` | ✅ | SCHEMA.md 分类法中已定义的标签 |
| `sources` | ✅ | 贡献此页面的 raw/ 文件名（bare filename，不加 `raw/` 前缀） |
| `created` | ✅ | 创建日期 |
| `updated` | ✅ | 最后更新日期 |
| `confidence` | ⚠️ | 0-1，低于 0.5 标记待审查（单来源/快速变化时必需） |
| `provenanceState` | ⚠️ | extracted / merged / inferred / ambiguous |
| `contradictedBy` | ⚠️ | 与此页面冲突的页面 slug 列表 |
| `aliases` | ❌ | 让 `[[别名]]` 也能解析到此页 |

</details>

<details>
<summary>引用语法详解</summary>

| 写法 | 含义 | 何时用 |
|------|------|--------|
| `^[paper.md]` | 段落级：这整段来自 paper.md | 综合了 3+ 来源时必需 |
| `^[paper.md:42-58]` | Claim 级：精确到第 42-58 行 | 数字、技术断言、直接引述 |
| `[[slug]]` | Wikilink：链接到 slug 页面 | 每个页面至少 2 个出站链接 |
| `[[slug\|显示标题]]` | 管道链接：显示文本和 slug 不同时 | 页面名和显示名不一致 |

来源文件名用 bare filename（`attention-paper.md`），不加 `raw/` 前缀。

</details>

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

<details>
<summary>两阶段编译详解</summary>

**阶段 1 — 概念提取：** 先读完全部来源，提取所有实体和概念。全部提取完再写页面。

**阶段 2 — 页面生成：** 跨来源共享概念合并为一个页面，各段落追加引用标记。

为什么要两阶段？逐个来源处理会导致：跨来源的共享概念被重复创建、合并不完整、交叉引用遗漏。

一次摄入可能触发 5-15 个页面更新。这是正常的增值效应。

</details>

### 3. 查询

```
你：Flash Attention 和标准注意力的区别？

代理：读 index.md → 找到相关页面 → 读页面 → 综合回答
有价值的答案归档为 comparison 页面，简单查找不归档。
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

每次新会话，代理会先**定向**：读 SCHEMA.md → index.md → log.md 最后 20-30 条，恢复对 wiki 的记忆。

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
| **concept** | 这是什么？怎么工作？ | 2+ 来源或核心主题 | 原理 + 变体 + 应用 | `self-attention.md` |
| **entity** | 这个具体东西？ | 2+ 来源提到 | 元数据 + 背景 | `gpt-4.md` |
| **comparison** | A vs B？ | 用户提问 / 频繁共现 | 并排对比表 | `transformer-vs-rnn.md` |
| **overview** | 这个领域有什么？ | 领域概念 > 5 个 | 地图 + 链接 | `attention-overview.md` |

附带提及、次要细节不创建页面——只在相关页面中一笔带过。

## 搜索

| wiki 规模 | 方式 | 命令 |
|----------|------|------|
| < 100 页面 | 读 index.md + 关键词搜索 | 代理自动执行 |
| 100+ 页面 | BM25 搜索 | `node references/bm25-search.js "查询"` |

<details>
<summary>BM25 搜索详解</summary>

首次搜索自动建索引。内容变化后执行 `--reindex` 更新。

BM25 为零依赖纯 Node.js 实现（k1=1.5, b=0.75），中英文混合分词。

```bash
node references/bm25-search.js --reindex      # 重建索引
node references/bm25-search.js "transformer"  # 搜索
```

输出示例：

```
查询: transformer attention
结果: 3 个页面

  1. [12.34] concepts/self-attention.md
     Self-Attention (concept)
  2. [8.76] concepts/multi-head-attention.md
     Multi-Head Attention (concept)
  3. [5.12] entities/transformer.md
     Transformer (entity)
```

</details>

## 安装后文件清单

| 文件 | 作用 |
|------|------|
| `AGENTS.md` | 规则——代理必须遵守的约束 |
| `skills/llm-wiki/SKILL.md` | 操作步骤——代理怎么执行各项任务 |
| `skills/llm-wiki/templates/` | SCHEMA.md / index.md / log.md 创建模板 |
| `skills/llm-wiki/references/` | 页面类型、引用语法、BM25 搜索等参考文档 |

## 参考

- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [MiMo Code](https://mimo.xiaomi.com/zh/mimocode)
