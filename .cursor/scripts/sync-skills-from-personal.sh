#!/usr/bin/env bash
# 从个人目录导入 skills 到当前项目（镜像同步）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="${HOME}/.cursor/skills"
DST="${ROOT}/.cursor/skills"
mkdir -p "$DST"
rsync -a --delete --exclude='.DS_Store' "$SRC/" "$DST/"
echo "已同步: $SRC -> $DST"
