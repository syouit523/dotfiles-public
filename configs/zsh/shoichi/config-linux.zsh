#linuxbrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

#diff-highlight
export PATH=" PATH=$PATH:$(brew --prefix git)/share/git-core/contrib/diff-highlight:$PATH"
 
 #enable japanese
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
