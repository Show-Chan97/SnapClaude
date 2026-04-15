#!/usr/bin/env bash
set -e
# install-claude-plugins.sh - Claude Code LSP 插件和 MCP 注册（Linux）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${SCRIPT_DIR}/core/detect.sh"
source "${SCRIPT_DIR}/core/common.sh"

step "注册 Claude Code 插件和服务..."

if ! is_installed claude; then
    warn "Claude Code 未安装，跳过"
    exit 0
fi


info "注册 Jupyter MCP..."
claude mcp add jupyter "http://127.0.0.1:8888/mcp" 2>/dev/null && ok "Jupyter MCP 已注册" || warn "Jupyter MCP 注册失败"

info "跳过 onboarding..."
mkdir -p "$HOME/.claude"
if [ -f "$HOME/.claude/settings.json" ]; then
    python3 -c "
import json
f='$HOME/.claude/settings.json'
with open(f) as fh: s=json.load(fh)
s['hasCompletedOnboarding']=True
with open(f,'w') as fh: json.dump(s,fh,indent=2)
" 2>/dev/null || true
else
    echo '{"hasCompletedOnboarding":true}' > "$HOME/.claude/settings.json"
fi
ok "Onboarding 已跳过"

ok "插件注册完成"
