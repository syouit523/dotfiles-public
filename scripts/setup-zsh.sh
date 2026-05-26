#!/bin/bash

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS="$ROOT_DIR/scripts"

# Prefer Homebrew's zsh over the system /bin/zsh.
# When invoked via sudo, PATH may be sanitized — check brew prefixes directly.
find_zsh() {
    for candidate in /opt/homebrew/bin/zsh /usr/local/bin/zsh /home/linuxbrew/.linuxbrew/bin/zsh; do
        if [ -x "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done
    command -v zsh 2>/dev/null
}

ZSH_PATH=$(find_zsh)

if [ -n "$ZSH_PATH" ] && [ -x "$ZSH_PATH" ]; then
    echo "Using zsh at: $ZSH_PATH"
    # set to the default shell to zsh
    # sudo -n sed -i.bak '/\/bin\/zsh/d' /etc/shells # remove existing zsh path for mac
    if ! grep -q "^$ZSH_PATH$" /etc/shells; then
        if [ "$(uname)" == 'Darwin' ]; then
            if [ "$(uname -m)" == x86_64 ]; then
                sh -c "echo \"$ZSH_PATH\" >> /etc/shells" # add zsh path of homebrew
            elif [ "$(uname -m)" == arm64 ]; then
                sh -c "echo \"$ZSH_PATH\" >> /etc/shells" # add zsh path of homebrew
            fi
        elif [ "$(uname)" == 'Linux' ]; then
            if [ -f /etc/shells ]; then
                sh -c "echo \"$ZSH_PATH\" >> /etc/shells" # add zsh path of apt
            fi
        fi
    fi
    # chsh は change-default-shell.sh に委譲（sudo -n chsh を使う）
    # ここで chsh を実行するとパスワード入力を要求するため削除した

    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh is already installed."
    else
        echo "Oh My Zsh is not installed. Installing now..."

        # Install oh-my-zsh without changing the shell immediately
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        echo "Oh My Zsh installation completed."
    fi

    if [ -n "$ZSH_VERSION" ]; then
        # shellcheck disable=SC1090
        source ~/.zshrc
    fi
    # theme
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        "$SCRIPTS"/git-clone.sh https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
    fi

    # theme
    ## zsh-autosuggestions
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        "$SCRIPTS"/git-clone.sh https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    fi
    ## zsh-syntax-highlighting
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        "$SCRIPTS"/git-clone.sh https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
    fi

else
    echo "zsh is not installed."
    exit
fi
