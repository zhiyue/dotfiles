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

# Print debug information
debug() {
  printf "\033[0;36m[DEBUG] %s\033[0m\n" "$1"
}

# Ensure required directories exist
ensure_dirs() {
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share"
  debug "Created required directories"
}

# Ensure required directories exist first
ensure_dirs

# Install chezmoi if not already installed
if ! command -v chezmoi >/dev/null 2>&1; then
  info "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
  export PATH="$HOME/.local/bin:$PATH"
  success "Chezmoi installed successfully"
else
  info "Chezmoi already installed"
fi

# Verify chezmoi is in PATH
if ! command -v chezmoi >/dev/null 2>&1; then
  error "Chezmoi not found in PATH after installation"
  debug "Current PATH: $PATH"
  debug "Attempting to use absolute path"
  CHEZMOI_BIN="$HOME/.local/bin/chezmoi"
  if [ -f "$CHEZMOI_BIN" ]; then
    debug "Found chezmoi binary at $CHEZMOI_BIN"
  else
    error "Chezmoi binary not found at $CHEZMOI_BIN"
    exit 1
  fi
else
  debug "Chezmoi found in PATH: $(which chezmoi)"
  CHEZMOI_BIN="chezmoi"
fi

# Debug current directory and contents
debug "Current directory: $PWD"
debug "Directory contents: $(ls -la)"

# Initialize and apply chezmoi configuration
info "Initializing chezmoi with current repository..."
$CHEZMOI_BIN init --source="$PWD"

# Check if initialization was successful
if [ $? -ne 0 ]; then
  error "Chezmoi initialization failed"
  exit 1
fi

debug "Chezmoi source directory: $($CHEZMOI_BIN source-path)"
debug "Home directory: $HOME"

info "Applying dotfiles configuration..."
$CHEZMOI_BIN apply -v

if [ $? -ne 0 ]; then
  error "Chezmoi apply failed"
  exit 1
fi

success "Dotfiles installation complete!"
