#!/usr/bin/env bash
# core/status.sh - 查看安装状态

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# PROJECT_ROOT 由 wrapper 传入，或直接运行时使用 dirname 推导
if [ -n "$PROJECT_ROOT" ]; then
    source "${PROJECT_ROOT}/core/detect.sh"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "${SCRIPT_DIR}/detect.sh"
fi

check() {
    local label=$1
    local detector=$2
    local result
    result=$($detector)
    if [[ "$result" == found:* ]]; then
        local ver="${result#found:}"
        printf "  %-12s ${GREEN}✓${NC}  %s\n" "$label" "$ver"
    else
        printf "  %-12s ${RED}✗${NC}  未安装\n" "$label"
    fi
}

echo ""
echo "  SnapClaude 环境状态"
echo "  ==================="
echo ""
echo -e "  平台:   ${GREEN}$(detect_platform)${NC}"
echo ""

check "Git"         detect_git
check "Node.js"     detect_node
check "Python"      detect_python
check "VSCode"      detect_vscode
check "Claude Code" detect_claude

echo ""
echo -e "  运行 ${GREEN}just install-all${NC} 安装全部"
echo ""
