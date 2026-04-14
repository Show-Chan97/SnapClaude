#!/usr/bin/env bash
# core/download.sh - 智能下载（直连优先，失败自动切镜像）
# 用法: source download.sh && download_with_fallback <url> <dest> [sha256]

GITHUB_MIRROR="https://gh-proxy.com"
GITHUB_MIRROR2="https://ghproxy.com"
NPM_MIRROR="https://registry.npmmirror.com"
PIP_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"

download_with_fallback() {
    local primary=$1
    local dest=$2
    local sha256=${3:-""}
    local mirrors=()
    
    if [[ "$primary" == *github.com* ]] || [[ "$primary" == *githubusercontent.com* ]]; then
        mirrors=("${GITHUB_MIRROR}/${primary}" "${GITHUB_MIRROR2}/${primary}")
    fi

    local tmp="${dest}.tmp"

    # 尝试直连
    if download_file "$primary" "$tmp"; then
        [ -n "$sha256" ] && ! sha256_check "$tmp" "$sha256" && { rm -f "$tmp"; false; } || true
        if [ -f "$tmp" ]; then
            mv "$tmp" "$dest"
            return 0
        fi
    fi

    # 尝试镜像
    for mirror in "${mirrors[@]}"; do
        if download_file "$mirror" "$tmp"; then
            [ -n "$sha256" ] && ! sha256_check "$tmp" "$sha256" && { rm -f "$tmp"; continue; } || true
            if [ -f "$tmp" ]; then
                mv "$tmp" "$dest"
                return 0
            fi
        fi
    done

    rm -f "$tmp"
    return 1
}

# 下载 GitHub release asset（根据 pattern 匹配）
download_github_asset() {
    local repo=$1
    local pattern=$2
    local dest=$3
    local sha256=${4:-""}

    local api="https://api.github.com/repos/${repo}/releases/latest"
    local json
    json=$(curl -sL "$api" 2>/dev/null) || json=$(curl -sL "${GITHUB_MIRROR}/${api}" 2>/dev/null) || return 1

    local url
    url=$(echo "$json" | python3 -c "
import sys,json
try:
    for a in json.load(sys.stdin)['assets']:
        if '$pattern' in a['name']:
            print(a['browser_download_url'])
            break
except: pass
" 2>/dev/null) || return 1

    [ -z "$url" ] && return 1
    download_with_fallback "$url" "$dest" "$sha256"
}

export -f download_with_fallback download_github_asset
