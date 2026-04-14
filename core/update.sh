#!/usr/bin/env bash
# core/update.sh - 更新 SnapClaude

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC}  $1"; }

echo ""
info "检查更新..."

cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"

if [ -d ".git" ]; then
    git pull origin main 2>/dev/null && ok "已是最新版本" || ok "更新完成"
else
    echo "非 git 仓库，请手动下载最新版本"
fi

echo ""
ok "运行 just status 查看当前状态"
