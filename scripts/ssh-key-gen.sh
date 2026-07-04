#!/bin/bash

connection_test_github () {
    if [ "$NONINTERACTIVE" = "1" ]; then
        echo "NONINTERACTIVE: skipping GitHub connection test."
        return 0
    fi
    echo "DO YOU WANT TO CONNECTION TEST TO GITHUB? (Y/n)"
    read -r flag
    if [ "$flag" = "Y" ] || [ "$flag" = "y" ] || [ -z "$flag" ]; then
        ssh -T git@github.com
    fi
}

# 現在のリポジトリの origin が HTTPS だったら SSH に切り替える。
# 安全のため:
#   1. 必ず git リポジトリの中で実行されていること
#   2. origin の HTTPS URL から host/owner/repo を抽出して
#      動的に SSH URL を組み立てる（ハードコードしない）
#   3. github.com 以外のホストでもそのまま動く
switch_remote_to_ssh () {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    fi

    local current_url
    current_url=$(git remote get-url origin 2>/dev/null || echo "")
    case "$current_url" in
        https://*)
            # https://HOST/OWNER/REPO(.git) -> git@HOST:OWNER/REPO.git
            local stripped="${current_url#https://}"
            local host="${stripped%%/*}"
            local path="${stripped#*/}"
            # .git を付与（既にあれば重複防止）
            case "$path" in
                *.git) ;;
                *) path="${path}.git" ;;
            esac
            local ssh_url="git@${host}:${path}"

            echo "Switching origin from HTTPS to SSH..."
            git remote set-url origin "$ssh_url"
            echo "  Before: $current_url"
            echo "  After:  $ssh_url"
            ;;
        *)
            # 既に SSH または別 remote。何もしない。
            ;;
    esac
}

# SSHキーが既に存在するか確認
# id_ed25519 固定だと RSA キーや別名キーのユーザーが毎回
# 「キーがない」扱いになるため、~/.ssh/id_* の秘密鍵をすべて対象にする
EXISTING_KEY=$(find "$HOME/.ssh" -maxdepth 1 -type f -name 'id_*' ! -name '*.pub' 2>/dev/null | head -n 1)
if [ -n "$EXISTING_KEY" ]; then
    echo "SSHキーは既に存在します。($EXISTING_KEY)"
    switch_remote_to_ssh
    connection_test_github || exit 0
else
    echo "SSHキーが見つかりません。新しいキーを作成します。"

    if [ "$NONINTERACTIVE" = "1" ]; then
        echo "NONINTERACTIVE: skipping interactive SSH key generation."
        echo "Run 'make ssh-key-gen' manually after bootstrap."
        exit 0
    fi

    # GitHub CLIで認証およびSSHキーの自動作成・追加
    if ! command -v gh >/dev/null 2>&1; then
        echo "gh (GitHub CLI) が見つかりません。先に 'make brew_setup' を実行してください。"
        exit 1
    fi

    echo "GitHubアカウントにログインし、SSHキーを登録します。"
    gh auth login -p ssh

    # 接続テスト
    connection_test_github

    # リモートURLをSSH接続に変更
    switch_remote_to_ssh
fi
