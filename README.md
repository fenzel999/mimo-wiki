# mimo-wiki

为 MiMo Code 提供 Karpathy LLM Wiki 模式的全局规则和技能。

基于 [Andrej Karpathy 的 LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)，
让你的 AI 编程助手像维护知识库一样持续积累和交叉引用知识，而非每次从零检索。

## 仓库结构

```
mimo-wiki/
├── AGENTS.md                    # 全局规则（通过网络远程加载到 MiMo Code）
├── skills/
│   └── llm-wiki/
│       └── SKILL.md             # LLM Wiki 技能（复制到本地或远程加载）
└── README.md                    # 本文件
```

## 它是怎么工作的

| 文件 | 作用 | 加载方式 |
|------|------|----------|
| `AGENTS.md` | Wiki 模式的规则约束，始终在上下文中 | 远程 URL 自动拉取 |
| `skills/llm-wiki/SKILL.md` | 完整的操作模板和步骤，按需加载 | 复制到本地目录 或 远程 URL |

AGENTS.md 始终在上下文中，所以保持精简（只写规则）；SKILL.md 在代理需要时才加载，
包含完整的 SCHEMA 模板、摄入/查询/检查的逐步步骤、Obsidian 集成等。

## 配置步骤

### 第 1 步：推送仓库到 GitHub

将本仓库推送到你的 GitHub，确保为公开仓库（public），这样远程 URL 才能访问。

### 第 2 步：配置全局规则（远程加载 AGENTS.md）

编辑你的 MiMo Code 全局配置文件：

- **Windows：** `C:\Users\<你的用户名>\.config\mimocode\mimocode.json`
- **Linux/macOS：** `~/.config/mimocode/mimocode.json`

写入以下内容，将 URL 中的 `<你的用户名>` 替换为你的 GitHub 用户名：

```json
{
  "$schema": "https://mimo.xiaomi.com/mimocode/config.json",
  "instructions": [
    "https://raw.githubusercontent.com/<你的用户名>/mimo-wiki/main/AGENTS.md"
  ]
}
```

> 远程指令的获取超时时间为 5 秒。所有指令文件都会与项目中的 AGENTS.md 合并。

### 第 3 步：安装技能

**方式 A — 复制到本地（推荐）**

将仓库中的 `skills/llm-wiki/SKILL.md` 复制到全局技能目录：

- **Windows：** `C:\Users\<你的用户名>\.config\mimocode\skills\llm-wiki\SKILL.md`
- **Linux/macOS：** `~/.config/mimocode/skills/llm-wiki/SKILL.md`

也可以放在项目级别的技能目录：`.mimocode/skills/llm-wiki/SKILL.md`

**方式 B — 远程加载**

在 `mimocode.json` 中添加 `skills.urls`，免去手动复制：

```json
{
  "$schema": "https://mimo.xiaomi.com/mimocode/config.json",
  "instructions": [
    "https://raw.githubusercontent.com/<你的用户名>/mimo-wiki/main/AGENTS.md"
  ],
  "skills": {
    "urls": [
      "https://raw.githubusercontent.com/<你的用户名>/mimo-wiki/main/skills/llm-wiki/SKILL.md"
    ]
  }
}
```

MiMo Code 搜索技能的目录：

| 位置 | 说明 |
|------|------|
| `~/.config/mimocode/skills/**/SKILL.md` | 全局技能 |
| `.mimocode/skills/**/SKILL.md` | 项目级技能 |
| `~/.claude/skills/**/SKILL.md` | 兼容目录（全局） |
| `.claude/skills/**/SKILL.md` | 兼容目录（项目级） |
| `.agents/`, `.codex/`, `.opencode/` | 其他兼容目录 |

### 第 4 步：设置 Wiki 路径（可选）

通过环境变量 `WIKI_PATH` 指定 wiki 目录，不设置则默认 `~/wiki`：

```bash
# Linux/macOS
export WIKI_PATH=~/wiki

# Windows (PowerShell)
$env:WIKI_PATH = "$HOME\wiki"
```

## 使用方法

在 MiMo Code 中正常对话即可，例如：

| 你说的话 | 会发生什么 |
|---------|-----------|
| "帮我创建一个新的 LLM Wiki，领域是 AI/ML 研究" | 初始化 wiki 目录结构、SCHEMA.md、index.md、log.md |
| "帮我把这篇文章摄入 wiki: https://..." | 抓取内容→存 raw/→创建/更新实体和概念页面→更新索引和日志 |
| "Transformer 和 RNN 的主要区别？" | 读 index→找相关页面→综合回答→引用 [[页面]] |
| "帮我检查 wiki 健康状况" | 扫描孤儿页面、断链、陈旧内容、矛盾等 |

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
└── queries/            # 归档的查询结果
```

### 三种核心操作

1. **摄入 (Ingest)** — 把来源（URL、PDF、文本）集成到 wiki：存原始文件→检查已有页面→创建/更新 wiki 页面→更新索引和日志
2. **查询 (Query)** — 基于 wiki 编译的知识回答问题，引用来源页面，有价值的答案归档
3. **检查 (Lint)** — 扫描孤儿页面、断链、索引完整性、陈旧内容、矛盾、来源漂移等

### Obsidian 集成

Wiki 目录开箱即用作为 Obsidian vault：
- `[[wikilinks]]` 渲染为可点击链接
- Graph View 可视化知识网络
- YAML frontmatter 驱动 Dataview 查询
- 建议将 Obsidian 附件文件夹设置为 `raw/assets/`

## 更新流程

修改了仓库中的文件后：

1. **AGENTS.md** — 推送到 GitHub 即可，下次启动 MiMo Code 时自动从远程拉取最新版本
2. **SKILL.md** — 推送到 GitHub 后，需重新复制到本地技能目录（如果用方式 A）；用方式 B 则自动拉取

## 权限配置（可选）

在 `mimocode.json` 中控制代理对技能的访问权限：

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "llm-wiki": "allow"
    }
  }
}
```

| 权限 | 行为 |
|------|------|
| `allow` | 技能立即加载 |
| `deny` | 对代理隐藏技能 |
| `ask` | 加载前提示用户确认 |

## 参考文档

- [MiMo Code 规则文档](https://mimo.xiaomi.com/zh/mimocode/rules)
- [MiMo Code 技能文档](https://mimo.xiaomi.com/zh/mimocode/skills)
- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
