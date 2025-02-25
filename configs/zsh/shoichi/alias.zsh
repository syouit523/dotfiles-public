# ---- Eza (better ls) -----
if command -v eza > /dev/null 2>&1; then
    alias ls="eza --color=always --long --git --icons=always --no-user"
    alias l="ls"
    alias lt="ls --tree"
    alias la="ls --all"
    alias lat="ls --all --tree"
else
    echo "eza not found"
    alias l="ls"
    alias lt="tree ."
    alias lat="tree -a ."
fi

# ---- Zoxide (better cd) ----
if command -v z > /dev/null 2>&1; then
    alias cd="z"
else
    echo "z not found"
fi

alias g="git"