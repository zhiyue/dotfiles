#!/bin/bash
set -e

# This script installs chezmoi and applies dotfiles in a container environment
# It's designed to be used with VSCode's dotfiles feature

# Print colorful messages
info() {
  printf "\033[0;34m%s\033[0m\n" "$1"
}

success() {
  printf "\033[0;32m%s\033[0m\n" "$1"
}

warning() {
  printf "\033[0;33m%s\033[0m\n" "$1"
}

error() {
  printf "\033[0;31m%s\033[0m\n" "$1"
}

# Install chezmoi if not already installed
if ! command -v chezmoi >/dev/null 2>&1; then
  info "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
  export PATH="$HOME/.local/bin:$PATH"
  success "Chezmoi installed successfully"
else
  info "Chezmoi already installed"
fi

# Initialize and apply chezmoi configuration
info "Initializing chezmoi with current repository..."
chezmoi init --source="$PWD"

info "Applying dotfiles configuration..."
chezmoi apply

success "Dotfiles installation complete!"
