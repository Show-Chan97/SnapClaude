#!/usr/bin/env bash
set -e
# install-git.sh - Git 安装（Linux）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"

step "安装 Git..."

if is_installed git; then
    ver=$(git --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    ok "Git 已安装 (v$ver)"
    exit 0
fi

if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y git
elif command -v yum &> /dev/null; then
    sudo yum install -y git
elif command -v dnf &> /dev/null; then
    sudo dnf install -y git
else
    fail "未找到包管理器"
    exit 1
fi

ok "Git 安装完成: $(git --version)"
