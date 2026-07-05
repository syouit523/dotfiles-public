#!/bin/bash

set -e

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS="$ROOT_DIR/scripts"

# bootstrap 中(brew が PATH に入る前)でも tmux / cmake を見つけられる
# よう、brew の場所を直接 PATH に通す
if ! command -v tmux >/dev/null 2>&1; then
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        if [ -x "$brew_bin" ]; then
            eval "$("$brew_bin" shellenv)"
            break
        fi
    done
fi

# Change to dotfiles-public directory so deps are created there
cd "$ROOT_DIR" || exit

## Install TPM using git-clone.sh
"$SCRIPTS"/git-clone.sh https://github.com/tmux-plugins/tpm "$HOME"/.tmux/plugins/tpm

## Install tmux plugins
"$SCRIPTS"/git-clone.sh https://github.com/tmux-plugins/tmux-resurrect "$HOME"/.tmux/plugins/tmux-resurrect
"$SCRIPTS"/git-clone.sh https://github.com/tmux-plugins/tmux-continuum "$HOME"/.tmux/plugins/tmux-continuum
"$SCRIPTS"/git-clone.sh https://github.com/christoomey/vim-tmux-navigator "$HOME"/.tmux/plugins/vim-tmux-navigator
"$SCRIPTS"/git-clone.sh https://github.com/jimeh/tmux-themepack "$HOME"/.tmux/plugins/tmux-themepack
"$SCRIPTS"/git-clone.sh https://github.com/thewtex/tmux-mem-cpu-load "$HOME"/.tmux/plugins/tmux-mem-cpu-load

# Build tmux-mem-cpu-load plugin
PLUGIN_DIR="$HOME/.tmux/plugins/tmux-mem-cpu-load"

# Build the plugin
if command -v cmake >/dev/null 2>&1 && command -v make >/dev/null 2>&1; then
    echo "Building tmux-mem-cpu-load..."
    if (
        cd "$PLUGIN_DIR" && \
        cmake . >/dev/null 2>&1 && \
        make >/dev/null 2>&1
    ); then
        echo "Successfully built tmux-mem-cpu-load"
    else
        echo "Warning: Failed to build tmux-mem-cpu-load"
        echo "The plugin will attempt to build automatically on first tmux launch"
    fi
else
    echo "Warning: cmake or make not found. Skipping tmux-mem-cpu-load build"
    echo "The plugin will attempt to build automatically on first tmux launch"
fi

## Auto-install TPM plugins
if command -v tmux >/dev/null 2>&1; then
    echo ""
    echo "Installing tmux plugins via TPM..."

    # ユーザーの既存 tmux サーバー/セッションには一切触れないよう、
    # 一時ディレクトリのソケットで隔離サーバーを立てて TPM 公式の
    # ヘッドレスインストーラー (bin/install_plugins) を同期実行する
    (
        unset TMUX
        TMUX_TMPDIR=$(mktemp -d)
        export TMUX_TMPDIR
        tmux new-session -d -s tpm_install
        "$HOME/.tmux/plugins/tpm/bin/install_plugins" || \
            echo "Warning: TPM plugin installation reported errors"
        tmux kill-server 2>/dev/null || true
        rm -rf "$TMUX_TMPDIR"
    ) || echo "Warning: TPM auto-install could not run (install manually with prefix + I)"

    echo ""
    echo "=========================================="
    echo "  Tmux Setup Complete!"
    echo "=========================================="
    echo ""
    echo "Plugins have been installed automatically."
    echo "Start tmux with: tmux"
    echo ""
    echo "Available features:"
    echo "  • Ctrl+H/J/K/L for pane navigation"
    echo "  • Works seamlessly with vim/nvim!"
    echo "  • Session persistence (resurrect/continuum)"
    echo "  • CPU/Memory monitoring in status bar"
    echo ""
    echo "=========================================="
    echo ""
else
    echo "Warning: tmux not found. Please install tmux first."
fi
