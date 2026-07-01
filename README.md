# mimo-wiki

为 [MiMo Code](https://mimo.xiaomi.com/zh/mimocode) 提供 Karpathy LLM Wiki 模式——
让你的 AI 编程助手持续积累和交叉引用知识，而非每次从零检索。

基于 [Andrej Karpathy 的 LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)。

## 为什么用 Wiki 模式

|  | 传统 RAG | Wiki 模式 |
|--|---------|-----------|
| 查询行为 | 每次从零检索、从零综合 | 复用已编译的结构 |
| 知识增长 | 临时的，不积累 | 页面 + 归档查询不断增殖 |
| 跨来源概念 | 重复分块竞争 | 合并为一个共享页面 |
| 来源追溯 | 分块引用 | 段落级 + claim 级行范围引用 |
| 版本历史 | 无 | git 仓库天然支持 |

Wiki 就是一个 git 仓库里的 markdown 文件目录。越用越强。

## 快速开始

### 第 1 步：安装

有两种放置方式，按你的工作流选择：

#### 方式 A：全局安装（推荐）

把规则和技能放到 MiMo Code 全局目录，**所有项目**都能用 wiki 功能：

```
~/.mimocode/
├── AGENTS.md                 # 全局规则 — 所有项目生效
└── skills/
    └── llm-wiki/
        └── SKILL.md          # 全局技能 — 所有项目可加载
```

**优点：** 任何项目里说"帮我摄入这篇文章"都能用，不用每个项目单独配置。
**适合：** 你经常在不同项目间切换，wiki 作为通用知识库。

#### 方式 B：项目级安装

把规则和技能放到具体项目目录，**只在该项目**中生效：

```
你的项目/
├── AGENTS.md                 # 项目规则 — 只对本项目生效
└── skills/
    └── llm-wiki/
        └── SKILL.md          # 项目技能 — 只对本项目可加载
```

**优点：** 不同项目可以有不同的 wiki 配置（比如一个 AI 研究 wiki，一个健康 wiki）。
**适合：** 你为不同领域维护独立的 wiki。

**建议：** 如果你只有一个 wiki，用全局安装。如果需要多个独立 wiki，用项目级安装。

### 第 2 步：初始化 Wiki

在 MiMo Code 中说：

> "帮我创建一个新的 LLM Wiki，领域是 AI/ML 研究"

代理会创建 wiki 目录结构、SCHEMA.md、index.md、log.md。

### 第 3 步：使用

正常对话即可。以下是实际场景：

#### 场景 1：摄入来源

```
你：帮我把这篇文章摄入 wiki: https://arxiv.org/abs/1706.03762

代理：（读取论文 → 提取概念 → 创建页面 → 更新索引和日志）
     创建了以下页面：
     - concepts/self-attention.md
     - concepts/multi-head-attention.md
     - entities/transformer.md
     更新了 index.md 和 log.md
```

#### 场景 2：查询

```
你：Transformer 和 RNN 的主要区别？

代理：（读 index.md → 找到相关页面 → 综合回答）
     基于 [[transformer]] 和 [[rnn]] 页面：
     1. 并行性：Transformer 完全并行，RNN 顺序处理
     2. 长距离依赖：Transformer 直接建模，RNN 受梯度消失限制
     ...
     （如果答案有价值，会自动归档为 comparisons/transformer-vs-rnn.md）
```

#### 场景 3：切换会话后自动查询

这是 wiki 模式的核心价值——**知识跨会话持久化**：

```
=== 会话 1（周一）===
你：帮我摄入这 3 篇关于注意力机制的论文
代理：（创建了 self-attention、multi-head-attention、flash-attention 等页面）
你：/new（关闭会话）

=== 会话 2（周三，全新会话）===
你：Flash Attention 和标准注意力的区别是什么？

代理：（自动读 SCHEMA.md → 读 index.md → 读 log.md 最后 20 条
      → 发现 flash-attention 和 self-attention 页面已存在
      → 读取这两个页面 → 综合回答）

     基于 [[flash-attention]] 和 [[self-attention]] 页面：
     Flash Attention 通过 IO 感知的分块算法将注意力计算的
     内存复杂度从 O(n²) 降到 O(n)，同时保持数值精确...
     ^[flash-attention.md:12-28]

你：（完全不需要重新提供那 3 篇论文，代理已经知道）
```

**关键点：**
- 新会话开始时，代理自动读 SCHEMA → index → log 完成定向
- 之前摄入的知识已经编译在 wiki 页面中，无需重新提供
- 代理引用具体页面和行号，来源可追溯
- 你问的问题如果值得保留，会自动归档回 wiki

#### 场景 4：健康检查

```
你：帮我检查 wiki 健康状况

代理：（扫描所有页面）
     发现 3 个问题：
     ⚠ 孤儿页面：entities/old-model.md（无入站链接）
     ⚠ 断链：[[deprecated-api]] 指向不存在的页面
     ⚠ 数据差距：多个页面提到 "LoRA" 但缺少独立概念页面
     建议：摄入一篇 LoRA 论文来填补这个差距
```

## 四种页面类型

Wiki 有四种页面，每种解决不同的知识组织问题：

### concept（概念）— 最常见的类型

**是什么：** 独立的想法、技术或模式。不是某个具体事物，而是一类事物。

**解决什么问题：** "这个东西是什么？它怎么工作？和其他东西什么关系？"

**例子：**
- `self-attention` — 一种注意力机制，解释原理、公式、变体
- `knowledge-compilation` — 知识编译技术，解释定义、方法、应用
- `fine-tuning` — 微调技术，解释方法、优缺点、适用场景

**什么时候创建：** 某个技术/想法被多个来源提到，或者是某个来源的核心主题。

### entity（实体）— 具体的命名事物

**是什么：** 某个具体的人、组织、产品、模型、论文。不是一类事物，而是"这一个"。

**解决什么问题：** "这个具体东西的背景、关键信息、相关项目是什么？"

**例子：**
- `andrej-karpathy` — 人物页面：背景、贡献、相关项目
- `gpt-4` — 模型页面：发布时间、架构、能力、局限
- `anthropic` — 公司页面：成立时间、产品、团队
- `attention-is-all-you-need` — 论文页面：发表年份、作者、核心贡献

**什么时候创建：** 某个具体事物被多个来源提到，需要记录其元数据和背景。

### comparison（比较）— 并排分析

**是什么：** 两个或多个概念/实体的并排比较。不是单独介绍，而是"它们之间有什么区别"。

**解决什么问题：** "A 和 B 哪个更好？在什么场景下用哪个？"

**例子：**
- `transformer-vs-rnn` — 架构对比：并行性、长距离依赖、计算效率
- `rag-vs-llmwiki` — 方法对比：检索方式、知识增长、维护成本
- `bm25-vs-dense-retrieval` — 搜索算法对比：速度、质量、适用场景

**什么时候创建：** 用户问"A 和 B 的区别"，且答案需要多维度对比。

### overview（总览）— 领域地图

**是什么：** 连接某个领域多个相关概念的地图页面。不是深入某个点，而是"这个领域有哪些东西，它们怎么关联"。

**解决什么问题：** "这个领域有哪些关键概念？从哪里开始？"

**例子：**
- `attention-mechanisms-overview` — 注意力机制全景：从 self-attention 到 flash-attention
- `retrieval-augmented-generation-overview` — RAG 全景：从 BM25 到 dense retrieval
- `training-techniques-overview` — 训练技术全景：从预训练到 RLHF

**什么时候创建：** wiki 在某个领域积累了足够多的概念页面，需要一个入口来组织它们。

### 为什么需要四种类型？

不同类型有不同的**阅读目的**和**更新策略**：

| | concept | entity | comparison | overview |
|--|---------|--------|------------|----------|
| **回答什么** | 这是什么？ | 这个具体东西？ | A vs B？ | 这个领域有什么？ |
| **内容结构** | 原理 + 变体 + 应用 | 元数据 + 背景 | 并排对比表 | 地图 + 链接 |
| **更新频率** | 中（技术演变） | 低（事实稳定） | 低（对比结论稳定） | 高（领域不断扩展） |
| **来源要求** | 2+ 来源或核心主题 | 2+ 来源提到 | 用户提问触发 | 领域积累到一定规模 |

## Wiki 目录结构

```
wiki/
├── SCHEMA.md           # 约定、结构规则、标签分类法（活文档）
├── index.md            # 内容目录，每页一行摘要
├── log.md              # 操作日志（只追加，超 500 条轮转）
├── raw/                # 原始来源（不可变，只读）
│   ├── articles/       # 网络文章
│   ├── papers/         # PDF、论文
│   ├── transcripts/    # 会议笔记、访谈
│   └── assets/         # 图片、图表
├── entities/           # 实体页面
├── concepts/           # 概念页面
├── comparisons/        # 比较页面
├── overviews/          # 总览页面
└── queries/            # 归档的查询结果
```

## 引用追溯

每段内容都能追溯到具体来源：

- **段落级：** `^[knowledge-compilation.md]` — 该段来自哪个文件
- **Claim 级：** `^[architecture-notes.md:42-58]` — 精确到来源文件的行范围

## Obsidian（可选）

[Obsidian](https://obsidian.md) 是一个 markdown 笔记应用，可以用 Graph View 可视化 wiki 的链接网络。
Wiki 目录可以直接用 Obsidian 打开——不需要额外配置。

Obsidian 是**可选的浏览工具**。在 MiMo Code 中直接对话就能完成所有操作（摄入、查询、检查），
Obsidian 只是提供了图形化的浏览体验。需要查看链接网络或使用搜索面板时可以打开它。

## MCP Server（可选）

通过 [MCP](https://modelcontextprotocol.io) 可以让 MiMo Code 直接读写 Obsidian vault。
需要安装 [cyanheads/obsidian-mcp-server](https://github.com/cyanheads/obsidian-mcp-server) 和
[Omnisearch](https://github.com/scambier/obsidian-omnisearch) 插件（提供 BM25 搜索）。

MCP 是**可选的增强**。没有 MCP 时代理直接读写文件系统，效果一样。MCP 提供了更结构化的读写方式和 BM25 搜索能力。

## 相关工具

[llm-wiki-compiler](https://github.com/atomicmemory/llm-wiki-compiler) — Node.js CLI，将来源编译成概念 wiki。适合想要定时/CLI 驱动的编译流水线。

## 参考

- [MiMo Code 规则文档](https://mimo.xiaomi.com/zh/mimocode/rules)
- [MiMo Code 技能文档](https://mimo.xiaomi.com/zh/mimocode/skills)
- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [cyanheads/obsidian-mcp-server](https://github.com/cyanheads/obsidian-mcp-server)
- [Omnisearch](https://github.com/scambier/obsidian-omnisearch)
- [llm-wiki-compiler](https://github.com/atomicmemory/llm-wiki-compiler)
