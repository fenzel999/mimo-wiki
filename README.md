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

### 安装

一行命令安装到项目或全局：

```bash
# 方式 A：安装到当前项目（项目级）
npx --yes degit fenzel999/mimo-wiki/skills/llm-wiki skills/llm-wiki
curl -sL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/AGENTS.md -o AGENTS.md

# 方式 B：安装到全局（所有项目可用）
npx --yes degit fenzel999/mimo-wiki/skills/llm-wiki ~/.mimocode/skills/llm-wiki
curl -sL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/AGENTS.md -o ~/.mimocode/AGENTS.md
```

安装后目录结构：

```
你的项目/  (或 ~/.mimocode/)
├── AGENTS.md                    # 全局规则 — 始终在上下文中
└── skills/
    └── llm-wiki/
        ├── SKILL.md             # 操作指南 — 按需加载
        ├── templates/           # 模板文件
        │   ├── schema-template.md
        │   ├── index-template.md
        │   └── log-template.md
        └── references/          # 参考资料
            ├── bm25-search.js   # BM25 搜索脚本
            ├── bm25.md          # BM25 算法说明
            ├── page-types.md    # 页面类型详解
            └── citations.md     # 引用语法详解
```

- **AGENTS.md** — 始终在上下文中，保持精简，只写"必须/不要"的规则
- **SKILL.md** — 按需加载，包含操作流程
- **templates/** — 初始化 wiki 时使用
- **references/** — 搜索、创建页面、写引用时按需读取

### 初始化 Wiki

在 MiMo Code 中说：

> "帮我创建一个新的 LLM Wiki，领域是 AI/ML 研究"

代理会创建 wiki 目录结构、SCHEMA.md、index.md、log.md。

### 使用

#### 摄入来源

```
你：帮我把这篇文章摄入 wiki: https://arxiv.org/abs/1706.03762

代理：（读取论文 → 提取概念 → 创建页面 → 更新索引和日志）
     创建了以下页面：
     - concepts/self-attention.md
     - concepts/multi-head-attention.md
     - entities/transformer.md
```

#### 切换会话后查询（知识跨会话持久化）

```
=== 会话 1（周一）===
你：帮我摄入这 3 篇关于注意力机制的论文
代理：（创建了 self-attention、multi-head-attention、flash-attention 等页面）
你：/new（关闭会话）

=== 会话 2（周三，全新会话）===
你：Flash Attention 和标准注意力的区别是什么？

代理：（自动读 SCHEMA → index → log → 发现页面已存在 → 读取 → 综合回答）

     基于 [[flash-attention]] 和 [[self-attention]] 页面：
     Flash Attention 通过 IO 感知的分块算法将注意力计算的
     内存复杂度从 O(n²) 降到 O(n)，同时保持数值精确...
     ^[flash-attention.md:12-28]

你：（不需要重新提供那 3 篇论文，代理已经知道）
```

#### 健康检查

```
你：帮我检查 wiki 健康状况

代理：（扫描所有页面）
     ⚠ 孤儿页面：entities/old-model.md（无入站链接）
     ⚠ 断链：[[deprecated-api]] 指向不存在的页面
     ⚠ 数据差距：多个页面提到 "LoRA" 但缺少独立概念页面
     建议：摄入一篇 LoRA 论文来填补这个差距
```

## 四种页面类型

| 类型 | 回答什么 | 示例 | 何时创建 |
|------|---------|------|---------|
| **concept** | "这个东西是什么" | self-attention, fine-tuning | 2+ 来源提到，或核心主题 |
| **entity** | "这个具体东西" | gpt-4, karpathy, anthropic | 2+ 来源提到 |
| **comparison** | "A vs B" | transformer-vs-rnn | 用户提问触发 |
| **overview** | "这个领域有什么" | attention-mechanisms-overview | 领域积累到一定规模 |

## 引用追溯

- **段落级：** `^[knowledge-compilation.md]` — 该段来自哪个文件
- **Claim 级：** `^[architecture-notes.md:42-58]` — 精确到行范围

## Wiki 目录结构

```
wiki/
├── SCHEMA.md           # 约定、标签分类法（活文档，协同进化）
├── index.md            # 内容目录，每页一行摘要
├── log.md              # 操作日志（只追加，超 500 条轮转）
├── raw/                # 原始来源（不可变）
│   ├── articles/
│   ├── papers/
│   ├── transcripts/
│   └── assets/
├── entities/           # 实体页面
├── concepts/           # 概念页面
├── comparisons/        # 比较页面
├── overviews/          # 总览页面
└── queries/            # 归档的查询结果
```

## Obsidian（可选）

Wiki 目录可以直接用 [Obsidian](https://obsidian.md) 打开——
Graph View 可视化链接网络，Dataview 查询 frontmatter。

在 MiMo Code 中直接对话就能完成所有操作，Obsidian 只是可选的浏览工具。

## 参考

- [MiMo Code 规则文档](https://mimo.xiaomi.com/zh/mimocode/rules)
- [MiMo Code 技能文档](https://mimo.xiaomi.com/zh/mimocode/skills)
- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [GitHub 仓库](https://github.com/fenzel999/mimo-wiki)
