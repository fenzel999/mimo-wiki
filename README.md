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
| 版本历史 | 通常无 | git 仓库天然支持 |
| 适用场景 | 噪声数据的临时检索 | 需要保存、可审查、可追溯的持久知识 |

Wiki 就是一个 git 仓库——你天然拥有版本历史、分支和协作能力。

## 如何使用本项目

### 第 1 步：把规则和技能放入项目

将 `AGENTS.md` 放到你的项目根目录（或其他 MiMo Code 项目目录），将 `skills/llm-wiki/` 目录放到项目的 `skills/` 目录下：

```
你的项目/
├── AGENTS.md                 # 全局规则
└── skills/
    └── llm-wiki/
        └── SKILL.md          # 操作手册
```

MiMo Code 会自动加载 `AGENTS.md` 作为全局规则，按需加载 `skills/llm-wiki/SKILL.md` 作为技能。

### 第 2 步：初始化 Wiki

在 MiMo Code 中说：

> "帮我创建一个新的 LLM Wiki，领域是 AI/ML 研究"

代理会创建 wiki 目录结构、SCHEMA.md、index.md、log.md。

### 第 3 步：摄入来源

把来源丢给代理：

> "帮我把这篇文章摄入 wiki: https://..."

> "把这个 PDF 摄入 wiki"

> "这是我昨天会议的笔记，摄入到 wiki"

代理会：抓取内容 → 概念提取 → 页面生成 → 更新索引和日志。

### 第 4 步：查询和检查

正常对话即可：

| 你说的话 | 会发生什么 |
|---------|-----------|
| "Transformer 和 RNN 的主要区别？" | 读 index → 找相关页面 → 综合回答 → 引用 [[页面]] |
| "帮我检查 wiki 健康状况" | 扫描孤儿页面、断链、引用错误、数据差距、建议新来源 |
| "最近 5 次摄入了什么？" | 读 log.md 最后 5 条 |

### 第 5 步：随 wiki 进化 SCHEMA.md

SCHEMA.md 不是一次写完的——随着领域理解加深，你会和代理一起调整标签分类法、约定和规则。
代理可以提议新标签、新约定，但你的确认后才会写入。

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

## Wiki 目录结构

初始化后的 wiki 目录：

