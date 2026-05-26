# homebrew
architecture=$(uname -m)
if [ "$architecture" = "arm64" ]; then
    # Homebrew path for Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # diff-highlight for Apple Silicon Mac
    export PATH="$PATH:/opt/homebrew/share/git-core/contrib/diff-highlight"
    # for cp command from GNU (brew install coreutils)
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
elif [ "$architecture" = "x86_64" ]; then
    # diff-highlight for Intel Mac
    export PATH="$PATH:/usr/local/share/git-core/contrib/diff-highlight"
fi

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

#sbin
export PATH="/usr/local/sbin:$PATH"

#pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

