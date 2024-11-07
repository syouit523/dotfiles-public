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
	make zsh_extensions
	make linux_setup
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
	make zsh_extensions
	make ssh-key-gen
else ifeq ($(UNAME_S), Windows_NT)
	@echo Windows is not supported
else
	@echo "$(UNAME_S)" is not supported
endif

.PHONY: brew_install
brew_install:
	@echo "Install Homebrew\n"
	$(SCRIPTS)/./install-brew.sh

.PHONY: brew_setup
brew_setup:
	@echo "Install Brewfile\n"
	brew bundle --file="$(SHARED)/Brewfile"
ifeq ($(UNAME_S), Darwin)
	brew bundle --file="$(MAC)/Brewfile"
endif

.PHONY: brew_update_all
brew_update_all:
	@echo "Update Homebrew\n"
	brew update
ifeq ($(UNAME_S), Linux)
	brew upgrade
else ifeq ($(UNAME_S), Darwin)
	brew upgrade --cask --greedy
endif
	brew bundle

.PHONY: font f
font f:
	sh $(SCRIPTS)/install-fonts.sh

.PHONY: fish
fish:
	@echo "Setup Fish\n"
	sh $(SETUP_FISH)

.PHONY: zsh
zsh:
	@echo "Setup Zsh\n"
	sh $(SETUP_ZSH)

.PHONY: zsh_extensions
zsh_extensions:
	@echo "Install Zsh Extensions\n"
	sh $(SCRIPTS)/install-zsh-extensitions.sh

.PHONY: linux_setup
linux_setup:
# for GUI Linux
	@echo "Install Flatpak\n"
	sh $(SCRIPTS)/linux/install-flatpak.sh
	@echo "Install Apps\n"
	sh $(SCRIPTS)/linux/install-apps.sh

.PHONY: ssh-key-gen
ssh-key-gen:
	@echo "Generate SSH Key\n"
	sh $(SCRIPTS)/ssh-key-gen.sh


## ******************** Deploy dot files ********************
.PHONY: deploy d
deploy d:
	@echo "Deploy dot files\n"
	sh $(DEPLOY_CONFIGS) $(ROOT)

.PHONY: clean c
clean c:
	@echo "Clean\n"
	echo "clean"
