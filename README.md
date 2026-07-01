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
| AGENTS.md | 项目根目录 | `~/.config/mimocode/AGENTS.md` |
| 技能 | `skills/llm-wiki/` | `~/.config/mimocode/skills/llm-wiki/` |

### 项目级安装

**Windows：**
```powershell
irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex
```

**macOS / Linux：**
```bash
curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash
```

### 全局安装

**Windows：**
```powershell
irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install-global.ps1 | iex
```

**macOS / Linux：**
```bash
curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install-global.sh | bash
```

## 卸载

### 项目级

**Windows：**
```powershell
irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/uninstall.ps1 | iex
```

**macOS / Linux：**
```bash
curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/uninstall.sh | bash
```

### 全局

**Windows：**
```powershell
irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/uninstall-global.ps1 | iex
```

**macOS / Linux：**
```bash
curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/uninstall-global.sh | bash
```

## Wiki 目录结构

安装后，让代理创建 wiki，会生成这样的目录：

```
~/wiki/                          ← WIKI_PATH（可自定义）
├── SCHEMA.md                    # 约定、标签分类法（活文档，你和代理一起维护）
├── index.md                     # 内容目录（自动维护）
├── log.md                       # 操作日志（只追加，500 条轮转）
├── raw/                         # 原始来源（不可修改）
│   ├── articles/                # 网络文章
│   ├── papers/                  # PDF、论文
│   ├── transcripts/             # 会议笔记
│   └── assets/                  # 本地化图片
├── concepts/                    # 概念页面
├── entities/                    # 实体页面
├── comparisons/                 # 比较页面
├── overviews/                   # 总览页面
└── queries/                     # 归档的深度查询结果
```

三层架构：**raw/**（不可变的原始来源）→ **wiki 页面**（代理编译维护）→ **SCHEMA.md**（约定和分类法，协同进化）。

`WIKI_PATH` 环境变量控制 wiki 存放位置，不设置则默认 `~/wiki`。

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
  ② 提取所有概念和实体
  ③ 创建/合并页面：self-attention、multi-head-attention、transformer…
  ④ 更新 index.md + log.md
```

一次摄入可能触发 5-15 个页面更新——跨来源的共享概念会被合并，不会重复。

### 3. 查询

```
你：Flash Attention 和标准注意力的区别？

代理：读 index.md → 找到相关页面 → 直接综合回答（引用 [[flash-attention]] [[standard-attention]]）
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

### 5. 健康检查

```
你：帮我检查 wiki 健康度

代理：孤儿页面 / 断裂链接 / 来源失效 / 矛盾标记 / 缺失引用…
```

## 四种页面类型

| 类型 | 回答什么 | 何时创建 | 示例 |
|------|---------|---------|------|
| **concept** | "这个东西是什么" | 2+ 来源提到，且是核心概念 | `self-attention.md` |
| **entity** | "这个具体东西" | 2+ 来源提到，或是某来源的主角 | `gpt-4.md`, `karpathy.md` |
| **comparison** | "A vs B" | 用户提问，或两个相关概念频繁共现 | `transformer-vs-rnn.md` |
| **overview** | "这个领域有什么" | 领域内概念 > 5 个，需要一张地图 | `attention-overview.md` |

页面之间用 `[[wikilinks]]` 互链——从任何一个页面出发，可以跳到所有相关概念。

## 安装后文件清单

```
项目根目录/
├── AGENTS.md                              # 规则（代理必须遵守的约束）
└── skills/llm-wiki/
    ├── SKILL.md                           # 技能（代理的操作步骤）
    ├── templates/
    │   ├── schema-template.md             # SCHEMA.md 模板
    │   ├── index-template.md              # index.md 模板
    │   └── log-template.md                # log.md 模板
    └── references/
        ├── bm25-search.js                 # BM25 搜索（纯 Node.js，零依赖）
        ├── bm25.md                        # BM25 使用说明
        ├── page-types.md                  # 四种页面类型详解
        └── citations.md                   # 引用语法详解
```

- **AGENTS.md** = 规则（"必须…"/"不要…"）——代理必须遵守的约束
- **SKILL.md** = 操作步骤——代理怎么执行各项任务
- **templates/** = 创建 wiki 时用的模板
- **references/** = 代理需要时按需读取的参考文档

## 参考

- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [MiMo Code 文档](https://mimo.xiaomi.com/zh/mimocode)
- [GitHub 仓库](https://github.com/fenzel999/mimo-wiki)
