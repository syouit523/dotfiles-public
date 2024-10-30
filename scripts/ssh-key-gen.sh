#!/bin/bash

connection_test_github () {
    echo "DO YOU WANT TO CONNECTION TEST TO GITHUB?: y/n"
    read flag
    if [ $flag = "y" ]; then
        ssh -T git@github.com
    fi
}


# SSHキーが既に存在するか確認
KEY_PATH_ED25519="$HOME/.ssh/id_ed25519"
if [ -f "$KEY_PATH_ED25519" ]; then
    echo "SSHキーは既に存在します。"
    connection_test_github
else
    echo "SSHキーが見つかりません。新しいキーを作成します。"
    ## SET E-MAIL
    echo "INPUT YOUR e-mail ADDRESS:"
    read mail
    ssh-keygen -t ed25519 -C ${mail}
    eval "${ssh-agant -s}"
    ssh-add $HOME/.ssh/id_ed25519
    echo "新しいSSHキーが作成されました: $KEY_PATH"
    ## PRINT THE KEY
    echo "Please add the pub-key on Github!"
    cat $HOME/.ssh/id_ed25519.pub
    connection_test_github
    ## change to ssh connection on this repository
    git remote set-url origin git@github.com:syouit523/dotfiles-public.git
fi

