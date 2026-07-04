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

# NOTE: cd の置き換えは zshrc 末尾の `zoxide init zsh --cmd cd` で行う
# (alias cd="z" よりも公式推奨の方法で、補完も正しく効く)

alias g="git"
