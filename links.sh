#!/bin/sh
set -e

BASE_DIR="/algorithm-hami-xb0416"
TARGET_DIR="$(cd "$(dirname "$0")" && pwd)"

for name in datasets instructions models results; do
    src="$BASE_DIR/$name"
    dst="$TARGET_DIR/$name"

    if [ ! -e "$src" ]; then
        echo "跳过: 源路径不存在 -> $src"
        continue
    fi

    if [ -L "$dst" ]; then
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        echo "跳过: 目标已存在且不是软链接 -> $dst"
        continue
    fi

    ln -s "$src" "$dst"
    echo "已创建: $dst -> $src"
done
