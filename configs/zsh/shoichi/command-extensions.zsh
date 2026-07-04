# fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

#fd
## -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

## Use fd (https://github.com/sharkdp/fd) for listing path candidates.
## - The first argument to the function ($1) is the base path to start traversal
## - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

## Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# fzf-git
if [ -f "$HOME/.config/zsh/fzf-git/fzf-git.sh" ]; then
  source "$HOME/.config/zsh/fzf-git/fzf-git.sh"
fi

# ----- Bat (better cat) -----
# テーマ未インストールの環境で bat を実行するたびに
# "[bat warning]: Unknown theme 'tokyonight_night'" が出るのを防ぐため、
# テーマファイルの存在を確認してから設定する
# （テーマのインストールは install-zsh-extensions.sh が行う）
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes/tokyonight_night.tmTheme" ]; then
  export BAT_THEME=tokyonight_night
fi

# eza & bat
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}


# thefuck alias (only execute on macOS)
if [[ "$(uname)" == "Darwin" ]] && command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
  eval "$(thefuck --alias fk)"
fi

# NOTE: zoxide の初期化は zshrc の末尾で行う
# (zoxide init は PATH 変更や alias 定義より後に実行しないと
#  zoxide doctor が警告を出す)

# zsh
# zsh-autosuggestions
if [ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# zsh-syntax-highlighting
if [ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
