if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end

#homebrew path
eval (/opt/homebrew/bin/brew shellenv)

# rbenv
set -x PATH $HOME/.rbenv/bin $PATH
status --is-interactive; and source (rbenv init -|psub)

## diff-highlight for Apple silicon Mac
set -x PATH $PATH:/opt/homebrew/share/git-core/contrib/diff-highlight

## diff-highlight for Intel Mac
# set -x PATH $PATH:/usr/local/share/git-core/contrib/diff-highlight