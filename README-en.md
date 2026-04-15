# SnapClaude

One-command cross-platform development environment setup. Automatically detects macOS / Windows / Linux and installs everything you need.

## Features

- **Cross-platform**: Auto-detects your OS, downloads only what's needed
- **Idempotent**: Safe to run multiple times — won't re-install if already present
- **China-friendly**: Falls back to mirrors when direct downloads fail
- **Sparse checkout**: Only your platform's scripts are downloaded

## Requirements

- **macOS / Linux**: [just](https://github.com/casey/just) >= 1.20
- **Windows**: PowerShell 5.0+
- **macOS recommended**: [Homebrew](https://brew.sh)
- **Git recommended**: `>= 2.25` for Sparse Checkout support (older versions will silently fallback to full codebase sync).
- **WSL Users**: Script auto-detects WSL and skips VSCode installation in the subsystem. Please install VSCode on your Windows host and use the `Remote - WSL` extension.

## Install

### Option A: One-liner (recommended)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Show-Chan97/SnapClaude/main/install.sh)
```

Automatically detects your OS, pulls the right platform scripts, runs the install.

### Option B: Manual clone

```bash
git clone https://github.com/Show-Chan97/SnapClaude
cd snapclaude

# Only checkout your platform (saves bandwidth)
git sparse-checkout set platforms/macos install.sh README.md

# Run
just install-all
```

### Option C: Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/Show-Chan97/SnapClaude/main/platforms/windows/install.ps1 | iex
```

> **🛠️ Troubleshooting**: If the installation fails, you can enable debug logging:
> ```powershell
> # 1. Download script
> irm https://raw.githubusercontent.com/Show-Chan97/SnapClaude/main/platforms/windows/install.ps1 -OutFile install.ps1
> 
> # 2. Unlock execution policy (applies to this session only)
> Set-ExecutionPolicy Bypass -Scope Process -Force
> 
> # 3. Run with debug logging
> .\install.ps1 -DebugLog
> ```


## Usage

```bash
just install-all        # Install everything (Git / Node.js / Python / VSCode / Claude Code)
just install-claude     # Claude Code only + deps
just install-git        # Git only
just install-node       # Node.js only
just install-python     # Python only
just install-vscode    # VSCode only
just status             # Check installation status
```

## What's installed

| Tool | Min Version | Description |
|------|-------------|-------------|
| Git | >= 2.40 | Version control |
| Node.js | >= 18 | JavaScript runtime |
| Python | >= 3.9 | Python runtime |
| VSCode | latest | Code editor |
| Claude Code | latest | Anthropic CLI |

### Claude Code auto-registration

- MCP server: `http://127.0.0.1:8888/mcp` (Jupyter)
- Skips onboarding

## Directory structure

```
snapclaude/
├── install.sh              # Bootstrap (detects OS + sparse checkout)
├── README.md
├── justfile                 # Root justfile (routes to platforms)
├── core/                    # Shared across all platforms
│   ├── detect.sh            # OS / arch detection
│   ├── common.sh            # Common utilities
│   ├── download.sh          # Smart download with mirror fallback
│   ├── status.sh            # Status check (bash)
│   ├── status.ps1           # Status check (PowerShell)
│   └── update.sh            # Update script
└── platforms/
    ├── macos/               # macOS specific (Homebrew)
    │   ├── justfile
    │   └── src/             # install-*.sh
    ├── windows/              # Windows specific (PowerShell)
    │   ├── justfile
    │   ├── install.ps1      # PowerShell entry point
    │   └── src/
    └── linux/               # Linux specific (apt/yum/dnf)
        ├── justfile
        └── src/
```

## Mirror fallback

No manual config needed — when a download fails, mirrors kick in automatically:

- GitHub Releases → `gh-proxy.com` / `ghproxy.com`
- npm → `registry.npmmirror.com`
- pip → Tsinghua / Aliyun mirrors

## 🤝 Acknowledgments

During the development of this project, some of the cross-platform concepts and core script structures were inspired by the open-source project [raystyle/oymywinclaude](https://github.com/raystyle/oymywinclaude). We would like to express our gratitude to its author!

## License

MIT
