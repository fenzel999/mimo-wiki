# log.md 模板

```markdown
# Wiki Log

> 所有 wiki 操作的按时间顺序记录。只追加。
> 格式：`## [YYYY-MM-DDThh:mm:ssZ] operation | description`
> 操作：ingest, compile, update, query, lint, create, archive, delete
> 当此文件超过 500 条时，轮转：重命名为 log-YYYY.md，重新开始。

## [2026-06-05T09:14:02Z] ingest | Attention Is All You Need
- 摄入来源: https://arxiv.org/abs/1706.03762
- 页面: [[self-attention]], [[multi-head-attention]], [[transformer]]

## [2026-06-05T09:15:30Z] query | What is multi-head attention?
- 页面: [[multi-head-attention]], [[self-attention]]
- 已归档: 是
```

因为只有标题以 `## [` 开头，可以用标准 shell 工具提取近期操作：
```bash
grep "^## \[" log.md | tail -5
```
