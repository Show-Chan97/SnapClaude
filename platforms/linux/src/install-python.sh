#!/usr/bin/env bash
set -e
# install-python.sh - Python 安装（Linux）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"

step "安装 Python..."

if is_installed python3; then
    ver=$(python3 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
    ok "Python3 已安装 (v$ver)"
    exit 0
fi

if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv
elif command -v yum &> /dev/null; then
    sudo yum install -y python3 python3-pip
fi

# 配置 pip 镜像
if is_installed pip3; then
    mkdir -p "$HOME/.config/pip"
    echo "[global]" > "$HOME/.config/pip/pip.conf"
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> "$HOME/.config/pip/pip.conf"
    ok "pip 已配置国内镜像"
fi

ok "Python 安装完成: $(python3 --version)"
