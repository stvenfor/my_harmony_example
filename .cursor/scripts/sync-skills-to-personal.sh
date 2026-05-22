#!/usr/bin/env bash
# 将项目 skills 同步到个人目录（全项目可用）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="${ROOT}/.cursor/skills"
DST="${HOME}/.cursor/skills"
mkdir -p "$DST"
rsync -a --delete --exclude='.DS_Store' "$SRC/" "$DST/"
echo "已同步: $SRC -> $DST"
