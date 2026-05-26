#!/bin/bash

SSH_REMOTE="git@github.com:syouit523/dotfiles-public.git"
HTTPS_REMOTE_PATTERN="https://github.com/"

connection_test_github () {
    echo "DO YOU WANT TO CONNECTION TEST TO GITHUB? (Y/n)"
    read -r flag
    if [ "$flag" = "Y" ] || [ "$flag" = "y" ] || [ -z "$flag" ]; then
        ssh -T git@github.com
    fi
}

# 現在のリポジトリの origin が HTTPS だったら SSH に切り替える
switch_remote_to_ssh () {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    fi
    local current_url
    current_url=$(git remote get-url origin 2>/dev/null || echo "")
    case "$current_url" in
        "$HTTPS_REMOTE_PATTERN"*)
            echo "Switching origin from HTTPS to SSH..."
            git remote set-url origin "$SSH_REMOTE"
            echo "  Before: $current_url"
            echo "  After:  $SSH_REMOTE"
            ;;
    esac
}

# SSHキーが既に存在するか確認
KEY_PATH_ED25519="$HOME/.ssh/id_ed25519"
if [ -f "$KEY_PATH_ED25519" ]; then
    echo "SSHキーは既に存在します。"
    switch_remote_to_ssh
    connection_test_github || exit 0
else
    echo "SSHキーが見つかりません。新しいキーを作成します。"

    # GitHub CLIで認証およびSSHキーの自動作成・追加
    echo "GitHubアカウントにログインし、SSHキーを登録します。"
    gh auth login -p ssh

    # 接続テスト
    connection_test_github

    # リモートURLをSSH接続に変更
    switch_remote_to_ssh
fi
