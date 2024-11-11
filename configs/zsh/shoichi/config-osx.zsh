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
eval "$(rbenv init -)"

#sbin
export PATH="/usr/local/sbin:$PATH"
