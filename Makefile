ROOT = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
export ROOT

## ******************** Global Variables ********************
# Installation mode: minimum or extra
# - For interactive use: MODE defaults to minimum
# - For non-interactive use: pass DOTFILES_BOOTSTRAP_MODE=extra (etc.)
MODE ?= $(if $(DOTFILES_BOOTSTRAP_MODE),$(DOTFILES_BOOTSTRAP_MODE),minimum)
export MODE
export NONINTERACTIVE
export DOTFILES_BOOTSTRAP_MODE
export DOTFILES_GIT_USER_NAME
export DOTFILES_GIT_USER_EMAIL
export DOTFILES_DEFAULT_SHELL
export SCRIPTS := $(ROOT)/scripts
export MAC := $(ROOT)/mac

# PID ファイルは UID 込みにして複数ユーザーでの衝突を防ぐ
SUDO_KEEPALIVE_PID := /tmp/dotfiles-sudo-keepalive-$(shell id -u).pid

## ******************** Script Environment ********************
UNAME_S := $(shell uname -s)
XCODE_SELECT_INSTALL    = $(MAC)/scripts/xcode-select-install.sh
DEPLOY_CONFIGS = $(SCRIPTS)/deploy-configs.sh
SETUP_FISH = $(SCRIPTS)/setup-fish.sh
SETUP_ZSH = $(SCRIPTS)/setup-zsh.sh
BREWFILES = $(ROOT)/Brewfiles

default: help

.PHONY: help
help:
	@echo "Available targets:"
	@echo ""
	@echo "  Bootstrap:"
	@echo "    bootstrap (b)        Run OS-appropriate setup (sudo + interactive)"
	@echo "                         Pass NONINTERACTIVE=1 + DOTFILES_* envs for one-shot install"
	@echo ""
	@echo "  Homebrew:"
	@echo "    brew_install         Install Homebrew"
	@echo "    brew_setup           Install packages from Brewfile (MODE=minimum|extra)"
	@echo "    brew_mac_app         Install Mac App Store apps (extra mode only)"
	@echo "    brew_update_all      Update Homebrew and all packages"
	@echo ""
	@echo "  Shell:"
	@echo "    zsh                  Install zsh + oh-my-zsh"
	@echo "    zsh_extensions       Install zsh extensions"
	@echo "    fish                 Install fish + fisher"
	@echo "    change-default-shell Change login shell (DOTFILES_DEFAULT_SHELL=zsh|fish)"
	@echo "    reload_zshrc         Reload ~/.zshrc"
	@echo ""
	@echo "  Dotfiles:"
	@echo "    link (l)             Symlink dotfiles"
	@echo "    copy                 Copy dotfiles"
	@echo "    delete               Remove dotfiles (restores .backup if present)"
	@echo ""
	@echo "  Tmux/Font/SSH:"
	@echo "    tmux                 Install tmux + TPM"
	@echo "    font (f)             Install nerd fonts"
	@echo "    ssh-key-gen          Generate SSH key + gh auth (interactive)"
	@echo ""
	@echo "  Linux:"
	@echo "    linux_gui_setup      Install GUI apps via Flatpak"
	@echo "    linux_support_japanese"
	@echo "                         Configure Japanese input on Linux"
	@echo ""
	@echo "  Test/Clean:"
	@echo "    test (t)             Run BATS test suite"
	@echo "    clean (c)            Uninstall everything (interactive confirm)"
	@echo ""
	@echo "Run 'make bootstrap' to start. See README.md for the one-line install."

