# 引用语法

## 段落级引用

段落末尾追加 `^[source-file.md]` 指示该段内容来自哪个来源：

```markdown
知识编译指的是将知识库预处理为支持高效查询的目标语言的一系列技术。^[knowledge-compilation.md]

两阶段编译流水线将概念提取与页面生成分离，使跨来源合并确定性地发生。^[architecture-notes.md]
```

文件名相对于 raw/ 目录，使用 bare filename（不加 `raw/` 前缀）。

## Claim 级引用

对具体数字、技术断言、直接引述，精确定位到行范围，两种等价语法：

```markdown
系统使用两阶段编译流水线。^[architecture-notes.md:42-58]

系统使用两阶段编译流水线。^[architecture-notes.md#L42-L58]
```

Claim 级引用越多，来源追溯越精确。综合了 3+ 来源的页面必须使用引用标记。

## 来源合并时的引用

多来源合并到同一页面时，各段落继续指向实际贡献该段内容的来源文件：

```markdown
注意力机制计算值的加权和。^[attention-paper.md:12-18]

多头注意力并行应用该机制 h 次。^[transformer-architecture.md:44-51]
```

## Wikilinks 和别名

- 使用 `[[slug]]` 简单链接，或 `[[slug|显示标题]]` 管道语法
- 管道语法在页面文件名与显示标题不同时保持链接稳定
- 页面 frontmatter 中声明 `aliases` 字段，使 `[[别名]]` 也能解析到该页面：

```yaml
---
title: Multi-Head Attention
aliases:
  - multi-head self-attention
  - MHA
---
```
