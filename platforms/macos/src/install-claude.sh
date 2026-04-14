#!/usr/bin/env bash
set -e
# install-claude.sh - Claude Code CLI 安装（macOS）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"

step "安装 Claude Code..."

# 检查依赖
if ! is_installed git; then
    info "Git 未安装，先安装..."
    bash "${SCRIPT_DIR}/platforms/macos/src/install-git.sh"
fi

if ! is_installed node; then
    info "Node.js 未安装，先安装..."
    bash "${SCRIPT_DIR}/platforms/macos/src/install-node.sh"
fi

if is_installed claude; then
    ok "Claude Code 已安装: $(claude --version 2>/dev/null | head -1)"
    exit 0
fi

if ! is_installed npm; then
    fail "npm 未找到"
    exit 1
fi

info "正在安装 @anthropic-ai/claude-code..."
# 尝试安装，若失败则回退到代理源
if ! npm install -g @anthropic-ai/claude-code; then
    warn "默认 npm 由于网络原因可能安装失败，尝试使用国内镜像加速..."
    npm install -g @anthropic-ai/claude-code --registry="https://registry.npmmirror.com"
fi

if is_installed claude; then
    ok "Claude Code 安装完成: $(claude --version 2>/dev/null | head -1)"
else
    fail "Claude Code 安装失败"
    exit 1
fi
