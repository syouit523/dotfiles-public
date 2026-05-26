#!/bin/bash
# fish のセットアップ
# - デフォルトシェルへの切替は change-default-shell.sh に委譲（パスワード入力を避けるため）
# - fisher と plugin のインストールを fish のサブシェルで実行

set -e

FISH_BIN="$(command -v fish || true)"
if [ -z "$FISH_BIN" ]; then
    echo "fish is not installed. Skipping."
    exit 0
fi

echo "Installing fisher and plugins via $FISH_BIN..."

# fisher のインストール（既に入っていれば no-op に近い）
"$FISH_BIN" -c '
    if not functions -q fisher
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        and fisher install jorgebucaran/fisher
    end
    if test -f $__fish_config_dir/fish_plugins
        fisher update
    end
'

echo "Fish setup completed."
echo "Note: To make fish your default shell, run 'make change-default-shell' with DOTFILES_DEFAULT_SHELL=fish."
