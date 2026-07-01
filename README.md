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

## 安装

### 项目级

当前目录，只影响这个项目。

**Windows：**
```powershell
irm https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.ps1 | iex
```

**macOS / Linux：**
```bash
curl -sSL https://raw.githubusercontent.com/fenzel999/mimo-wiki/master/install.sh | bash
```

### 全局

`~/.config/mimocode/`，所有项目可用。

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

## 使用

安装后在 MiMo Code 中说：

> "帮我创建一个新的 LLM Wiki，领域是 AI/ML 研究"

### 摄入来源

```
你：帮我把这篇文章摄入 wiki: https://arxiv.org/abs/1706.03762
代理：创建了 self-attention、multi-head-attention、transformer 等页面
```

### 切换会话后查询

```
=== 会话 1 ===
你：帮我摄入这 3 篇论文

=== 会话 2（全新会话）===
你：Flash Attention 和标准注意力的区别？
代理：（页面已存在，直接综合回答）
```

## 四种页面类型

| 类型 | 回答什么 | 示例 |
|------|---------|------|
| **concept** | "这个东西是什么" | self-attention |
| **entity** | "这个具体东西" | gpt-4, karpathy |
| **comparison** | "A vs B" | transformer-vs-rnn |
| **overview** | "这个领域有什么" | attention-overview |

## 参考

- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [MiMo Code 文档](https://mimo.xiaomi.com/zh/mimocode)
- [GitHub 仓库](https://github.com/fenzel999/mimo-wiki)
