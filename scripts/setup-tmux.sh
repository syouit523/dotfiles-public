#!/bin/bash

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS="$ROOT_DIR/scripts"

# Change to dotfiles-public directory so deps are created there
cd "$ROOT_DIR"

## Install TPM using git-clone.sh
$SCRIPTS/git-clone.sh https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

## Install tmux plugins
$SCRIPTS/git-clone.sh https://github.com/tmux-plugins/tmux-resurrect $HOME/.tmux/plugins/tmux-resurrect
$SCRIPTS/git-clone.sh https://github.com/tmux-plugins/tmux-continuum $HOME/.tmux/plugins/tmux-continuum
$SCRIPTS/git-clone.sh https://github.com/christoomey/vim-tmux-navigator $HOME/.tmux/plugins/vim-tmux-navigator
$SCRIPTS/git-clone.sh https://github.com/jimeh/tmux-themepack $HOME/.tmux/plugins/tmux-themepack
$SCRIPTS/git-clone.sh https://github.com/thewtex/tmux-mem-cpu-load $HOME/.tmux/plugins/tmux-mem-cpu-load
