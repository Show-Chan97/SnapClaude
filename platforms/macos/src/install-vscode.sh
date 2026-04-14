#!/usr/bin/env bash
set -e
# install-vscode.sh - VSCode 安装（macOS）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"

step "安装 VSCode..."

if is_installed code; then
    ver=$(code --version 2>/dev/null | head -1)
    ok "VSCode 已安装 (v$ver)"
    exit 0
fi

if ! command -v brew &> /dev/null; then
    fail "Homebrew 未安装"
    exit 1
fi

brew install --cask visual-studio-code
ok "VSCode 安装完成"
