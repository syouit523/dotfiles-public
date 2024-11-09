#!/bin/bash

connection_test_github () {
    echo "DO YOU WANT TO CONNECTION TEST TO GITHUB? (Y/n)"
    read flag
    if [ "$flag" = "Y" ]; then
        ssh -T git@github.com
    fi
}

# SSHキーが既に存在するか確認
KEY_PATH_ED25519="$HOME/.ssh/id_ed25519"
if [ -f "$KEY_PATH_ED25519" ]; then
    echo "SSHキーは既に存在します。"
    connection_test_github || exit 0
else
    echo "SSHキーが見つかりません。新しいキーを作成します。"
    
    # GitHub CLIで認証およびSSHキーの自動作成・追加
    echo "GitHubアカウントにログインし、SSHキーを登録します。"
    gh auth login -p ssh

    # 接続テスト
    connection_test_github
    
    # リモートURLをSSH接続に変更
    git remote set-url origin git@github.com:syouit523/dotfiles-public.git || exit 0
fi