.PHONY: check-sudo
check-sudo:
	@echo "Check sudo"
	@# sudo cache が生きているかを実コマンドで確認 (kill -0 だけでは不十分)
	@if sudo -n true 2>/dev/null; then \
		echo "Sudo cache is valid."; \
		if [ ! -f $(SUDO_KEEPALIVE_PID) ] || ! kill -0 $$(cat $(SUDO_KEEPALIVE_PID) 2>/dev/null) 2>/dev/null; then \
			( while true; do sudo -n true; sleep 50; done ) >/dev/null 2>&1 & \
			echo $$! > $(SUDO_KEEPALIVE_PID); \
		fi; \
	elif [ ! -t 0 ]; then \
		echo "Error: sudo password required but stdin is not a TTY."; \
		echo "Run 'sudo -v' manually before invoking this target,"; \
		echo "or use NOPASSWD sudoers entry for this user."; \
		exit 1; \
	else \
		echo "Requesting sudo password..."; \
		sudo -v; \
		if [ -f $(SUDO_KEEPALIVE_PID) ] && kill -0 $$(cat $(SUDO_KEEPALIVE_PID) 2>/dev/null) 2>/dev/null; then \
			kill $$(cat $(SUDO_KEEPALIVE_PID)) 2>/dev/null; \
		fi; \
		( while true; do sudo -n true; sleep 50; done ) >/dev/null 2>&1 & \
		echo $$! > $(SUDO_KEEPALIVE_PID); \
	fi

.PHONY: cleanup-sudo
cleanup-sudo:
	@if [ -f $(SUDO_KEEPALIVE_PID) ]; then \
		PID=$$(cat $(SUDO_KEEPALIVE_PID)); \
		kill $$PID 2>/dev/null && echo "Stopped sudo keep-alive (PID $$PID)"; \
		rm -f $(SUDO_KEEPALIVE_PID); \
	fi

## ******************** Common Targets ********************
.PHONY: bootstrap
bootstrap b: check-sudo
	@echo "Starting bootstrap for $(UNAME_S)"
	@if [ "$(NONINTERACTIVE)" != "1" ] && [ -z "$(DOTFILES_BOOTSTRAP_MODE)" ]; then \
		echo ""; \
		echo "Select installation mode:"; \
		echo "1) minimum (essential packages only)"; \
		echo "2) extra (all packages)"; \
		read -p "Enter choice [1-2] (default: 1): " choice; \
		case "$$choice" in \
			2) mode="extra";; \
			*) mode="minimum";; \
		esac; \
		echo "Selected mode: $$mode"; \
		$(MAKE) $(UNAME_S)_setup MODE=$$mode; \
	else \
		echo "Installation mode: $(MODE)"; \
		$(MAKE) $(UNAME_S)_setup; \
	fi
	@$(MAKE) cleanup-sudo

## ******************** Linux Setup ********************
.PHONY: Linux_setup
Linux_setup: check-sudo
	@echo "" && echo "=== Linux Setup ==="
	sudo -n apt-get update && sudo -n apt-get upgrade -y
	# Homebrew on Linux の前提パッケージ (https://docs.brew.sh/Homebrew-on-Linux)
	sudo -n apt-get install -y build-essential procps curl file git
	$(MAKE) linux_support_japanese
	$(MAKE) brew_install
	$(MAKE) brew_setup
	$(MAKE) font
	$(MAKE) link
	$(MAKE) zsh
	$(MAKE) zsh_extensions
	$(MAKE) tmux
	$(MAKE) change-default-shell
	$(MAKE) reload_zshrc
	@echo ""
	@echo "===================================================="
	@echo "Bootstrap finished. To set up SSH key + GitHub auth,"
	@echo "run manually:  make ssh-key-gen"
	@echo "===================================================="

.PHONY: linux_gui_setup
linux_gui_setup:
	@echo "" && echo "=== Linux GUI Setup ==="
	bash $(SCRIPTS)/linux/install-flatpak.sh
	bash $(SCRIPTS)/linux/install-apps.sh

## ******************** macOS Setup ********************
.PHONY: Darwin_setup
Darwin_setup: check-sudo
	@echo "" && echo "=== macOS Setup ==="
	bash $(XCODE_SELECT_INSTALL)
	$(MAKE) brew_install
	$(MAKE) brew_setup
	$(MAKE) link
	$(MAKE) zsh
	$(MAKE) zsh_extensions
	$(MAKE) tmux
	$(MAKE) change-default-shell
	$(MAKE) reload_zshrc
	@echo ""
	@echo "===================================================="
	@echo "Bootstrap finished. To set up SSH key + GitHub auth,"
	@echo "run manually:  make ssh-key-gen"
	@echo "===================================================="

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
	@if [ "$(MODE)" = "extra" ]; then \
		echo "Running in extra mode, installing Mac apps..."; \
		brew bundle --file="$(BREWFILES)/macApps-Brewfile"; \
	else \
		echo "Skipping Mac apps installation (not in extra mode)"; \
	fi

