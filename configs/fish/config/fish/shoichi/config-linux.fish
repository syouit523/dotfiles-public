if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end

# enable japanese
set -x LANG ja_JP.UTF-8
set -x LC_ALL ja_JP.UTF-8