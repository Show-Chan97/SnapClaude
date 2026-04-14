#!/usr/bin/env bash
set -e
# install-python.sh - Python 安装（macOS）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"

step "安装 Python..."

if is_installed python3; then
    ver=$(python3 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
    ok "Python3 已安装 (v$ver)"
    exit 0
fi

if ! command -v brew &> /dev/null; then
    fail "Homebrew 未安装"
    exit 1
fi

brew install python@3.11

# 配置 pip 镜像
mkdir -p "$HOME/Library/Application Support/pip"
echo "[global]" > "$HOME/Library/Application Support/pip/pip.conf"
echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> "$HOME/Library/Application Support/pip/pip.conf"
ok "pip 已配置国内镜像"

ok "Python 安装完成: $(python3 --version)"
