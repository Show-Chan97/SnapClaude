#!/usr/bin/env bash
# core/detect.sh - 系统环境检测（各平台通用）

# -------------------- 颜色 --------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}   $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail()  { echo -e "${RED}[FAIL]${NC} $1"; }
step()  { echo -e "${CYAN}[STEP]${NC} $1"; }

# -------------------- 操作系统检测 --------------------
detect_os() {
    case "$(uname -s)" in
        Darwin*)  echo "macos" ;;
        Linux*)   echo "linux" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# -------------------- CPU 架构检测 --------------------
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "x64" ;;
        arm64|aarch64) echo "arm64" ;;
        *)             echo "x64" ;;
    esac
}

# -------------------- 平台合并 --------------------
detect_platform() {
    local os=$(detect_os)
    local arch=$(detect_arch)
    case "$os" in
        macos)  [ "$arch" == "arm64" ] && echo "darwin-arm64" || echo "darwin-x64" ;;
        linux)  [ "$arch" == "arm64" ] && echo "linux-arm64"  || echo "linux-x64" ;;
        windows) [ "$arch" == "arm64" ] && echo "windows-arm64" || echo "windows-x64" ;;
        *)      echo "unsupported" ;;
    esac
}

# -------------------- 版本比较 --------------------
version_ge() {
    # 返回 0 表示 $1 >= $2
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# -------------------- 工具检测 --------------------
check_tool() {
    local cmd=$1
    if command -v "$cmd" &> /dev/null; then
        local ver=$($cmd --version 2>/dev/null | head -1 || echo "unknown")
        echo "found:$ver"
    else
        echo "not_found"
    fi
}

detect_git()    { check_tool git; }
detect_node()   { local v=$(node --version 2>/dev/null || echo ""); echo "${v:+found:${v#v}}"; }
detect_python() {
    local v=$(python3 --version 2>/dev/null || python --version 2>/dev/null || echo "")
    echo "${v:+found:${v#Python }}"
}
detect_vscode() { check_tool code; }
detect_claude() { check_tool claude; }

export -f detect_os detect_arch detect_platform version_ge
export -f detect_git detect_node detect_python detect_vscode detect_claude
