# ⚡ Snapdragon Claude (SnapClaude)

![Platform](https://img.shields.io/badge/platform-macOS_|_Windows_|_Linux-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-Active-success.svg)

跨平台开发环境一键配置工具。自动识别 macOS / Windows / Linux，一条命令完成所有的开发环境和 Claude Code CLI 安装。

## ✨ 特性

- **跨平台兼容**：自动检测系统，自动挂载并执行对应平台脚本。
- **幂等性安装**：安全！重复运行绝不会重复安装，可作为更新检测工具使用。
- **智能国内加速**：中国大陆直连失败时，自动切换高速代理和镜像（包含 gh-proxy, npmmirror, tuna pip 源）。
- **按需极致拉取**：运用 Git Sparse Checkout 机制，仅拉取您当前平台的文件段落。

## 📦 依赖环境

- **macOS / Linux**: 预装 [just](https://github.com/casey/just) >= 1.20
- **Windows**: PowerShell 5.0+
- **macOS 额外推荐**: 预装 [Homebrew](https://brew.sh)
- **Git 版本推荐**: `>= 2.25`（低版本不支持 Sparse Checkout 机制，会自动静默降级为全量代码同步）
- **WSL 提示**: 脚本已内置 WSL 环境查杀，如果侦测到环境为 WSL，会自动跳过子系统内 VSCode 的安装。推荐在宿主机 (Windows) 安装 VSCode 并配合 `Remote - WSL` 插件连接使用。

---

## 🚀 安装指南

### 方式 A：一键全自动安装（✅ 推荐 macOS / Linux 用户）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Show-Chan97/SnapClaude/main/install.sh)
```
> *自动检测系统并拉取对应平台脚本，全程无感、极速初始化！*

### 方式 B：手动克隆仓库（💻 适合跨平台进阶用户）

```bash
git clone https://github.com/Show-Chan97/SnapClaude
cd SnapClaude

# 若需要节省带宽，可只提取对应平台库
git sparse-checkout set platforms/macos install.sh README.md

# 执行完整安装
just install-all
```

### 方式 C：Windows 原生安装（✅ 推荐 Windows 用户）

如果您的电脑是 Windows 系统，直接打开 `PowerShell` 执行：
```powershell
irm https://raw.githubusercontent.com/Show-Chan97/SnapClaude/main/platforms/windows/install.ps1 | iex
```

**🛠️ 调试与排错**：如果安装遇到问题，可以开启调试日志模式：

```powershell
# 1. 下载脚本
irm https://raw.githubusercontent.com/Show-Chan97/SnapClaude/main/platforms/windows/install.ps1 -OutFile install.ps1 -Encoding UTF8

# 2. 解锁执行策略 (仅对当前窗口有效)
Set-ExecutionPolicy Bypass -Scope Process -Force

# 3. 运行调试
.\install.ps1 -DebugLog
```


> **💡 温馨提示：默认安装路径**
> 系统会自动为您在 `D:\DevEnvs` 构建纯净的独立环境目录；如果您没有 D 盘，系统会智能降级放置在您的 `C:\Users\用户名\DevEnvs` 目录下，绝不污染系统原有的 `Program Files` 目录！

---

## 🛠️ 使用方法与指令

项目自带丰富的颗粒级安装子指令，你可以按需安装想要的环境：

```bash
just install-all        # 安装全部（Git / Node.js / Python / VSCode / Claude Code）
just install-claude     # 只装 Claude Code (含前置依赖)
just install-git        # 只装 Git
just install-node       # 只装 Node.js
just install-python     # 只装 Python
just install-vscode     # 只装 VSCode编辑器
just status             # 查看所有工具当前的安装状态和版本
```

## 📋 安装列表与版本要求

| 工具 | 最低版本要求 | 详情说明 |
|------|----------|------|
| Git | `>= 2.40` | 后续所有代码版本管理 |
| Node.js | `>= 18` | JavaScript 运行时（npm 环境支持）|
| Python | `>= 3.9` | Python 运行时及 Pip 管理器 |
| VSCode | 最新稳定版 | 主力代码编辑器 |
| Claude Code| 最新版 | Anthropic 官方 CLI |

### 🤖 Claude Code 智能自动配置

安装不仅是下载 CLI，更包括对它的底层初始化配置：
- 自动打通 MCP 服务：内嵌 `http://127.0.0.1:8888/mcp`（交互式 Notebook Jupyter）。
- 全程自动跳过人工 onboarding 步骤。

---

## 📂 核心目录结构

```text
SnapClaude/
├── install.sh              # 核心 Bootstrap（通过此入口自动判断系统 + 下载）
├── README.md               # 项目首页
├── LICENSE                 # 开源协议文件
├── justfile                # 根运行配置
├── core/                   # 平台通用模块
│   ├── detect.sh           # OS 及 CPU 架构嗅探
│   ├── download.sh         # 支持网络镜像回退的高智能下载器
│   └── status.sh / .ps1    # 环境诊断探针
└── platforms/              # 各独立平台包
    ├── macos/              # macOS (基于 Homebrew)
    ├── windows/            # Windows (基于 PowerShell Script)
    └── linux/              # Linux Debian/RedHat (apt/yum/dnf 系列)
```

## 🌍 国内网络深度优化

内置了深度网络优化策略。您完全无需手动操作。
在触发主库超时或失败时系统会自动挂钩备用代理：
- GitHub Releases → 动用 `gh-proxy.com` 或备胎分发节点。
- NPM 仓库 → `registry.npmmirror.com` (淘宝源) 无缝加速。
- PIP 仓库 → 优先切换清华 / 阿里云镜像服务。

## 🤝 致谢 (Acknowledgments)

本项目在开发过程中，部分跨平台理念与核心脚本的构建灵感参考了 [raystyle/oymywinclaude](https://github.com/raystyle/oymywinclaude) 开源项目。特此对其开发者的工作表示感谢！

## 📜 许可协议 (License)

本项目采用 **[MIT License](LICENSE)** 开源协议。

- **您可以**：自由地用于商业或非商业项目、修改代码、分发工具。
- **您只需要**：在分发的副本中保留版权声明（详见 `LICENSE` 文件）。

SnapClaude 期待它能给您的跨栈开发环境部署带来最无感的丝滑体验。
