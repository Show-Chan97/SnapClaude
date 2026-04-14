#!/usr/bin/env bash
set -e
# install-git.sh - Git 安装（macOS）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"

step "安装 Git..."

if is_installed git; then
    ver=$(git --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    ok "Git 已安装 (v$ver)"
    exit 0
fi

if ! command -v brew &> /dev/null; then
    fail "Homebrew 未安装，请先安装 Homebrew: https://brew.sh"
    exit 1
fi

brew install git
ok "Git 安装完成: $(git --version)"
