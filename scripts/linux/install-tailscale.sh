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

# Fedora Atomic (Bazzite 等) では公式インストーラが使えない。
# Bazzite は tailscale 同梱のため通常ここには到達しないが、
# 他の ostree 系ディストリのための安全ガード。
if [ -f /run/ostree-booted ]; then
    echo "ostree-based OS detected. The official installer does not support it."
    echo "Install tailscale via rpm-ostree or your distro's mechanism, then re-run."
    exit 0
fi

curl -fsSL https://tailscale.com/install.sh | sh
