# mimo-wiki

Karpathy LLM Wiki 模式的全局规则和技能，为 MiMo Code 提供。

基于 [Andrej Karpathy 的 LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)，
让你的 AI 编程助手像维护知识库一样持续积累和交叉引用知识，而非每次从零检索。

## 为什么用 Wiki 模式

传统方式：每次问 AI，它从零检索、从零综合。问三次同一个话题，它做三次重复工作。

Wiki 模式：一次编译知识，持续更新。交叉引用已经存在，矛盾已被标记，综合分析反映所有已摄入的内容。越用越强。

|  | 传统 RAG | Wiki 模式 |
|--|---------|-----------|
| 主要产物 | 原始分块 | 编译后的 wiki 页面 |
| 查询行为 | 每次重构上下文 | 复用已编译的结构 |
| 知识增长 | 通常临时的 | 通过页面和归档查询不断增殖 |
| 跨来源概念 | 重复分块在检索时竞争 | 合并到一个共享页面 |
| 来源追溯 | 分块引用 | 段落级和 claim 级行范围引用 |
| 新鲜度 | 通常无 | Stale/Orphaned 内置检测 |
| 适用场景 | 噪声数据的临时检索 | 需要保存、可审查、可追溯的持久知识 |

## 仓库结构

```
mimo-wiki/
├── AGENTS.md                    # 全局规则 — "必须/不要"的约束声明
├── skills/
│   └── llm-wiki/
│       └── SKILL.md             # 操作指南 — 完整模板、步骤、陷阱
└── README.md                    # 本文件
```

- **AGENTS.md** — 始终在上下文中，所以保持精简，只写规则
- **SKILL.md** — 按需加载，包含完整的操作模板和步骤

## 使用方法

在 MiMo Code 中正常对话即可：

| 你说的话 | 会发生什么 |
|---------|-----------|
| "帮我创建一个新的 LLM Wiki，领域是 AI/ML 研究" | 初始化 wiki 目录结构、SCHEMA.md、index.md、log.md |
| "帮我把这篇文章摄入 wiki: https://..." | 抓取内容→概念提取→页面生成→更新索引和日志 |
| "Transformer 和 RNN 的主要区别？" | 读 index→找相关页面→综合回答→引用 [[页面]] |
| "帮我检查 wiki 健康状况" | 扫描孤儿页面、断链、引用错误、陈旧内容、矛盾等 |

### Wiki 目录结构

初始化后的 wiki 目录：

```
wiki/
├── SCHEMA.md           # 约定、结构规则、标签分类法
├── index.md            # 内容目录，每页一行摘要
├── log.md              # 操作日志（只追加，超 500 条轮转）
├── raw/                # 原始来源（不可变，只读）
│   ├── articles/       # 网络文章
│   ├── papers/         # PDF、论文
│   ├── transcripts/    # 会议笔记、访谈
│   └── assets/         # 图片、图表
├── entities/           # 实体页面（人物、组织、产品、模型）
├── concepts/           # 概念页面
├── comparisons/        # 比较页面
├── overviews/          # 领域地图页面
└── queries/            # 归档的查询结果
```

Wiki 就是一个 markdown 文件目录。不需要数据库，不需要特殊工具。

### 两阶段编译

摄入来源时分两个阶段：

1. **概念提取** — 先读完全部来源，提取所有实体和概念，跨来源重叠概念标记为合并候选
2. **页面生成** — 基于全局概念集合生成页面，共享概念合并为一个页面

这消除了顺序依赖：先看完所有来源再写页面，避免重复和遗漏合并。

### 来源新鲜度

wiki 自动追踪每个页面依赖的来源文件及其内容哈希：

- **Stale** — 来源文件内容已变化，页面需要重新编译
- **Orphaned** — 来源文件已删除，页面成为孤儿

检查时会报告这些状态，帮你保持 wiki 与来源同步。

### 四种页面类型

| 类型 | 说明 | 示例 |
|------|------|------|
| **concept** | 独立的想法、技术或模式 | self-attention, knowledge-compilation |
| **entity** | 具体的命名事物 | andrej-karpathy, gpt-4 |
| **comparison** | 两个或多个概念的并排分析 | transformer-vs-rnn |
| **overview** | 连接某领域多个相关概念的地图 | attention-mechanisms-overview |

### 引用追溯

每段内容都能追溯到具体来源，两种精度：

- **段落级：** `^[knowledge-compilation.md]` — 该段来自哪个文件
- **Claim 级：** `^[architecture-notes.md:42-58]` — 精确到来源文件的行范围

### 三种核心操作

