#!/usr/bin/env bash
# brew.sh - Homebrew bootstrap helpers for macOS installers

find_brew() {
    if command -v brew &> /dev/null; then
        command -v brew
        return 0
    fi

    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$brew_bin" ]; then
            echo "$brew_bin"
            return 0
        fi
    done

    return 1
}

load_homebrew() {
    local brew_bin
    brew_bin="$(find_brew)" || return 1
    eval "$("$brew_bin" shellenv)"
}

ensure_homebrew() {
    if load_homebrew; then
        ok "Homebrew 已就绪: $(brew --version | head -1)"
        return 0
    fi

    if ! command -v curl &> /dev/null; then
        fail "curl 未安装，无法自动安装 Homebrew"
        exit 1
    fi

    info "Homebrew 未安装，开始自动安装..."
    info "安装过程中可能需要输入 macOS 登录密码，这是 Homebrew 官方安装脚本的正常行为。"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if ! load_homebrew; then
        fail "Homebrew 安装后仍无法加载，请重新打开终端后再运行安装命令"
        exit 1
    fi

    local brew_bin shellrc shellenv_line
    brew_bin="$(command -v brew)"
    shellrc="$HOME/.zshrc"
    [ -n "${BASH_VERSION:-}" ] && [ -f "$HOME/.bash_profile" ] && shellrc="$HOME/.bash_profile"
    shellenv_line="eval \"\$(${brew_bin} shellenv)\""

    if ! grep -Fq "$shellenv_line" "$shellrc" 2>/dev/null; then
        printf '\n# Homebrew\n%s\n' "$shellenv_line" >> "$shellrc"
    fi

    ok "Homebrew 安装完成: $(brew --version | head -1)"
}

export -f find_brew load_homebrew ensure_homebrew