```
wiki/
├── SCHEMA.md           # 约定、结构规则、标签分类法（活文档）
├── index.md            # 内容目录，每页一行摘要
├── log.md              # 操作日志（只追加，超 500 条轮转）
├── .obsidian/          # Obsidian 配置
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

Wiki 就是一个 markdown 文件目录，同时也是一个 Obsidian vault。

## 两阶段编译

摄入来源时分两个阶段：

1. **概念提取** — 先读完全部来源，提取所有实体和概念，跨来源重叠概念标记为合并候选
2. **页面生成** — 基于全局概念集合生成页面，共享概念合并为一个页面

这消除了顺序依赖：先看完所有来源再写页面，避免重复和遗漏合并。

## 来源新鲜度

wiki 自动追踪每个页面依赖的来源文件及其内容哈希：

- **Stale** — 来源文件内容已变化，页面需要重新编译
- **Orphaned** — 来源文件已删除，页面成为孤儿

检查时会报告这些状态，帮你保持 wiki 与来源同步。

## 四种页面类型

| 类型 | 说明 | 示例 |
|------|------|------|
| **concept** | 独立的想法、技术或模式 | self-attention, knowledge-compilation |
| **entity** | 具体的命名事物 | andrej-karpathy, gpt-4 |
| **comparison** | 两个或多个概念的并排分析 | transformer-vs-rnn |
| **overview** | 连接某领域多个相关概念的地图 | attention-mechanisms-overview |

## 引用追溯

每段内容都能追溯到具体来源，两种精度：

- **段落级：** `^[knowledge-compilation.md]` — 该段来自哪个文件
- **Claim 级：** `^[architecture-notes.md:42-58]` — 精确到来源文件的行范围

## 三种核心操作

1. **摄入 (Ingest)** — 把来源（URL、PDF、文本）集成到 wiki：概念提取 → 页面生成 → 更新索引和日志
2. **查询 (Query)** — 基于 wiki 编译的知识回答问题，引用来源页面，有价值的答案归档回 wiki
3. **检查 (Lint)** — 扫描孤儿页面、断链、引用错误、数据差距、建议新来源

## Obsidian 集成

Wiki 目录开箱即用作为 Obsidian vault——直接在 Obsidian 中打开 wiki/ 文件夹即可。

### 安装 Obsidian

1. 从 [obsidian.md](https://obsidian.md) 下载安装
2. 打开 → "Open folder as vault" → 选择 wiki 目录
3. 完成。开始浏览 wiki

### 推荐插件

#### 必装插件

##### 1. Omnisearch — BM25 全文搜索

**作用：** 为 Obsidian 提供高质量的全文搜索能力，使用 BM25 算法（与 Elasticsearch 相同的底层算法）。

**为什么需要：**
- Obsidian 内置搜索只支持简单的子串匹配
- Omnisearch 支持**语义相关性排序**——搜索 "attention mechanism" 会优先显示最相关的页面
- 支持**中文搜索**（默认的英文分词器对中文效果有限，但比内置搜索好很多）
- 支持**拼写容错**——输错几个字母也能找到
- 支持**引号短语**精确匹配和 `-排除` 语法
- 支持 `path:` 和 `ext:` 过滤器
- 安装 Text Extractor 插件后可搜索 PDF 和图片中的文字（OCR）

**安装：**
1. Obsidian → Settings → Community Plugins → Browse
2. 搜索 "Omnisearch" → Install → Enable
3. 无需额外配置，BM25 搜索立即可用

**使用：**
- `Ctrl+Shift+F`（或 `Cmd+Shift+F`）打开搜索面板
- 输入关键词 → 结果按 BM25 相关性排序
- `"`multi-head attention"` — 精确匹配短语
- `attention -self` — 排除包含 "self" 的结果
- `path:concepts transformer` — 只在 concepts 目录搜索

**与 MCP 的关系：**
- 安装 Omnisearch 后，MCP 工具 `obsidian_search_notes` 的 `omnisearch` 模式自动可用
- 代理可以通过 MCP 调用 BM25 搜索，无需你手动操作

---

##### 2. Dataview — SQL 查询 frontmatter

**作用：** 用类似 SQL 的语法查询所有笔记的 YAML frontmatter，生成动态表格和列表。

**为什么需要：**
- wiki 的每个页面都有 frontmatter（tags, kind, confidence, sources 等）
- Dataview 可以**动态查询**这些元数据，无需手动维护列表
- 可以创建"活的"索引——自动列出所有 concept 页面、所有 confidence < 0.5 的页面等
- 可以按标签、类型、日期、来源数量等维度聚合

**安装：**
1. Settings → Community Plugins → Browse
2. 搜索 "Dataview" → Install → Enable
3. Settings → Dataview → 开启 "Enable JavaScript Queries"（可选，更强大）

**使用示例：**

```dataview
TABLE kind, confidence, sources
FROM "concepts"
WHERE confidence < 0.5
SORT updated DESC
```
→ 列出所有 confidence < 0.5 的概念页面，按更新时间倒序

```dataview
LIST
FROM #model
SORT file.name ASC
```
→ 列出所有带 `#model` 标签的页面

```dataview
TABLE length(sources) AS "来源数"
FROM ""
WHERE kind = "concept"
SORT length(sources) DESC
```
→ 按来源数量排序所有概念页面（来源越多越可靠）

**高级用法：**
- `Dataview JS` — 用 JavaScript 写更复杂的查询
- `TASK` 查询 — 收集所有笔记中的待办事项
- `CALENDAR` — 按日期可视化笔记

---

##### 3. Web Clipper — 浏览器一键剪藏

**作用：** 浏览器扩展，一键将网页转换为干净的 markdown 保存到 Obsidian vault。

**为什么需要：**
- 网页是 wiki 的主要来源之一
- 手动复制粘贴会丢失格式、图片、链接
- Web Clipper 自动提取正文、转换 markdown、下载图片
- 可以预设保存位置（如 `raw/articles/`）
- 是往 wiki 添加网络来源**最便捷的方式**

**安装：**
1. Chrome Web Store 或 Firefox Add-ons 搜索 "Obsidian Web Clipper"
2. 安装扩展
3. 点击扩展图标 → 设置：
   - **Vault** → 选择你的 wiki 目录
   - **Folder** → `raw/articles`
   - **Template** → 可选，自定义剪藏模板
4. 浏览网页时点击扩展图标 → 自动保存为 markdown

**使用：**
- 浏览到想保存的文章 → 点击 Web Clipper 图标
- 自动提取正文、标题、作者、发布日期
- 图片自动下载到 `raw/assets/`
- 保存为 `raw/articles/文章标题.md`
- 你可以在保存前编辑内容、添加标签

**与代理协作：**
- 剪藏后告诉代理："帮我摄入刚剪藏的文章"
- 代理会读取文件、执行两阶段编译、更新 wiki

---

#### 推荐插件

##### 4. Graph View — 链接网络可视化（内置）

**作用：** 可视化 wiki 中所有页面之间的链接关系，以节点和连线的形式展示。

**为什么需要：**
- 直观看到哪些页面是**枢纽**（被多个页面链接）
- 发现**孤岛页面**（没有入站链接的页面）
- 理解知识结构——哪些概念紧密关联，哪些是孤立的
- 帮助决定哪些页面需要更多交叉引用

