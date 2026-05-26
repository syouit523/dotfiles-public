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
echo "Waiting for Xcode Command Line Tools installation to complete..."
until xcode-select -p &>/dev/null; do
    sleep 5
done

echo "Xcode Command Line Tools installed."
