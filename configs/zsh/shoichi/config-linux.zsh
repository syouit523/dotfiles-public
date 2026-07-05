# Homebrew on Linux
# 非ログイン対話シェル(GUIターミナルのデフォルト等)では ~/.zprofile が
# 読まれず brew が PATH に入らないため、ここで確立する
# (macOS 側の config-osx.zsh と対称)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && ! command -v brew >/dev/null 2>&1; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

 #enable japanese
export LANG=en_US.UTF-8
export LC_CTYPE=ja_JP.UTF-8
