#!/usr/bin/env bash
set -e
# install-node.sh - Node.js 安装（Linux）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"

step "安装 Node.js..."

if is_installed node; then
    ver=$(node --version 2>/dev/null | tr -d 'v')
    ok "Node.js 已安装 (v$ver)"
    exit 0
fi

# 使用 NodeSource
if command -v curl &> /dev/null; then
    version="18"
    curl -fsSL "https://deb.nodesource.com/setup_${version}.x" | sudo bash -
    sudo apt-get install -y nodejs
else
    fail "curl 未找到"
    exit 1
fi

ok "Node.js 安装完成: $(node --version)"
