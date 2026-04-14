#!/usr/bin/env bash
# core/common.sh - 公共函数库（各平台通用）
# 使用前先: source "${SCRIPT_DIR}/../core/common.sh"

# -------------------- 路径配置 --------------------
get_install_prefix() {
    case "$(uname -s)" in
        Darwin*)  echo "$HOME/.local" ;;
        Linux*)   echo "$HOME/.local" ;;
        *)        echo "D:/DevEnvs" ;;
    esac
}

get_bin_dir() {
    case "$(uname -s)" in
        Darwin*)  echo "$HOME/.local/bin" ;;
        Linux*)   echo "$HOME/.local/bin" ;;
        *)        echo "D:/DevEnvs/bin" ;;
    esac
}

add_to_path() {
    local bin_dir=$(get_bin_dir)
    case "$(uname -s)" in
        Darwin*)
            local shellrc="$HOME/.zshrc"
            [ -f "$HOME/.bash_profile" ] && shellrc="$HOME/.bash_profile"
            if ! grep -q "$bin_dir" "$shellrc" 2>/dev/null; then
                printf '\n# SnapClaude\n' >> "$shellrc"
                printf 'export PATH="%s:$PATH"\n' "$bin_dir" >> "$shellrc"
            fi
            ;;
        Linux*)
            local shellrc="$HOME/.bashrc"
            if ! grep -q "$bin_dir" "$shellrc" 2>/dev/null; then
                printf '\n# SnapClaude\n' >> "$shellrc"
                printf 'export PATH="%s:$PATH"\n' "$bin_dir" >> "$shellrc"
            fi
            ;;
    esac
}

# -------------------- 文件操作 --------------------
ensure_dir() {
    [ -d "$1" ] || mkdir -p "$1"
}

is_installed() {
    command -v "$1" &> /dev/null
}

# -------------------- 下载 --------------------
download_file() {
    local url=$1
    local dest=$2

    if command -v curl &> /dev/null; then
        curl -L --fail --progress-bar -o "$dest" "$url" 2>/dev/null && return 0
    elif command -v wget &> /dev/null; then
        wget -q --show-progress -O "$dest" "$url" 2>/dev/null && return 0
    fi
    return 1
}

# -------------------- 校验 --------------------
sha256_check() {
    local file=$1
    local expected=$2
    [ ! -f "$file" ] && return 1
    local actual
    actual=$(shasum -a 256 "$file" 2>/dev/null | awk '{print $1}' || sha256sum "$file" | awk '{print $1}')
    [ "$actual" == "$expected" ]
}

# -------------------- 解压 --------------------
extract_tar() {
    tar -xzf "$1" -C "$2" --strip-components=1
}

extract_zip() {
    unzip -q "$1" -d "$2"
}

export -f get_install_prefix get_bin_dir add_to_path ensure_dir is_installed
export -f download_file sha256_check extract_tar extract_zip
