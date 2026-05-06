#!/usr/bin/env bash
# status.sh - 状态查看（macOS wrapper）
# 脚本在 platforms/macos/src 下
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
exec bash "${PROJECT_ROOT}/core/status.sh" "$@"
