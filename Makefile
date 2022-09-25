ROOT = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

## ******************** Script Environment ********************

SCRIPTS  = $(ROOT)/scripts
BREWFILE = $(ROOT)/Brewfile
XCODE_SELECT_INSTALL    = $(SCRIPTS)/xcode-select-install.sh
MAKE_WORKSPACE   = $(SCRIPTS)/make-workspace.sh
BREW_INSTALL   = $(SCRIPTS)/brew-install.sh
BREW_SETUP   = $(SCRIPTS)/brew-setup.sh
DEPLOY_CONFIGS = $(SCRIPTS)/deploy-configs.sh
SETUP_FISH = $(SCRIPTS)/setup-fish.sh

default: bootstrap

## ******************** Setup ********************
.PHONY: bootstrap b
bootstrap b:
	sh defaults write com.apple.finder AppleShowAllFiles TRUE
	sh killall Finder
	sh $(XCODE_SELECT_INSTALL)
	sh $(MAKE_WORKSPACE)
	sh $(BREW_INSTALL)
	sh $(BREW_SETUP) $(BREWFILE)
	make deploy
	make font

.PHONY: font f
font f:
	git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
	cd nerd-fonts
	git sparse-checkout add patched-fonts/JetBrainsMono
	./install.sh
	echo "Change iTerm2 font for `JetBrainsMono Nerd Font`!!"

.PHONY: fish
fish:
	sh $(SETUP_FISH)

## ******************** Deploy dot files ********************
.PHONY: deploy d
deploy d:
	sh $(DEPLOY_CONFIGS) $(ROOT)

.PHONY: clean c
clean c:
	echo "clean"