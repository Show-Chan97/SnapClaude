#!/usr/bin/env bash
# install.sh - SnapClaude Bootstrap
# 自动检测系统，使用 Git Sparse Checkout 拉取对应平台脚本
#
# 用法:
#   bash install.sh              # 交互式
#   bash install.sh macos        # 指定平台

set -e

REPO_TARBALL_URL="${SNAPCLAUDE_TARBALL_URL:-https://github.com/Show-Chan97/SnapClaude/archive/refs/heads/main.tar.gz}"
REPO_TARBALL_MIRROR_URL="${SNAPCLAUDE_TARBALL_MIRROR_URL:-https://gh-proxy.com/https://github.com/Show-Chan97/SnapClaude/archive/refs/heads/main.tar.gz}"
BOOTSTRAP_TMP_DIR=""

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

cleanup() {
    if [ -n "$BOOTSTRAP_TMP_DIR" ] && [ -d "$BOOTSTRAP_TMP_DIR" ]; then
        rm -rf "$BOOTSTRAP_TMP_DIR"
    fi
}

is_supported_platform() {
    case "$1" in
        macos|windows|linux) return 0 ;;
        *) return 1 ;;
    esac
}

download_project_source() {
    if ! command -v curl &> /dev/null; then
        fail "curl 未安装，无法下载 SnapClaude 安装包" >&2
        exit 1
    fi
    if ! command -v tar &> /dev/null; then
        fail "tar 未安装，无法解压 SnapClaude 安装包" >&2
        exit 1
    fi

    local tmp_dir archive
    tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/snapclaude.XXXXXX")"
    archive="${tmp_dir}/snapclaude.tar.gz"
    BOOTSTRAP_TMP_DIR="$tmp_dir"

    info "正在下载 SnapClaude 安装脚本..." >&2
    if ! curl -fsSL "$REPO_TARBALL_URL" -o "$archive"; then
        warn "GitHub 直连失败，尝试代理下载..." >&2
        curl -fsSL "$REPO_TARBALL_MIRROR_URL" -o "$archive"
    fi

    mkdir -p "${tmp_dir}/src"
    tar -xzf "$archive" -C "${tmp_dir}/src" --strip-components=1
    echo "${tmp_dir}/src"
}

run_shell_installer() {
    local platform_dir=$1
    shift

    cd "$platform_dir"
    if [ -f "src/install-all.sh" ]; then
        bash src/install-all.sh "$@"
        return
    fi

    bash src/install-git.sh
    bash src/install-node.sh
    bash src/install-python.sh
    bash src/install-vscode.sh
    bash src/install-claude.sh
    bash src/install-claude-plugins.sh
}

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
    if ! is_supported_platform "$TARGET_PLATFORM"; then
        fail "不支持的平台: $TARGET_PLATFORM"
        echo "支持的平台: macos / windows / linux"
        exit 1
    fi

    if [ ! -d "${PLATFORM_DIR}/${TARGET_PLATFORM}" ]; then
        SCRIPT_DIR="$(download_project_source)"
        PLATFORM_DIR="${SCRIPT_DIR}/platforms"
    fi

    if [ ! -d "${PLATFORM_DIR}/${TARGET_PLATFORM}" ]; then
        fail "安装包缺少平台目录: ${TARGET_PLATFORM}"
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
            run_shell_installer "${PLATFORM_DIR}/${TARGET_PLATFORM}"
        fi
    fi

    echo ""
    ok "安装完成！运行 claude --version 查看 Claude Code 状态"
}

trap cleanup EXIT
main "$@"
