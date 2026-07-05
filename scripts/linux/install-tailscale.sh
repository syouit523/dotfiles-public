#!/bin/bash

set -e

# Tailscale は公式インストーラでインストールする。
# brew formula はバイナリを置くだけで systemd サービス
# (tailscaled の自動起動) を登録しないため、Linux では
# apt リポジトリ登録 + サービス有効化まで行う公式スクリプトを使う。
if command -v tailscale >/dev/null 2>&1; then
    echo "tailscale is already installed. Skipping."
    exit 0
fi

curl -fsSL https://tailscale.com/install.sh | sh
