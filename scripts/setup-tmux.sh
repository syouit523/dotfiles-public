#!/bin/bash

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS="$ROOT_DIR/scripts"
## Install TPM using git-clone.sh
$SCRIPTS/git-clone.sh https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
