#!/usr/bin/env bash
set -e
# install-node.sh - Node.js 安装（macOS）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"
source "${SCRIPT_DIR}/platforms/macos/src/brew.sh"

step "安装 Node.js..."

if is_installed node; then
    ver=$(node --version 2>/dev/null | tr -d 'v')
    ok "Node.js 已安装 (v$ver)"
    exit 0
fi

ensure_homebrew

brew install node
ok "Node.js 安装完成: $(node --version)"
