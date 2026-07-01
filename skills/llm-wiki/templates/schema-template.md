# SCHEMA.md 模板

根据用户领域调整此模板。

```markdown
# Wiki Schema

## 领域
[这个 wiki 覆盖什么 — 例如 "AI/ML 研究"、"个人健康"、"创业情报"]

## 约定
- 文件名：小写、连字符、无空格（如 `transformer-architecture.md`）
- 每个 wiki 页面以 YAML frontmatter 开头（见下方）
- 使用 `[[wikilinks]]` 在页面间链接（每页至少 2 个出站链接）
- 更新页面时始终更新 `updated` 日期
- 每个新页面必须添加到 `index.md` 的正确分区下
- 每个操作必须追加到 `log.md`

## Frontmatter
  ```yaml
  ---
  title: 页面标题
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  kind: concept | entity | comparison | overview | query | summary
  tags: [来自下方分类法]
  sources: [source-name.md]
  # 认识论元数据（可选但推荐）：
  confidence: 0.82            # 0-1 之间，低于 0.5 标记待审查
  provenanceState: extracted | merged | inferred | ambiguous
  contradictedBy:             # 与此页面冲突的页面
    - slug: other-page-slug
  aliases:                    # 别名，使 [[别名]] 也能解析到本页
    - MHA
    - multi-head self-attention
  ---
  ```

`sources` 使用 bare filename（相对于 raw/ 目录），不加 `raw/` 前缀。
例如来自 `raw/articles/karpathy-llm-wiki.md` 的来源写 `karpathy-llm-wiki.md`。

`confidence` 和 `provenanceState` 是可选但推荐的，用于观点密集或快速变化的主题。
检查时会标记 confidence < 0.5 和有 contradictedBy 的页面供用户审查，防止弱声明
悄悄固化为已接受的 wiki 事实。

### provenanceState 含义

- **extracted** — 直接从一个来源推导
- **merged** — 综合自多个来源（多来源合并到同一页面时始终设为 merged）
- **inferred** — LLM 推理出了来源中没有明确声明的结论
- **ambiguous** — 来源给出了冲突信号，页面反映编译器的最佳综合

### raw/ Frontmatter

原始来源也有一个小 frontmatter 块，以便重新摄入时检测漂移：

```yaml
---
source_url: https://example.com/article   # 原始 URL（如适用）
ingested: YYYY-MM-DD
sha256: <原始内容正文的十六进制摘要>
---
```

`sha256:` 让未来的重新摄入可以跳过未更改的内容，并在更改时标记漂移。
仅对正文计算（闭合 `---` 之后的所有内容），不包括 frontmatter 本身。

## 标签分类法
[为领域定义 10-20 个顶级标签。在使用新标签之前先在此添加。]

AI/ML 示例：
- 模型: model, architecture, benchmark, training
- 人物/组织: person, company, lab, open-source
- 技术: optimization, fine-tuning, inference, alignment, data
- 元: comparison, timeline, controversy, prediction

规则：页面上的每个标签都必须出现在此分类法中。如果需要新标签，
先在此添加，然后使用。这防止标签蔓延。
```
