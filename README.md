# SnapClaude

跨平台开发环境一键配置工具。自动识别 macOS / Windows / Linux，一条命令完成安装。

## 特性

- **跨平台**：自动检测系统，仅下载对应平台脚本
- **幂等安装**：重复运行不会重复安装
- **国内加速**：直连失败自动切换镜像
- **按需拉取**：使用 Git Sparse Checkout，只下载目标平台的文件

## 依赖

- macOS / Linux: [just](https://github.com/casey/just) >= 1.20
- Windows: PowerShell 5.0+
- macOS 额外推荐: [Homebrew](https://brew.sh)

## 安装

### 方式 A：一键安装（推荐）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/snapclaude/main/install.sh)
```

自动检测系统并拉取对应平台脚本，全程无感。

### 方式 B：手动 clone

```bash
git clone https://github.com/YOUR_USERNAME/snapclaude
cd snapclaude

# 只 checkout 对应平台（节省下载）
git sparse-checkout set platforms/macos install.sh README.md

# 安装
just install-all
```

### 方式 C：Windows PowerShell 直接跑

```powershell
irm https://raw.githubusercontent.com/YOUR_USERNAME/snapclaude/main/install.sh | iex
```

## 使用

```bash
just install-all        # 安装全部（Git / Node.js / Python / VSCode / Claude Code）
just install-claude     # 只装 Claude Code 及依赖
just install-git        # 只装 Git
just install-node       # 只装 Node.js
just install-python     # 只装 Python
just install-vscode     # 只装 VSCode
just status             # 查看安装状态
```

## 安装内容

| 工具 | 版本要求 | 说明 |
|------|----------|------|
| Git | >= 2.40 | 代码版本管理 |
| Node.js | >= 18 | JavaScript 运行时 |
| Python | >= 3.9 | Python 运行时 |
| VSCode | 最新版 | 代码编辑器 |
| Claude Code | 最新版 | Anthropic CLI |

### Claude Code 自动注册

- LSP 插件：`pyright`、`typescript`、`powershell`
- Skills：`playwright`
- MCP 服务：`http://127.0.0.1:8888/mcp`（Jupyter）
- 跳过 onboarding

## 目录结构

```
snapclaude/
├── install.sh              # Bootstrap（自动判断系统 + sparse checkout）
├── README.md
├── justfile                 # 根 justfile（中转）
├── core/                    # 各平台通用
│   ├── detect.sh            # 系统检测
│   ├── common.sh            # 公共函数
│   ├── download.sh          # 智能下载（镜像回退）
│   ├── status.sh            # 状态查看（bash）
│   └── status.ps1           # 状态查看（PowerShell）
└── platforms/
    ├── macos/               # macOS 专用
    │   ├── justfile
    │   └── src/             # 安装脚本
    ├── windows/              # Windows 专用
    │   ├── justfile
    │   ├── install.ps1       # PowerShell 入口
    │   └── src/
    └── linux/               # Linux 专用
        ├── justfile
        └── src/
```

## 国内网络

无需手动配置，下载失败时自动切换：
- GitHub Releases → `gh-proxy.com` / `ghproxy.com`
- npm → `registry.npmmirror.com`
- pip → 清华 / 阿里云镜像

## License

MIT
