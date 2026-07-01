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

## 快速开始

### 方式 1：GitHub Template（最简单，零安装）

打开 [mimo-wiki](https://github.com/fenzel999/mimo-wiki) → 点击绿色的 **"Use this template"** 按钮 → **"Create a new repository"**

你的新仓库已包含所有文件。Clone 到本地即可使用。

### 方式 2：npm 安装（需要 Node.js）

```bash
cd your-project && npx mimo-wiki       # 安装到当前项目
npx mimo-wiki --global                 # 安装到全局
npx mimo-wiki --dir ~/my-project       # 安装到指定目录
```

### 方式 3：git sparse checkout（需要 Git）

```bash
git clone --depth 1 --filter=blob:none --sparse https://github.com/fenzel999/mimo-wiki.git temp
cd temp && git sparse-checkout set AGENTS.md skills/llm-wiki
cp AGENTS.md ../ && cp -r skills/llm-wiki ../skills/ && cd .. && rm -rf temp
```

### 安装后

目录结构：

```
你的项目/
├── AGENTS.md                    # 全局规则 — 始终在上下文中
└── skills/
    └── llm-wiki/
        ├── SKILL.md             # 操作指南 — 按需加载
        ├── templates/           # 初始化 wiki 时使用
        └── references/          # 搜索脚本、算法说明等
```

在 MiMo Code 中说：

> "帮我创建一个新的 LLM Wiki，领域是 AI/ML 研究"

## 使用

### 摄入来源

```
你：帮我把这篇文章摄入 wiki: https://arxiv.org/abs/1706.03762
代理：创建了 self-attention、multi-head-attention、transformer 等页面
```

### 切换会话后查询（知识跨会话持久化）

```
=== 会话 1 ===
你：帮我摄入这 3 篇论文
（代理创建页面，你关闭会话）

=== 会话 2（全新会话）===
你：Flash Attention 和标准注意力的区别？

代理：（自动读 SCHEMA → index → log → 页面已存在 → 综合回答）
     基于 [[flash-attention]] 和 [[self-attention]]：...
     ^[flash-attention.md:12-28]

（不需要重新提供论文）
```

### 健康检查

```
你：帮我检查 wiki 健康状况
代理：⚠ 孤儿页面、断链、数据差距、建议新来源
```

## 四种页面类型

| 类型 | 回答什么 | 示例 | 何时创建 |
|------|---------|------|---------|
| **concept** | "这个东西是什么" | self-attention | 2+ 来源或核心主题 |
| **entity** | "这个具体东西" | gpt-4, karpathy | 2+ 来源提到 |
| **comparison** | "A vs B" | transformer-vs-rnn | 用户提问触发 |
| **overview** | "这个领域有什么" | attention-overview | 领域积累到一定规模 |

## Obsidian（可选）

Wiki 目录可直接用 [Obsidian](https://obsidian.md) 打开浏览。
MiMo Code 中直接对话就能完成所有操作。

## 参考

- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [MiMo Code 文档](https://mimo.xiaomi.com/zh/mimocode)
- [GitHub 仓库](https://github.com/fenzel999/mimo-wiki)
