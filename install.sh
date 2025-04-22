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
debug "Using source directory: $PWD"
$CHEZMOI_BIN init --source="$PWD"

# Check if initialization was successful
if [ $? -ne 0 ]; then
  error "Chezmoi initialization failed"
  debug "Failed to initialize with source: $PWD"
  debug "Contents of source directory: $(ls -la $PWD)"
  exit 1
fi

# Get and verify the chezmoi source path
CHEZMOI_SOURCE_PATH="$($CHEZMOI_BIN source-path 2>/dev/null || echo '')"
debug "Chezmoi source directory: $CHEZMOI_SOURCE_PATH"
debug "Home directory: $HOME"

# Ensure the source directory exists
if [ -z "$CHEZMOI_SOURCE_PATH" ] || [ ! -d "$CHEZMOI_SOURCE_PATH" ]; then
  error "Chezmoi source directory does not exist or could not be determined"
  debug "Attempting to create source directory manually"
  mkdir -p "$HOME/.local/share/chezmoi"

  # Try to copy files from current directory to chezmoi source directory
  if [ -d "$PWD" ] && [ -n "$(ls -A "$PWD")" ]; then
    debug "Copying files from $PWD to $HOME/.local/share/chezmoi"
    cp -r "$PWD/"* "$HOME/.local/share/chezmoi/" 2>/dev/null || true
    CHEZMOI_SOURCE_PATH="$HOME/.local/share/chezmoi"
  else
    error "Failed to initialize chezmoi source directory"
    exit 1
  fi
fi

debug "Contents of chezmoi source directory: $(ls -la "$CHEZMOI_SOURCE_PATH" 2>/dev/null || echo 'Cannot list directory')"

info "Applying dotfiles configuration..."
$CHEZMOI_BIN apply -v

if [ $? -ne 0 ]; then
  error "Chezmoi apply failed"
  debug "Apply command failed. Try running manually: $CHEZMOI_BIN apply -v --debug"
  exit 1
fi

success "Dotfiles installation complete!"
