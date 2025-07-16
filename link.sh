#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#coreutils --command bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure ~/.config exists
mkdir -p "$HOME/.config"

# Remove existing nvim config if present
rm -rf "$HOME/.config/tmux"

# Link tmux config to the script directory
ln -s "$SCRIPT_DIR" "$HOME/.config/tmux"