1. **摄入 (Ingest)** — 把来源（URL、PDF、文本）集成到 wiki：概念提取→页面生成→更新索引和日志
2. **查询 (Query)** — 基于 wiki 编译的知识回答问题，引用来源页面，有价值的答案归档
3. **检查 (Lint)** — 扫描孤儿页面、断链、引用错误、来源新鲜度、矛盾、陈旧内容等

## 可选工具：qmd 搜索引擎

[qmd](https://github.com/tobi/qmd) 是 Karpathy 本人在 Gist 中推荐的本地 markdown 搜索引擎。
当 wiki 增长到 100+ 页面时，`index.md` + grep 就不够用了——qmd 提供混合搜索，全部离线运行。

| Wiki 规模 | 推荐方式 |
|-----------|---------|
| 0-50 页面 | `index.md` 足够 |
| 50-100 页面 | `index.md` + grep |
| 100+ 页面 | 安装 qmd |

### 安装

```bash
# 需要 Node.js >= 22 或 Bun >= 1.0
npm install -g @tobilu/qmd
```

首次使用时自动下载 3 个 GGUF 模型（共 ~2GB）：
- embeddinggemma-300M — 向量嵌入
- qwen3-reranker-0.6B — 结果重排
- qmd-query-expansion-1.7B — 查询扩展

### 配置 wiki 为 qmd collection

```bash
qmd collection add ~/wiki --name wiki

# 添加上下文描述（帮助搜索理解内容）
qmd context add qmd://wiki "LLM Wiki 知识库"
qmd context add qmd://wiki/concepts "概念页面：技术、模式、理论"

# 生成向量嵌入
qmd embed
```

### 搜索方式

```bash
# 关键词搜索（最快）
qmd search "transformer"

# 语义搜索（理解意思，不只是关键词）
qmd vsearch "如何让模型更高效地利用长文本"

# 混合搜索（最佳质量：BM25 + 向量 + LLM 重排）
qmd query "multi-head attention 的工作原理"

# 只搜 wiki collection
qmd query "主题" -c wiki
```

| 命令 | 方式 | 速度 | 质量 | 需要 LLM |
|------|------|------|------|---------|
| `qmd search` | BM25 关键词 | 最快 | 基础 | 否 |
| `qmd vsearch` | 语义向量 | 中等 | 较好 | 嵌入模型 |
| `qmd query` | 混合 + 重排 | 最慢 | 最好 | 三个模型全部 |

### 摄入后更新索引

```bash
qmd update && qmd embed
```

### 中文支持

默认嵌入模型对中文覆盖有限，切换到多语言模型：

```bash
export QMD_EMBED_MODEL="hf:Qwen/Qwen3-Embedding-0.6B-GGUF/Qwen3-Embedding-0.6B-Q8_0.gguf"
qmd embed -f    # 切换后必须全量重新嵌入
```

### MCP Server 模式

让 MiMo Code 直接调用 qmd 搜索工具（`query`、`get`、`multi_get`、`status`）：

```bash
# 标准输入输出（MiMo Code 启动子进程）
qmd mcp

# HTTP 模式（共享长连接，避免重复加载模型）
qmd mcp --http              # localhost:8181
qmd mcp --http --daemon     # 后台守护进程
qmd mcp stop                # 停止
qmd status                  # 查看状态
```

qmd 不是必需的，别在 wiki 还小时就装它——先让 wiki 长起来。

## 可选工具：Obsidian

Obsidian 是一个 markdown 笔记应用，可以用 Graph View 可视化 wiki 的链接网络。
Wiki 目录开箱即用作为 Obsidian vault——直接打开 wiki/ 文件夹即可。

推荐设置：
- 附件文件夹设为 `raw/assets/`
- 启用 Wikilinks
- 安装 Dataview 插件查询 frontmatter
- 安装 Marp 插件生成幻灯片

Obsidian 是**可选的浏览工具**——wiki 本身就是纯 markdown 目录，不需要任何特殊软件。

## 相关工具

[llm-wiki-compiler](https://github.com/atomicmemory/llm-wiki-compiler) — Node.js CLI，将来源编译成概念 wiki，灵感同样来自 Karpathy。兼容 Obsidian，适合想要定时/CLI 驱动的编译流水线。

权衡：llm-wiki-compiler 接管页面生成（替代代理对页面创建的判断），针对小语料调优。需要代理在循环中策展时用 mimo-wiki 技能；想要批量编译来源目录时用 llm-wiki-compiler。

## 参考

- [MiMo Code 规则文档](https://mimo.xiaomi.com/zh/mimocode/rules)
- [MiMo Code 技能文档](https://mimo.xiaomi.com/zh/mimocode/skills)
- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [qmd — 本地 markdown 搜索引擎](https://github.com/tobi/qmd)
- [llm-wiki-compiler](https://github.com/atomicmemory/llm-wiki-compiler)
- [llmwiki 文档](https://llmwiki.atomicstrata.ai)
