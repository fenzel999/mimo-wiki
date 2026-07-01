# mimo-wiki

Karpathy LLM Wiki 模式的全局规则和技能，为 MiMo Code 提供。

基于 [Andrej Karpathy 的 LLM Wiki 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)，
让你的 AI 编程助手像维护知识库一样持续积累和交叉引用知识，而非每次从零检索。

## 为什么用 Wiki 模式

传统方式：每次问 AI，它从零检索、从零综合。问三次同一个话题，它做三次重复工作。

Wiki 模式：一次编译知识，持续更新。交叉引用已经存在，矛盾已被标记，综合分析反映所有已摄入的内容。越用越强。

## 仓库结构

```
mimo-wiki/
├── AGENTS.md                    # 全局规则 — Wiki 模式的约束条件
├── skills/
│   └── llm-wiki/
│       └── SKILL.md             # 操作指南 — 完整模板、步骤、陷阱
└── README.md                    # 本文件
```

- **AGENTS.md** — 始终在上下文中，所以保持精简，只写规则
- **SKILL.md** — 按需加载，包含完整的操作模板和步骤

## 使用方法

在 MiMo Code 中正常对话即可：

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

Wiki 就是一个 markdown 文件目录 — 你可以在 Obsidian、VS Code 或任何编辑器中打开。
不需要数据库，不需要特殊工具。

### 三种核心操作

1. **摄入 (Ingest)** — 把来源（URL、PDF、文本）集成到 wiki：存原始文件→检查已有页面→创建/更新 wiki 页面→更新索引和日志
2. **查询 (Query)** — 基于 wiki 编译的知识回答问题，引用来源页面，有价值的答案归档
3. **检查 (Lint)** — 扫描孤儿页面、断链、索引完整性、陈旧内容、矛盾、来源漂移等

## Obsidian 集成

Wiki 目录开箱即用作为 Obsidian vault：

- `[[wikilinks]]` 渲染为可点击链接
- Graph View 可视化知识网络
- YAML frontmatter 驱动 Dataview 查询
- `raw/assets/` 文件夹存放通过 `![[image.png]]` 引用的图片

最佳实践：

- 将 Obsidian 的附件文件夹设置为 `raw/assets/`
- 在 Obsidian 设置中启用 "Wikilinks"（通常默认开启）
- 安装 Dataview 插件以执行查询，如 `TABLE tags FROM "entities" WHERE contains(tags, "company")`

### 无界面同步（Obsidian Headless）

在没有显示器的服务器上，可以使用 `obsidian-headless` 代替桌面应用。
它通过 Obsidian Sync 无 GUI 同步 vault — 适合代理在服务器上写入 wiki，
同时在 Obsidian 桌面端另一台设备上阅读。

**安装：**
```bash
# 需要 Node.js 22+
npm install -g obsidian-headless

# 登录（需要 Obsidian Sync 订阅）
ob login --email <email> --password '<password>'

# 为 wiki 创建远程 vault
ob sync-create-remote --name "LLM Wiki"

# 连接 wiki 目录到 vault
cd ~/wiki
ob sync-setup --vault "<vault-id>"

# 初始同步
ob sync

# 持续同步（前台 — 用 systemd 跑后台）
ob sync --continuous
```

**systemd 后台持续同步：**
```ini
# ~/.config/systemd/user/obsidian-wiki-sync.service
[Unit]
Description=Obsidian LLM Wiki Sync
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/path/to/ob sync --continuous
WorkingDirectory=/home/user/wiki
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now obsidian-wiki-sync
# 启用 linger 使同步在注销后继续运行：
sudo loginctl enable-linger $USER
```

## 相关工具

[llm-wiki-compiler](https://github.com/atomicmemory/llm-wiki-compiler) — Node.js CLI，将来源编译成概念 wiki，灵感同样来自 Karpathy。兼容 Obsidian，适合想要定时/CLI 驱动的编译流水线。

权衡：它接管页面生成（替代代理对页面创建的判断），针对小语料调优。需要代理在循环中策展时用 mimo-wiki 技能；想要批量编译来源目录时用 llm-wiki-compiler。

## 参考

- [MiMo Code 规则文档](https://mimo.xiaomi.com/zh/mimocode/rules)
- [MiMo Code 技能文档](https://mimo.xiaomi.com/zh/mimocode/skills)
- [Karpathy LLM Wiki 原始 Gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [llm-wiki-compiler](https://github.com/atomicmemory/llm-wiki-compiler)
