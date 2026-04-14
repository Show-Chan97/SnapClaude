#!/usr/bin/env bash
# status.sh - 状态查看（macOS wrapper）
# $PWD = platforms/macos，脚本在 src/ 下
PROJECT_ROOT="$(cd "$(pwd)/../.." && pwd)"
exec bash "${PROJECT_ROOT}/core/status.sh" "$@"
