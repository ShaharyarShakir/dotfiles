# Dotfiles Makefile
#
# GNU Stow based dotfiles for Hyprland, NixOS and BlendOS.
# Run `make` or `make help` to list the available targets.

SHELL       := $(shell command -v bash 2>/dev/null || echo /bin/sh)
.SHELLFLAGS := -eu -c
.DEFAULT_GOAL := help

DOTFILES    := $(CURDIR)
STOW        ?= stow
STOW_TARGET ?= $(HOME)/.config
STOW_FLAGS  ?=
NIX_HOST    ?= nixos
NIX_FLAKE   ?= $(DOTFILES)/nixos

# Packages that must be stowed to $HOME instead of ~/.config.
HOME_PACKAGES := zsh

# Top-level directories that are not standalone stow packages.
NON_PACKAGES  := backgrounds images scripts blendos nixos
STOW_PACKAGES := $(filter-out $(NON_PACKAGES),$(patsubst %/,%,$(wildcard */)))

STOW_CMD = $(STOW) -t $(STOW_TARGET) $(STOW_FLAGS)

.PHONY: help install deps devbox stow link adopt restow unstow update status check \
        list tmux nixos blendos cleanup sync-projects stow-% unstow-% restow-%

##@ Setup

help: ## Show this help
	@printf "\n"
	@awk 'BEGIN {FS = ":.*## "} \
		/^[a-zA-Z0-9_%-]+:.*## / {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2} \
		/^##@/ {printf "\n\033[1m%s\033[0m\n", substr($$0, 5)}' $(MAKEFILE_LIST)
	@printf "\n  Packages: %s\n" "$(STOW_PACKAGES)"
	@printf "  Example:  make stow-nvim   (link a single package)\n\n"

install: ## Bootstrap dependencies, link dotfiles and install devbox
	@bash install.sh

deps: ## Install CLI packages, fonts and shell configuration
	@bash bash/install.sh

devbox: ## Install devbox if it is not already available
	@if command -v devbox >/dev/null 2>&1; then \
		echo "devbox is already installed"; \
	else \
		echo "==> Installing devbox"; \
		curl -fsSL https://get.jetify.com/devbox | bash; \
	fi

##@ Linking

stow: ## Link every package into STOW_TARGET (default: ~/.config)
	@echo "==> Stowing all packages into $(STOW_TARGET)"
	$(STOW_CMD) .

link: stow ## Alias for stow

adopt: ## Stow and move conflicting files into the repo (--adopt)
	@echo "==> Adopting existing files into the repo"
	$(STOW) --adopt -t $(STOW_TARGET) $(STOW_FLAGS) .

restow: ## Refresh all managed symlinks (--restow)
	@echo "==> Restowing all packages"
	$(STOW) --restow -t $(STOW_TARGET) $(STOW_FLAGS) .

unstow: ## Remove all symlinks managed by stow
	@echo "==> Removing all stow symlinks"
	$(STOW) --delete -t $(STOW_TARGET) $(STOW_FLAGS) .

stow-%: ## Link one package (e.g. make stow-nvim)
	@target="$(STOW_TARGET)"; \
	for pkg in $(HOME_PACKAGES); do \
		if [ "$$pkg" = "$*" ]; then target="$(HOME)"; fi; \
	done; \
	echo "==> Stowing $* into $$target"; \
	$(STOW) -t "$$target" $(STOW_FLAGS) "$*"

unstow-%: ## Unlink one package (e.g. make unstow-nvim)
	@target="$(STOW_TARGET)"; \
	for pkg in $(HOME_PACKAGES); do \
		if [ "$$pkg" = "$*" ]; then target="$(HOME)"; fi; \
	done; \
	echo "==> Unstowing $* from $$target"; \
	$(STOW) --delete -t "$$target" $(STOW_FLAGS) "$*"

restow-%: ## Refresh one package (e.g. make restow-nvim)
	@target="$(STOW_TARGET)"; \
	for pkg in $(HOME_PACKAGES); do \
		if [ "$$pkg" = "$*" ]; then target="$(HOME)"; fi; \
	done; \
	echo "==> Restowing $* into $$target"; \
	$(STOW) --restow -t "$$target" $(STOW_FLAGS) "$*"

##@ Maintenance

update: ## Pull the latest changes and refresh symlinks
	git pull --ff-only
	$(MAKE) restow

status: ## Show git status and a stow dry-run
	@git status --short
	@echo "--- stow dry-run ---"
	@$(STOW) --no --verbose -t $(STOW_TARGET) $(STOW_FLAGS) . || true

check: ## Verify stow, shell syntax and link conflicts
	@command -v $(STOW) >/dev/null 2>&1 || { \
		echo "error: GNU Stow not found. Install it with your package manager." >&2; \
		exit 1; \
	}
	@echo "==> Checking shell syntax"
	@bash -n install.sh
	@bash -n bash/install.sh
	@for f in scripts/*.sh tmux/install-tpm.sh; do bash -n "$$f"; done
	@echo "==> Checking stow links"
	@$(STOW) --no -t $(STOW_TARGET) $(STOW_FLAGS) .
	@echo "==> All checks passed"

list: ## List packages usable as make stow-<package>
	@printf '%s\n' $(STOW_PACKAGES)

##@ System

nixos: ## Rebuild NixOS from nixos/ (override with NIX_HOST=name)
	sudo nixos-rebuild switch --flake $(NIX_FLAKE)#$(NIX_HOST)

blendos: ## Sync the BlendOS declarative system config
	sudo blendos-track sync $(DOTFILES)/blendos/system.yaml

tmux: ## Install Tmux Plugin Manager and its plugins
	@bash tmux/install-tpm.sh

##@ Utilities

cleanup: ## Clean package caches and orphaned packages (Arch only)
	@bash scripts/cleanup.sh

sync-projects: ## Sync project directories using scripts/sync_projects.sh
	@bash scripts/sync_projects.sh
