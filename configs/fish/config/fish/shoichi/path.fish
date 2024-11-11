set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# Go
set -g GOPATH $HOME/go
set -gx PATH $GOPATH/bin $PATH

# For fzf
fzf --fish | source
set -U FZF_LEGACY_KEYBINDINGS 0

# Set FZF default command using fd
set -x FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -x FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($argv[1]) is the base path to start traversal

function _fzf_compgen_path
  fd --hidden --exclude .git . $argv[1]
end

# Use fd to generate the list for directory completion
function _fzf_compgen_dir
  fd --type=d --hidden --exclude .git . $argv[1]
end
