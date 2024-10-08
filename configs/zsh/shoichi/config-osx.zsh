# homebrew
architecture=$(uname -m)
if [ "$architecture" = "arm64" ]; then
    # Homebrew path for Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # diff-highlight for Apple Silicon Mac
    export PATH="$PATH:/opt/homebrew/share/git-core/contrib/diff-highlight"
elif [ "$architecture" = "x86_64" ]; then
    # diff-highlight for Intel Mac
    export PATH="$PATH:/usr/local/share/git-core/contrib/diff-highlight"
fi
