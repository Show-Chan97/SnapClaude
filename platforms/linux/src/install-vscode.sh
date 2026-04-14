#!/usr/bin/env bash
set -e
# install-vscode.sh - VSCode 安装（Linux）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"

step "安装 VSCode..."

if is_installed code; then
    ver=$(code --version 2>/dev/null | head -1)
    ok "VSCode 已安装 (v$ver)"
    exit 0
fi

if command -v apt-get &> /dev/null; then
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt-get update
    sudo apt-get install -y code
else
    warn "apt-get 未找到，跳过"
fi
