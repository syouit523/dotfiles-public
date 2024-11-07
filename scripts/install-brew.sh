

architecture=$(uname -m)

if command -v brew >/dev/null 2>&1; then
    echo "brew is already installed."
    echo "skip installing brew"
else
    sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
    if [ "$(uname)" == 'Darwin' ]; then
	    echo >> $HOME/.zprofile
        if [ "$architecture" = "arm64" ]; then
        # for Apple silicon
	    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
     	    eval "$(/opt/homebrew/bin/brew shellenv)"
	    #(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
	    #eval "$(/opt/homebrew/bin/brew shellenv)"
     	    #source $HOME/.zprofile
        fi
    fi
fi
