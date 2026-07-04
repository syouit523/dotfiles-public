set CURRENT_PATH (dirname (status --current-filename))
set SHOICHI_PATH $CURRENT_PATH/shoichi

set fish_greeting ""

# NOTE: TERM はターミナルエミュレータが設定するものなので上書きしない
# (tmux の tmux-256color や Ghostty の xterm-ghostty を壊し、
#  undercurl など terminfo 由来の機能が失われる)

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

set -gx EDITOR nvim

# NVM
# function __check_rvm --on-variable PWD --description 'Do nvm stuff'
#   status --is-command-substitution; and return

#   if test -f .nvmrc; and test -r .nvmrc;
#     nvm use
#   else
#   end
# end


source $SHOICHI_PATH/alias.fish
source $SHOICHI_PATH/path.fish

switch (uname)
  case Darwin
    source $SHOICHI_PATH/config-osx.fish
  case Linux
    source $SHOICHI_PATH/config-linux.fish
  case '*'
    source $SHOICHI_PATH/config-windows.fish
end

set LOCAL_CONFIG $CURRENT_PATH/config-local.fish
if test -f $LOCAL_CONFIG
  source $LOCAL_CONFIG
end