.PHONY: brew_update_all
brew_update_all:
	@echo "Update Homebrew"
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
	bash $(SCRIPTS)/install-fonts.sh

# ******************** fish ********************
.PHONY: fish
fish:
	@echo "Setup Fish"
	bash $(SETUP_FISH)

# ******************** zsh ********************
.PHONY: zsh
zsh:
	@echo "Setup Zsh"
	$(MAKE) check-sudo
	# Run as the current user; setup-zsh.sh internally uses `sudo tee`
	# only for /etc/shells. Running the whole script as root would make
	# git-clone.sh create deps/* as root, causing later runs to hit
	# Permission denied when removing them.
	bash $(SETUP_ZSH)

.PHONY: zsh_extensions
zsh_extensions:
	@echo "Install Zsh Extensions"
	$(MAKE) check-sudo
	bash $(SCRIPTS)/install-zsh-extensions.sh

# ******************** linux ********************
.PHONY: linux_support_japanese
linux_support_japanese:
	@echo "Support Japanese"
	sudo bash $(SCRIPTS)/linux/support-japanese.sh

# ******************** ssh ********************
.PHONY: ssh-key-gen
ssh-key-gen:
	@echo "Generate SSH Key"
	bash $(SCRIPTS)/ssh-key-gen.sh

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
	@echo "Setup Tmux"
	bash $(SCRIPTS)/setup-tmux.sh

# ******************** dot files ********************
.PHONY: link l
link l:
#make check-sudo
	@echo "Link dot files"
	bash $(DEPLOY_CONFIGS) link $(ROOT)
	bash $(SCRIPTS)/setup-gitconfig.sh

.PHONY: copy
copy:
	@echo "Copy dot files"
	# sudo は不要（書き込み先はすべて $$HOME 配下）。root で実行すると
	# 配置ファイルが root 所有になり、root の gitconfig を書き換えてしまう
	bash $(DEPLOY_CONFIGS) copy $(ROOT)
	bash $(SCRIPTS)/setup-gitconfig.sh

.PHONY: delete
delete:
	$(MAKE) check-sudo
	@echo "Delete dot files"
	bash $(DEPLOY_CONFIGS) delete $(ROOT)

# ******************** clean ********************

.PHONY: clean c
clean c:
	@echo ""
	@echo "*** This will uninstall Homebrew, remove dotfiles, and reset your shell. ***"
	@if [ "$(NONINTERACTIVE)" != "1" ]; then \
		read -p "Continue? [y/N]: " ans; \
		case "$$ans" in y|Y|yes) ;; *) echo "Aborted."; exit 1;; esac; \
	fi
	$(MAKE) check-sudo
	$(MAKE) clean-deps
	@if [ "$(UNAME_S)" = "Darwin" ]; then \
		$(MAKE) uninstall-brew; \
	fi
	$(MAKE) delete
	$(MAKE) change-default-shell

.PHONY: clean-deps
clean-deps:
	@echo "Clean dependencies"
	rm -rf deps

.PHONY: uninstall-brew
uninstall-brew:
	@echo "Uninstall Homebrew"
	bash $(SCRIPTS)/uninstall-brew.sh

.PHONY: change-default-shell
change-default-shell:
	@echo "Change default shell"
	$(MAKE) check-sudo
	bash $(SCRIPTS)/change-default-shell.sh

# ******************** tests ********************
.PHONY: test t
test t:
	@echo "Running tests..."
	@chmod +x $(ROOT)/tests/run-tests.sh
	@$(ROOT)/tests/run-tests.sh

.PHONY: test-install-bats
test-install-bats:
	@echo "Installing BATS test framework..."
	@chmod +x $(ROOT)/tests/run-tests.sh
	@cd $(ROOT)/tests && ./run-tests.sh --install-only
