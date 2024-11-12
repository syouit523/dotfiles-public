ROOT = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

## ******************** Script Environment ********************
UNAME_S := $(shell uname -s)
SCRIPTS  := $(ROOT)/scripts
MAC = $(ROOT)/mac
XCODE_SELECT_INSTALL    = $(MAC)/scripts/xcode-select-install.sh
MAKE_WORKSPACE   = $(SCRIPTS)/make-workspace.sh
BREW_INSTALL   = $(SCRIPTS)/brew-install.sh
BREW_SETUP   = $(SCRIPTS)/brew-setup.sh
DEPLOY_CONFIGS = $(SCRIPTS)/deploy-configs.sh
SETUP_FISH = $(SCRIPTS)/setup-fish.sh
SETUP_ZSH = $(SCRIPTS)/setup-zsh.sh

default: bootstrap

PHONY: check-sudo
check-sudo:
	@echo "Check sudo"
	@if sudo -n true 2>/dev/null; then \
		echo "Sudo is not required. Skipping."; \
	else \
		echo "Starting sudo loop..."; \
		sudo -v; \
		while true; do sudo -n true; sleep 60; kill -0 $$ || exit; done 2>/dev/null & \
	fi

## ******************** Setup ********************
.PHONY: bootstrap
bootstrap b:
ifeq ($(UNAME_S), Linux)
	make check-sudo
	make brew_install
	make brew_setup
	make font
	make zsh
	make zsh_extensions
	make link
	make reload_zshrc
	make linux_setup
	make ssh-key-gen
else ifeq ($(UNAME_S), Darwin)
#	sh defaults write com.apple.finder AppleShowAllFiles TRUE
#	sh killall Finder
	make check-sudo
	make brew_install
	make brew_setup
	make zsh
	make link
	make zsh_extensions
	make reload_zshrc
	make ssh-key-gen
else ifeq ($(UNAME_S), Windows_NT)
	@echo Windows is not supported
else
	@echo "$(UNAME_S)" is not supported
endif

.PHONY: brew_install
brew_install:
	@echo "Running Homebrew installation script..."
	@INSTALL_SHELL="$(SCRIPTS)/install-brew.sh"; \
	chmod +x "$$INSTALL_SHELL"; \
	"$$INSTALL_SHELL"

.PHONY: brew_setup
brew_setup:
	@echo "Setting up Brewfile packages..."
	@INSTALL_SHELL="$(SCRIPTS)/install-brew-bundle.sh"; \
	chmod +x "$$INSTALL_SHELL"; \
	"$$INSTALL_SHELL"

.PHONY: brew_mac_app
brew_mac_app:
	@echo "Installing Mac apps from AppStore..."
	- brew bundle --file="$(MAC)/mac-app/Brewfile"

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
	sudo $(SETUP_ZSH)

.PHONY: zsh_extensions
zsh_extensions:
	@echo "Install Zsh Extensions\n"
	sudo $(SCRIPTS)/install-zsh-extensitions.sh

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

.PHONY: reload_zshrc
reload_zshrc:
	@if [ -x "$(shell which zsh 2>/dev/null)" ]; then \
		ZSH_SHELL=$(shell which zsh); \
		echo "Reloading .zshrc using $$ZSH_SHELL"; \
		sudo $$ZSH_SHELL -c "source $(HOME)/.zshrc"; \
	else \
		echo "Zsh is not installed. Skipping .zshrc reload."; \
	fi

## ******************** dot files ********************
.PHONY: link l
link l:
	make check-sudo
	@echo "Link dot files\n"
	sudo sh $(DEPLOY_CONFIGS) link $(ROOT)
	sudo sh $(SCRIPTS)/setup-gitconfig.sh

.PHONY: copy
copy:
	make check-sudo
	@echo "Copy dot files\n"
	sudo sh $(DEPLOY_CONFIGS) copy $(ROOT)
	sudo sh $(SCRIPTS)/setup-gitconfig.sh

.PHONY: delete
delete:
	make check-sudo
	@echo "Delete dot files\n"
	sh $(DEPLOY_CONFIGS) delete $(ROOT)

# ******************** clean ********************

.PHONY: clean c
clean c:
	@echo "Clean\n"
	make check-sudo
	make uninstall-brew
	make delete
	make change-default-shell

.PHONY: uninstall-brew
uninstall-brew:
	@echo "Uninstall Homebrew\n"
	sh $(SCRIPTS)/uninstall-brew.sh

.PHONY: change-default-shell
change-default-shell:
	@echo "Change default shell\n"
	sh $(SCRIPTS)/change-default-shell.sh
