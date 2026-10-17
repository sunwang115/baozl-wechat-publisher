# 宝藏郎 Wechat 发布

**一键发布 Markdown 到微信公众号草稿箱 🚀 · 由 [baozl.com](https://baozl.com) 提供**

基于 [wenyan-cli](https://github.com/caol64/wenyan-cli) 封装的发布技能。

---

## ✨ 功能特性

- 🚀 **一键发布** - Markdown 自动转换并推送到草稿箱
- 🎨 **多主题支持** - lapis、phycat、default 等精美主题
- 💻 **代码高亮** - 9 种代码高亮主题，Mac 风格代码块
- 🖼️ **图片自动处理** - 本地/网络图片自动上传到微信图床
- 🔒 **加密访问** - 凭证本地保存，调用微信接口走 HTTPS（TLS 加密），日志掩码不泄露
- 📚 **完整文档** - 详细的使用说明和故障排查指南
- 🌐 **跨平台** - macOS / Windows / HarmonyOS（鸿蒙） / Linux 通用

---

## 🚀 快速开始

### 1. 安装 wenyan-cli

```bash
npm install -g @wenyan-md/cli
```

### 2. 配置凭证（直接编辑 config.env）

技能根目录里有一个**可直接编辑的配置文件 `config.env`**，用编辑器打开，填入你的公众号 AppID 与 AppSecret：

```bash
# config.env
WECHAT_APP_ID=你的AppID
WECHAT_APP_SECRET=你的AppSecret
```

配置读取优先级：环境变量 > `config.env`（推荐）> `.env` > `~/.wenyan.env` > 旧格式 `TOOLS.md`。

> 🔒 凭证仅保存在你本地，传输走 HTTPS 加密，`config.env` 已被 `.gitignore` 忽略，请勿提交到公开仓库。也可运行 `bash ./scripts/setup.sh` 交互式生成并把文件权限设为 600。

**获取凭证：** 公众号后台 →「设置与开发 → 基本配置 → 开发者ID(AppID) / 开发者密码(AppSecret)」。

**配置 IP 白名单（必做）：** 把运行发布命令机器的公网 IP 加入「设置与开发 → 基本配置 → IP白名单」（`curl ifconfig.me` 获取本机公网 IP）。未配置会报 `45166 IP地址不在白名单中`。

### 3. 发布测试文章

```bash
# bash 方式（macOS / Windows Git Bash / Linux）
./scripts/publish.sh example.md

# 或 Node 跨平台方式（推荐鸿蒙 / 无 bash 环境）
node ./scripts/publish.mjs example.md
```

### 4. 查看草稿箱

前往微信公众号后台草稿箱查看：https://mp.weixin.qq.com/

---

## 📝 使用方法

### Markdown 格式要求

文件顶部**必须**包含 frontmatter（`title` 与 `cover` 实测均必填）：

```markdown
---
title: 文章标题（必填！）
cover: ./assets/default-cover.jpg  # 封面图（必填！推荐 1080×864）
---

# 正文开始

你的内容...
```

**封面图推荐：**
- **相对路径**（推荐）：`./assets/default-cover.jpg`（内置默认封面）
- **绝对路径**：`/path/to/cover.jpg`
- **网络图片**：`https://example.com/cover.jpg`
- **尺寸建议**：1080×864（微信推荐比例）

### 发布命令

```bash
# 基本用法（默认主题）
./scripts/publish.sh article.md
node ./scripts/publish.mjs article.md

# 指定主题和代码高亮
./scripts/publish.sh article.md lapis solarized-light
node ./scripts/publish.mjs article.md lapis solarized-light
```

---

## 🎨 主题预览

| 主题 | 风格 | 适合场景 |
|------|------|----------|
| **lapis** | 蓝色优雅 | 技术文章、教程 |
| **phycat** | 绿色清新 | 博客、随笔 |
| **default** | 经典简约 | 通用场景 |

查看完整主题列表：[references/themes.md](references/themes.md)

---

## 🛠️ 故障排查

**1. 错误：`Error: 未能找到文章封面`** — frontmatter 缺少 `cover`，补上即可，或改用内置 `./assets/default-cover.jpg`。

**2. 错误：`Error: 45166 (IP地址不在白名单中)`** — 把运行发布命令机器的公网 IP 加入公众号后台白名单。

**3. 发布成功但看不到文章？** — 文章在草稿箱，需后台审核发布。

**4. 图片上传失败？** — 网络图片无法访问或格式不支持，改用本地图片。

查看完整故障排查指南：[references/troubleshooting.md](references/troubleshooting.md)

---

## 📂 项目结构

```
baozl-wechat-publisher/
├── SKILL.md                     # 技能完整文档
├── README.md                    # 本文件
├── config.env                   # ✅ 直接编辑的凭证配置文件（你只改这里）
├── .env.example                 # 配置模板
├── .gitignore                   # 忽略 config.env / .env 等敏感文件
├── example.md                   # 测试文章示例
├── assets/
│   └── default-cover.jpg        # 默认封面（1080×864）
├── scripts/
│   ├── publish.sh               # bash 发布入口（macOS/Windows Git Bash/Linux）
│   ├── publish.mjs              # Node 跨平台发布入口（含鸿蒙，无需 bash）
│   └── setup.sh                 # 交互式生成 config.env
└── references/
    ├── themes.md                # 主题列表和使用说明
    └── troubleshooting.md       # 详细故障排查指南
```

---

## 🌐 跨平台支持

| 平台 | 推荐入口 |
|------|----------|
| macOS | `bash ./scripts/publish.sh` 或 `node ./scripts/publish.mjs` |
| Windows | Git Bash 里 `bash ./scripts/publish.sh`，或任意终端 `node ./scripts/publish.mjs` |
| HarmonyOS（鸿蒙电脑） | `node ./scripts/publish.mjs`（只需 Node.js ≥ 14） |
| 其他 Linux | 同 macOS |

前置依赖：Node.js ≥ 14、npm。所有平台凭证均通过 HTTPS 加密传输。

---

## 🔧 高级用法

### 自定义主题
```bash
wenyan theme create my-theme
wenyan publish -f article.md -t my-theme
```

### 批量发布
```bash
for file in articles/*.md; do
    ./scripts/publish.sh "$file"
done
```

### 使用环境变量
```bash
export WECHAT_APP_ID=your_id
export WECHAT_APP_SECRET=your_secret
wenyan publish -f article.md
```

---

## 📘 教程

完整使用教程（P2P 异地虚拟局域网）：
https://baozl.com/2026/10/17/p2wlan-%e6%98%af%e4%bb%80%e4%b9%88%ef%bc%9f%e5%bc%80%e6%ba%90%e5%bc%82%e5%9c%b0%e8%99%9a%e6%8b%9f%e5%b1%80%e5%9f%9f%e7%bd%91%e5%ae%8c%e6%95%b4%e6%8c%87%e5%8d%97%ef%bc%9ap2p-%e7%9b%b4%e8%bf%9e%e3%80%81/

---

## 📄 许可证

Apache License 2.0（继承自 wenyan-cli）

---

## 🙏 致谢

- [wenyan-cli](https://github.com/caol64/wenyan-cli) - 优秀的微信公众号发布工具
- [baozl.com](https://baozl.com) - 本技能提供方与维护者

---

📦 **由 baozl.com 提供的「宝藏郎 Wechat 发布」方案** · 联系邮箱：647015850@qq.com · 开源主页：https://baozl.com