**使用：**
- 左侧边栏点击 "Open graph view" 图标（或 `Ctrl+G`）
- 节点 = 页面，连线 = `[[wikilinks]]`
- 颜色 = 按标签或目录分组
- 点击节点跳转到该页面
- 拖拽节点重新布局

**设置：**
- Settings → Graph → 显示标签颜色、调整节点大小
- Local Graph（单页视图）— 只看当前页面的链接关系

---

##### 5. Marp — Markdown 幻灯片

**作用：** 直接从 markdown 内容生成演示文稿（PPT/PDF），无需 PowerPoint。

**为什么需要：**
- wiki 中的知识可以直接转化为演示材料
- 适合给团队分享 wiki 中的研究成果
- 纯 markdown 格式，版本控制友好

**安装：**
1. Settings → Community Plugins → Browse
2. 搜索 "Marp for Obsidian" → Install → Enable

**使用：**
- 在笔记顶部添加 Marp frontmatter：
  ```yaml
  ---
  marp: true
  ---
  ```
- 用 `---` 分隔每页幻灯片
- 用 `<!-- _class: lead -->` 控制样式
- 右键 → "Marp: Export Slide Deck" → 导出 PDF/HTML/PPTX

**示例：**
```markdown
---
marp: true
---

# Transformer 架构
## 自注意力机制详解

---

## 核心思想

- 注意力计算值的加权和
- 多头注意力并行应用 h 次
- 位置编码注入序列信息

---

## 与 RNN 的区别

| | Transformer | RNN |
|--|------------|-----|
| 并行性 | ✅ 完全并行 | ❌ 顺序处理 |
| 长距离依赖 | ✅ 直接建模 | ⚠️ 梯度消失 |
```

---

##### 6. Tag Wrangler — 标签批量管理

**作用：** 批量重命名、合并、删除标签，保持标签分类法的一致性。

**为什么需要：**
- wiki 增长过程中，标签可能会不一致（如 `model` vs `models`）
- 手动修改每个文件的 frontmatter 很痛苦
- Tag Wrangler 一键重命名，自动更新所有使用该标签的文件

**安装：**
1. Settings → Community Plugins → Browse
2. 搜索 "Tag Wrangler" → Install → Enable

**使用：**
- 在标签面板（Tag Pane）中右键点击标签
- 选择 "Rename tag..."
- 输入新名称 → 自动更新所有文件
- 支持重命名嵌套标签（如 `model/transformer` → `architecture/transformer`）

---

##### 7. Periodic Notes — 周期性笔记模板

**作用：** 创建日记、周记、月记、年记，支持自定义模板。

**为什么需要：**
- 记录 wiki 的使用日志和思考过程
- 周记可以总结本周摄入的来源和发现
- 月记可以回顾 wiki 的增长和方向调整

**安装：**
1. Settings → Community Plugins → Browse
2. 搜索 "Periodic Notes" → Install → Enable

**设置：**
- Settings → Periodic Notes → 配置：
  - **Daily Note** → 格式 `YYYY-MM-DD`，模板可选
  - **Weekly Note** → 格式 `YYYY-Www`，如 `2026-W27`
  - **Monthly Note** → 格式 `YYYY-MM`

**模板示例（周记）：**
```markdown
# 周记 {{date:YYYY-Www}}

## 本周摄入
- 

## 本周发现
- 

## 下周计划
- 

## Wiki 状态
- 总页面数：
- 新增页面：
- 需要审查的页面：
```

---

##### 8. Text Extractor — PDF/OCR 文本提取

**作用：** 从 PDF、图片中提取文字，让 Omnisearch 可以搜索这些内容。

**为什么需要：**
- wiki 的 `raw/papers/` 中可能有 PDF 论文
- 默认情况下 Obsidian 无法搜索 PDF 内容
- Text Extractor 提取 PDF 文字 → Omnisearch 可以 BM25 搜索
- 支持 OCR（图片中的文字）

**安装：**
1. Settings → Community Plugins → Browse
2. 搜索 "Text Extractor" → Install → Enable

**使用：**
- 安装后自动生效
- Omnisearch 搜索时会自动包含 PDF 和图片中的文字
- 无需手动操作

---

### 推荐设置

Settings → Files and links：
- **Attachment folder path** → `raw/assets`（图片统一存储）
- **Default location for new notes** → `wiki/` 根目录
- **New link format** → `Shortest path`
- **Use Wikilinks** → 开启

Settings → Hotkeys：
- "Download attachments for current file" → `Ctrl+Shift+D`（图片本地化快捷键）

## Obsidian MCP Server

