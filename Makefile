ROOT = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
export ROOT

## ******************** Global Variables ********************
# Installation mode: minimum or extra (default: minimum)
MODE ?= minimum
export MODE
export SCRIPTS := $(ROOT)/scripts
export MAC := $(ROOT)/mac

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
BREWFILES = $(ROOT)/brewfiles

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

## ******************** Common Targets ********************
.PHONY: bootstrap
bootstrap b: check-sudo
	@echo "Starting bootstrap for $(UNAME_S)"
	@echo "\nSelect installation mode:"
	@echo "1) minimum (essential packages only)"
	@echo "2) extra (all packages)"
	@read -p "Enter choice [1-2] (default: 1): " choice; \
	case "$$choice" in \
		1) mode="minimum";; \
		2|"") mode="extra";; \
		*) echo "Invalid choice, using extra mode"; mode="extra";; \
	esac; \
	echo "Selected mode: $$mode"; \
	MODE=$$mode
	@make $(UNAME_S)_setup

## ******************** Linux Setup ********************
.PHONY: linux_setup
linux_setup:
	@echo "\n=== Linux Setup ==="
	sudo -n apt update && sudo -n apt upgrade -y
	make install_apt_packages_from_brew
	make font
	make zsh
	make zsh_extensions
	make link
	make reload_zshrc
	make tmux
	make linux_gui_setup
	make ssh-key-gen

.PHONY: linux_gui_setup
linux_gui_setup:
	@echo "\n=== Linux GUI Setup ==="
	sh $(SCRIPTS)/linux/install-flatpak.sh
	sh $(SCRIPTS)/linux/install-apps.sh

## ******************** macOS Setup ********************
.PHONY: darwin_setup
Darwin_setup:
	@echo "\n=== macOS Setup ==="
	make brew_install
	make brew_setup
	make zsh
	make link
	make zsh_extensions
	make tmux
	make reload_zshrc
	make ssh-key-gen

## ******************** Windows Setup ********************
.PHONY: Windows_NT_setup
Windows_NT_setup:
	@echo "Windows is not supported"

## ******************** Other OS ********************
.PHONY: %_setup
%_setup:
	@echo "$* is not supported"

# ******************** brew ********************
.PHONY: brew_install
brew_install:
	@echo "Running Homebrew installation script..."
	@INSTALL_SHELL="$(SCRIPTS)/install-brew.sh"; \
	chmod +x "$$INSTALL_SHELL"; \
	"$$INSTALL_SHELL"

.PHONY: brew_setup
brew_setup:
	@echo "Setting up Brewfile packages..."
	@echo "Installation mode: $(MODE)"
	@INSTALL_SHELL="$(SCRIPTS)/install-brew-bundle.sh"; \
	chmod +x "$$INSTALL_SHELL"; \
	"$$INSTALL_SHELL" $(MODE)

.PHONY: brew_mac_app
brew_mac_app:
	@echo "Installing Mac apps from AppStore..."
	- brew bundle --file="$(BREWFILES)/mac-apps/Brewfile"

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

# ******************** font ********************
.PHONY: font f
font f:
	sh $(SCRIPTS)/install-fonts.sh

# ******************** fish ********************
.PHONY: fish
fish:
	@echo "Setup Fish\n"
	sh $(SETUP_FISH)

# ******************** zsh ********************
.PHONY: zsh
zsh:
	@echo "Setup Zsh\n"
	make check-sudo
	sudo -n sh $(SETUP_ZSH)

.PHONY: zsh_extensions
zsh_extensions:
	@echo "Install Zsh Extensions\n"
	sudo -n sh $(SCRIPTS)/install-zsh-extensitions.sh

# ******************** linux ********************
.PHONY: install_apt_packages_from_brew
install_apt_packages_from_brew:
	sh $(SCRIPTS)/linux/install-apt-packages-from-brew.sh

.PHONY: linux_setup
linux_setup:
# for GUI Linux
	@echo "Install Flatpak\n"
	sh $(SCRIPTS)/linux/install-flatpak.sh
	@echo "Install Apps\n"
	sh $(SCRIPTS)/linux/install-apps.sh

# ******************** ssh ********************
.PHONY: ssh-key-gen
ssh-key-gen:
	@echo "Generate SSH Key\n"
	sh $(SCRIPTS)/ssh-key-gen.sh

.PHONY: reload_zshrc
reload_zshrc:
	@if [ -x "$(shell which zsh 2>/dev/null)" ]; then \
		ZSH_SHELL=$(shell which zsh); \
		echo "Reloading .zshrc using $$ZSH_SHELL"; \
		$$ZSH_SHELL -c "source $(HOME)/.zshrc"; \
	else \
		echo "Zsh is not installed. Skipping .zshrc reload."; \
	fi

# ******************** tmux ********************
.PHONY: tmux
tmux:
	@echo "Setup Tmux\n"
	sh $(SCRIPTS)/setup-tmux.sh

# ******************** dot files ********************
.PHONY: link l
link l:
#make check-sudo
	@echo "Link dot files\n"
	sh $(DEPLOY_CONFIGS) link $(ROOT)
	sh $(SCRIPTS)/setup-gitconfig.sh

.PHONY: copy
copy:
	make check-sudo
	@echo "Copy dot files\n"
	sudo -n sh $(DEPLOY_CONFIGS) copy $(ROOT)
	sudo -n sh $(SCRIPTS)/setup-gitconfig.sh

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
	make clean-deps
	make uninstall-brew
	make delete
	make change-default-shell

.PHONY: clean-deps
clean-deps:
	@echo "Clean dependencies\n"
	rm -rf deps

.PHONY: uninstall-brew
uninstall-brew:
	@echo "Uninstall Homebrew\n"
	sh $(SCRIPTS)/uninstall-brew.sh

.PHONY: change-default-shell
change-default-shell:
	@echo "Change default shell\n"
	sh $(SCRIPTS)/change-default-shell.sh
