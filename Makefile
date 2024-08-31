ROOT = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

## ******************** Script Environment ********************


UNAME_S := $(shell uname -s)
SCRIPTS  = $(ROOT)/scripts
SHARED = $(ROOT)/shared
MAC = $(ROOT)/mac
LINUX = $(ROOT)/linux
# BREWFILE = $(ROOT)/Brewfile
XCODE_SELECT_INSTALL    = $(MAC)/scripts/xcode-select-install.sh
MAKE_WORKSPACE   = $(SCRIPTS)/make-workspace.sh
BREW_INSTALL   = $(SCRIPTS)/brew-install.sh
BREW_SETUP   = $(SCRIPTS)/brew-setup.sh
DEPLOY_CONFIGS = $(SCRIPTS)/deploy-configs.sh
SETUP_FISH = $(SCRIPTS)/setup-fish.sh

default: bootstrap

## ******************** Setup ********************
.PHONY: bootstrap
bootstrap b:
ifeq ($(UNAME_S), Linux)
	sh $(MAKE_WORKSPACE)
	make brew_install
	make brew_setup
else ifeq ($(UNAME_S), Darwin)
#	sh defaults write com.apple.finder AppleShowAllFiles TRUE
#	sh killall Finder
	sh $(MAKE_WORKSPACE)
	make brew_install
	make brew_setup
	sh $(XCODE_SELECT_INSTALL)
	make deploy
	make font
else ifeq ($(UNAME_S), Windows_NT)
	@echo Windows is not supported
else
	@echo "$(UNAME_S)" is not supported
endif

.PHONY: brew_install
brew_install:
	sh /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


.PHONY: brew_setup
brew_setup:
	brew bundle --file="$(SHARED)/Brewfile"
ifeq ($(UNAME_S), Darwin)
	brew bundle --file="$(MAC)/Brewfile"
endif

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