#!/bin/bash
# shellcheck disable=SC1071

set -eo pipefail

architecture=$(uname -m)

if command -v brew >/dev/null 2>&1; then
    echo "brew is already installed."
    echo "skip installing brew"
else
    # sudoを使用せずに通常のユーザー権限で実行
    # (インストーラ内部で必要な箇所だけ sudo を使う。NONINTERACTIVE=1 は
    #  Makefile から export され、インストーラのプロンプトを抑止する)
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ---- プロファイル整備 (brew が既にインストール済みの場合も毎回行う) ----
# brew 既存時にスキップすると、手動導入済み (.bashrc にのみ shellenv 等) の
# 環境で chsh 後のログインシェルが brew PATH なしで起動してしまうため、
# shellenv の追記はインストールの有無に関わらず冪等に実行する。
if [ "$(uname)" = 'Darwin' ]; then
    if [ "$architecture" = "arm64" ]; then
        BREW_PATH=/opt/homebrew/bin/brew  # Apple Silicon
    else
        BREW_PATH=/usr/local/bin/brew  # Intel Mac
    fi
    PROFILES=("$HOME/.zprofile")
else
    # Homebrew on Linux (公式推奨プレフィックス)
    BREW_PATH=/home/linuxbrew/.linuxbrew/bin/brew
    # ログインシェルが bash でも zsh でも効くよう両方に追記する
    PROFILES=("$HOME/.profile" "$HOME/.zprofile")
    # bash は ~/.bash_profile が存在すると ~/.profile を読まないため、
    # 既にある場合はそちらにも追記する
    if [ -f "$HOME/.bash_profile" ]; then
        PROFILES+=("$HOME/.bash_profile")
    fi
fi

# 標準プレフィックスに無い場合 (手動で別の場所に導入済み等) は
# PATH 上の brew にフォールバックする
if [ ! -x "$BREW_PATH" ] && command -v brew >/dev/null 2>&1; then
    BREW_PATH=$(command -v brew)
fi
if [ ! -x "$BREW_PATH" ]; then
    echo "Error: brew not found at $BREW_PATH after installation." >&2
    exit 1
fi

# プロファイルへの追記は冪等にする（再実行のたびに重複しない）
for profile in "${PROFILES[@]}"; do
    if ! grep -q 'brew shellenv' "$profile" 2>/dev/null; then
        echo >> "$profile"
        echo "eval \"\$(${BREW_PATH} shellenv)\"" >> "$profile"
    fi
done
eval "$("$BREW_PATH" shellenv)"
