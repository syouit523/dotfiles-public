#!/bin/bash
# Xcode Command Line Tools が未インストールならインストールを開始し、完了まで待つ。
# 既にインストール済みなら何もしない。

set -e

if xcode-select -p &>/dev/null; then
    echo "Xcode Command Line Tools already installed."
    exit 0
fi

echo "Installing Xcode Command Line Tools..."
xcode-select --install || true

# インストール完了を待機（CLT は GUI ダイアログを出して非同期で進む）
# ユーザーがダイアログをキャンセルすると永久に完了しないため、
# タイムアウト（30分）を設けて無限ループを防ぐ
echo "Waiting for Xcode Command Line Tools installation to complete..."
MAX_WAIT_SECONDS=1800
waited=0
until xcode-select -p &>/dev/null; do
    if [ "$waited" -ge "$MAX_WAIT_SECONDS" ]; then
        echo "Error: Xcode Command Line Tools installation did not complete within $((MAX_WAIT_SECONDS / 60)) minutes." >&2
        echo "The installation dialog may have been cancelled. Re-run this script to try again." >&2
        exit 1
    fi
    sleep 5
    waited=$((waited + 5))
done

echo "Xcode Command Line Tools installed."
