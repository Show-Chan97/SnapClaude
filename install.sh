#!/usr/bin/env bash
# install.sh - SnapClaude Bootstrap
# 自动检测系统，使用 Git Sparse Checkout 拉取对应平台脚本
#
# 用法:
#   bash install.sh              # 交互式
#   bash install.sh macos        # 指定平台

set -e

# -------------------- 检测 --------------------
detect_os() {
    case "$(uname -s)" in
        Darwin*)  echo "macos" ;;
        Linux*)   echo "linux" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# -------------------- 颜色 --------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail()  { echo -e "${RED}[FAIL]${NC} $1"; }

# -------------------- 主 --------------------
main() {
    local TARGET_PLATFORM="${1:-}"
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local PLATFORM_DIR="${SCRIPT_DIR}/platforms"

    # 如果没有指定平台，检测
    if [ -z "$TARGET_PLATFORM" ]; then
        TARGET_PLATFORM=$(detect_os)
    fi

    # 验证平台
    if [ ! -d "${PLATFORM_DIR}/${TARGET_PLATFORM}" ]; then
        fail "不支持的平台: $TARGET_PLATFORM"
        echo "支持的平台: macos / windows / linux"
        exit 1
    fi

    # 如果是 git 仓库，使用 sparse checkout
    if [ -d "${SCRIPT_DIR}/.git" ] && [ "$SCRIPT_DIR" != "$HOME" ]; then
        info "配置 Git Sparse Checkout (若 Git < 2.25 将静默降级为全量代码)..."
        git sparse-checkout init --cone 2>/dev/null || true
        git sparse-checkout set "platforms/${TARGET_PLATFORM}" "install.sh" "README.md" 2>/dev/null || true
        ok "本地仓库代码目录已优化"
    fi

    # 执行对应平台的安装
    echo ""
    info "开始安装 (${TARGET_PLATFORM})..."
    echo ""

    if [ "$TARGET_PLATFORM" == "windows" ]; then
        # Windows: 用 PowerShell
        powershell -ExecutionPolicy Bypass -File "${PLATFORM_DIR}/${TARGET_PLATFORM}/install.ps1"
    else
        # Mac/Linux: 用 just 或 bash
        if command -v just &> /dev/null; then
            cd "${PLATFORM_DIR}/${TARGET_PLATFORM}"
            just install-all
        else
            warn "just 未安装，尝试直接运行脚本..."
            cd "${PLATFORM_DIR}/${TARGET_PLATFORM}"
            bash src/install-all.sh
        fi
    fi

    echo ""
    ok "安装完成！运行 just status 或 bash src/status.sh 查看状态"
}

main "$@"
