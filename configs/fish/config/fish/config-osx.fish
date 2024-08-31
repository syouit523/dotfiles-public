if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end

# rbenv
set -x PATH $HOME/.rbenv/bin $PATH
status --is-interactive; and source (rbenv init -|psub)

set -l architecture (uname -m)
if test "$architecture" = arm64
    #homebrew path
    eval (/opt/homebrew/bin/brew shellenv)
    ## diff-highlight for Apple silicon Mac
    set -x PATH $PATH:/opt/homebrew/share/git-core/contrib/diff-highlight
else if test "$architecture" = x86_64
    ## diff-highlight for Intel Mac
    set -x PATH $PATH:/usr/local/share/git-core/contrib/diff-highlight
end