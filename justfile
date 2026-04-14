# SnapClaude - 跨平台开发环境一键配置
# Usage: just <recipe>
#
# 注意：推荐使用 bash install.sh 一键安装，会自动判断平台

# ============================================================
# 检测当前平台
# ============================================================
detect-platform:
    @case "$(uname -s)" in \
        Darwin*)  echo "macos" ;; \
        Linux*)   echo "linux" ;; \
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;; \
        *)        echo "unknown" ;; \
    esac

# ============================================================
# macOS
# ============================================================
install-all-macos:
    cd platforms/macos && just install-all

install-claude-macos:
    cd platforms/macos && just install-claude

status-macos:
    cd platforms/macos && just status

# ============================================================
# Linux
# ============================================================
install-all-linux:
    cd platforms/linux && just install-all

install-claude-linux:
    cd platforms/linux && just install-claude

status-linux:
    cd platforms/linux && just status

# ============================================================
# Windows
# ============================================================
install-all-windows:
    @powershell -ExecutionPolicy Bypass -File platforms/windows/install.ps1

install-claude-windows:
    @powershell -ExecutionPolicy Bypass -File platforms/windows/install.ps1 -Target claude

status-windows:
    @powershell -ExecutionPolicy Bypass -File core/status.ps1
