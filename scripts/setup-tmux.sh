#!/bin/bash

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS="$ROOT_DIR/scripts"

# Change to dotfiles-public directory so deps are created there
cd "$ROOT_DIR"

## Install TPM using git-clone.sh
$SCRIPTS/git-clone.sh https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

# Fix TPM circular symlink issue
TPM_DIR="$ROOT_DIR/deps/tpm"
if [ -L "$TPM_DIR/tpm" ]; then
    rm "$TPM_DIR/tpm"
fi
if [ -f "$TPM_DIR/.git/config" ]; then
    (cd "$TPM_DIR" && git restore tpm 2>/dev/null)
fi

## Install tmux plugins
$SCRIPTS/git-clone.sh https://github.com/tmux-plugins/tmux-resurrect $HOME/.tmux/plugins/tmux-resurrect
$SCRIPTS/git-clone.sh https://github.com/tmux-plugins/tmux-continuum $HOME/.tmux/plugins/tmux-continuum
$SCRIPTS/git-clone.sh https://github.com/christoomey/vim-tmux-navigator $HOME/.tmux/plugins/vim-tmux-navigator
$SCRIPTS/git-clone.sh https://github.com/jimeh/tmux-themepack $HOME/.tmux/plugins/tmux-themepack
$SCRIPTS/git-clone.sh https://github.com/thewtex/tmux-mem-cpu-load $HOME/.tmux/plugins/tmux-mem-cpu-load

# Build tmux-mem-cpu-load plugin
PLUGIN_DIR="$HOME/.tmux/plugins/tmux-mem-cpu-load"

# Remove circular symlink if exists
if [ -L "$PLUGIN_DIR/tmux-mem-cpu-load" ]; then
    rm "$PLUGIN_DIR/tmux-mem-cpu-load"
fi

# Build the plugin
if command -v cmake >/dev/null 2>&1 && command -v make >/dev/null 2>&1; then
    echo "Building tmux-mem-cpu-load..."
    (
        cd "$PLUGIN_DIR" && \
        cmake . >/dev/null 2>&1 && \
        make >/dev/null 2>&1
    )

    if [ $? -eq 0 ]; then
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

    # Ensure clean tmux state
    tmux kill-server 2>/dev/null || true
    sleep 1

    # Start tmux server and create session
    tmux new-session -d -s tpm_auto_install 'sleep 10'
    sleep 2

    # Trigger TPM install (Ctrl+Space + I)
    tmux send-keys -t tpm_auto_install C-Space
    sleep 0.5
    tmux send-keys -t tpm_auto_install I

    echo "Waiting for plugin installation to complete..."
    sleep 8

    # Clean up
    tmux kill-server 2>/dev/null || true

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
