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
SETUP_ZSH = $(SCRIPTS)/setup-zsh.sh

default: bootstrap

## ******************** Setup ********************
.PHONY: bootstrap
bootstrap b:
ifeq ($(UNAME_S), Linux)
#	sh $(MAKE_WORKSPACE)
	make brew_install
	make brew_setup
	make font
	make zsh
	make deploy
	make ssh-key-gen
else ifeq ($(UNAME_S), Darwin)
#	sh defaults write com.apple.finder AppleShowAllFiles TRUE
#	sh killall Finder
#	sh $(MAKE_WORKSPACE)
	make brew_install
	make brew_setup
#	sh $(XCODE_SELECT_INSTALL)
	make zsh
	make deploy
	make ssh-key-gen
else ifeq ($(UNAME_S), Windows_NT)
	@echo Windows is not supported
else
	@echo "$(UNAME_S)" is not supported
endif

.PHONY: brew_install
brew_install:
	sh $(SCRIPTS)/install-brew.sh


.PHONY: brew_setup
brew_setup:
	brew bundle --file="$(SHARED)/Brewfile"
ifeq ($(UNAME_S), Darwin)
	brew bundle --file="$(MAC)/Brewfile"
endif

.PHONY: brew_update_all
brew_update_all:
	brew update
ifeq ($(UNAME_S), Linux)
	brew upgrade
else ifeq ($(UNAME_S), Darwin)
	brew upgrade --cask --greedy
endif
	brew bundle

.PHONY: font f
font f:
	git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git
	cd nerd-fonts
# install all fonts
	./install.sh
	echo "Set the installed fonts!!"

.PHONY: fish
fish:
	sh $(SETUP_FISH)

.PHONY: zsh
zsh:
	sh $(SETUP_ZSH)

.PHONY: ssh-key-gen
ssh-key-gen:
	sh $(SCRIPTS)/ssh-key-gen.sh


## ******************** Deploy dot files ********************
.PHONY: deploy d
deploy d:
	sh $(DEPLOY_CONFIGS) $(ROOT)

.PHONY: clean c
clean c:
	echo "clean"