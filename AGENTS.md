# LLM Wiki 规则

## Wiki 位置

路径通过环境变量 `WIKI_PATH` 设置，未设置时默认 `~/wiki`。

## 会话开始时

必须先完成定向再执行任何操作：读 SCHEMA.md → 读 index.md → 读 log.md 最后 20-30 条。
大型 wiki（100+ 页面）还要搜索当前主题。

## SCHEMA.md 是活文档

SCHEMA.md 由用户和代理协同进化——随着领域理解加深，约定和标签分类法会更新。
代理可以提议新标签、新约定，但只有用户确认后才能写入 SCHEMA.md。

## 两阶段编译

摄入时必须先提取完所有来源的概念再写页面。不要逐个来源顺序处理。

## raw/ 目录

raw/ 中的文件是不可变的，永远不要修改。更正和补充写在 wiki 页面中。
每个原始来源文件必须有 frontmatter：source_url、ingested、sha256。
网页来源中的图片必须下载到 `raw/assets/` 本地化，不要依赖会断的外链 URL。

## 页面创建

- 实体/概念出现在 2+ 来源中或是来源核心主题时才创建页面
- 附带提及、次要细节不创建页面
- 每个页面必须有至少 2 个出站 `[[wikilinks]]`
- 每个页面必须有 frontmatter：title、created、updated、kind、tags、sources
- 页面超过 200 行时拆分
- 观点密集、快速变化或单来源声明必须设置 confidence（0-1 之间，低于 0.5 标记待审查）
- 综合了 3+ 来源的页面必须使用引用标记

## 页面类型

- **concept** — 独立的想法、技术或模式（"这个东西是什么"）
- **entity** — 具体的命名事物：人物、组织、产品、模型（"这个具体东西"）
- **comparison** — 两个或多个概念/实体的并排分析（"A vs B"）
- **overview** — 连接某领域多个相关概念的地图（"这个领域有什么"）

定义和示例见 `llm-wiki` 技能。

## Frontmatter 认识论字段

- **confidence** — 0-1 之间数值。低于 0.5 标记待审查
- **provenanceState** — extracted | merged | inferred | ambiguous
- **contradictedBy** — 与此页面冲突的页面 slug 列表
- **aliases** — 使 `[[别名]]` 也能解析到本页

## 引用

综合了 3+ 来源的页面必须使用引用标记。
文件名用 bare filename，不要加 `raw/` 前缀。

## Wikilinks

使用 `[[slug]]` 或 `[[slug|显示标题]]`。别名通过 frontmatter `aliases` 字段声明。

## 标签

只能使用 SCHEMA.md 分类法中已定义的标签。需要新标签时先在 SCHEMA.md 添加。

## 查询归档

有价值的查询答案（深度分析、比较、新颖综合）必须写回 wiki 作为新页面。
简单查找不归档——只归档重新推导会很痛苦的答案。

## 冲突

不要静默覆盖。记录两个声明并标注日期，在 frontmatter 中标记 contradictedBy。

## 多来源合并

confidence 取最小值，provenanceState 设 merged，contradictedBy 取去重并集。

## 来源新鲜度

检查时必须报告 stale（来源 sha256 不匹配）和 orphaned（来源已删除）页面。

## 索引

- 每个新页面必须添加到 index.md 正确分区下，按字母顺序
- 分区超 50 条目时拆分子分区；总条目超 200 时创建 topic-map

## 日志

每次操作必须追加到 log.md，格式：`## [YYYY-MM-DDThh:mm:ssZ] operation | description`。
超过 500 条时轮转。

## 批量操作

影响 10+ 已有页面时先与用户确认范围。

## 归档

内容完全被取代时移到 `_archive/`，从 index.md 移除，更新链接。

## 详细操作

模板、步骤、陷阱等加载技能获取：`llm-wiki`