通过 [MCP (Model Context Protocol)](https://modelcontextprotocol.io) 让 MiMo Code 直接读写 Obsidian vault。

### 推荐方案：cyanheads/obsidian-mcp-server

⭐ 611 | 14 个工具 | 最全面 | 支持 BM25（通过 Omnisearch）

**安装步骤：**

1. **安装 Obsidian REST API 插件：**
   - Obsidian → Settings → Community Plugins → Browse
   - 搜索 "Local REST API" → Install → Enable
   - 记下 API Key（Settings → Local REST API → API Key）

2. **配置 MCP Server：**

   在你的 MCP 配置文件中添加（根据你使用的客户端）：

   **Claude Desktop** (`%APPDATA%\Claude\claude_desktop_config.json`)：
   ```json
   {
     "mcpServers": {
       "obsidian": {
         "command": "npx",
         "args": ["-y", "obsidian-mcp-server"],
         "env": {
           "OBSIDIAN_API_KEY": "你的API密钥"
         }
       }
     }
   }
   ```

   **VS Code** (`settings.json`)：
   ```json
   {
     "mcp.servers": {
       "obsidian": {
         "command": "npx",
         "args": ["-y", "obsidian-mcp-server"],
         "env": {
           "OBSIDIAN_API_KEY": "你的API密钥"
         }
       }
     }
   }
   ```

3. **重启客户端**，MCP 工具自动可用

### 可用工具

| 工具 | 功能 |
|------|------|
| `obsidian_get_note` | 读取笔记（全文/结构/单节/frontmatter） |
| `obsidian_list_notes` | 列出目录下的笔记 |
| `obsidian_list_tags` | 列出所有标签及使用次数 |
| `obsidian_search_notes` | **搜索**（text/jsonlogic/omnisearch BM25） |
| `obsidian_write_note` | 创建/替换笔记 |
| `obsidian_append_to_note` | 追加内容到笔记 |
| `obsidian_patch_note` | 精确编辑（标题/块/frontmatter） |
| `obsidian_replace_in_note` | 全文搜索替换 |
| `obsidian_manage_frontmatter` | 原子操作 frontmatter 字段 |
| `obsidian_manage_tags` | 添加/删除/列出标签 |
| `obsidian_delete_note` | 删除笔记 |
| `obsidian_open_in_ui` | 在 Obsidian 中打开文件 |
| `obsidian_execute_command` | 执行 Obsidian 命令面板命令 |
| `obsidian_list_commands` | 列出可用命令 |

### BM25 搜索（Omnisearch）

当 Omnisearch 插件安装后，`obsidian_search_notes` 工具的 `omnisearch` 模式自动可用：

```json
{
  "name": "obsidian_search_notes",
  "arguments": {
    "query": "transformer attention",
    "mode": "omnisearch"
  }
}
```

三种搜索模式对比：

| 模式 | 方式 | 速度 | 质量 | 适用场景 |
|------|------|------|------|---------|
| `text` | 子串匹配 | 最快 | 基础 | 快速找关键词 |
| `jsonlogic` | 结构化查询 | 中等 | 精确 | 按 frontmatter/tags/路径过滤 |
| `omnisearch` | **BM25 排名** | 较慢 | **最好** | 语义相关搜索、拼写容错 |

### 备选方案：StevenStavrakis/obsidian-mcp

⭐ 717 | 更简单 | 不需要 REST API 插件

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": ["-y", "obsidian-mcp", "C:\\Users\\你的用户名\\wiki"]
    }
  }
}
```

工具较少但更轻量：read-note、create-note、edit-note、search-vault、manage-tags。

## 相关工具

[llm-wiki-compiler](https://github.com/atomicmemory/llm-wiki-compiler) — Node.js CLI，将来源编译成概念 wiki，灵感同样来自 Karpathy。兼容 Obsidian，适合想要定时/CLI 驱动的编译流水线。

权衡：llm-wiki-compiler 接管页面生成（替代代理对页面创建的判断），针对小语料调优。需要代理在循环中策展时用 mimo-wiki 技能；想要批量编译来源目录时用 llm-wiki-compiler。

## 参考

- [MiMo Code 规则文档](https://mimo.xiaomi.com/zh/mimocode/rules)
- [MiMo Code 技能文档](https://mimo.xiaomi.com/zh/mimocode/skills)
- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [cyanheads/obsidian-mcp-server](https://github.com/cyanheads/obsidian-mcp-server) — 最全面的 Obsidian MCP
- [StevenStavrakis/obsidian-mcp](https://github.com/StevenStavrakis/obsidian-mcp) — 轻量替代
- [Omnisearch](https://github.com/scambier/obsidian-omnisearch) — BM25 搜索插件
- [Obsidian Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) — MCP 依赖
- [llm-wiki-compiler](https://github.com/atomicmemory/llm-wiki-compiler)
- [llmwiki 文档](https://llmwiki.atomicstrata.ai)
