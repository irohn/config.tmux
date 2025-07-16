#!/bin/bash
set -e

echo "Testing tmux configuration flake..."

# Test 1: Check if all required files exist
echo "✓ Checking required files exist..."
required_files=(
    "tmux.conf"
    "colorizer.sh"
    "sessionizer.sh"
    "tssh.sh"
    "menu.conf"
    "colors/tomorrow-night.conf"
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Missing required file: $file"
        exit 1
    fi
done

# Test 2: Check if scripts are executable
echo "✓ Checking script permissions..."
scripts=("colorizer.sh" "sessionizer.sh" "tssh.sh")
for script in "${scripts[@]}"; do
    if [[ ! -x "$script" ]]; then
        echo "❌ Script not executable: $script"
        exit 1
    fi
done

# Test 3: Check if scripts have proper shebang
echo "✓ Checking script shebangs..."
for script in "${scripts[@]}"; do
    if ! head -1 "$script" | grep -q "#!/usr/bin/env bash"; then
        echo "❌ Script missing proper shebang: $script"
        exit 1
    fi
done

# Test 4: Check if tmux.conf references the correct paths
echo "✓ Checking tmux.conf path references..."
if ! grep -q "~/.config/tmux/" tmux.conf; then
    echo "❌ tmux.conf missing expected path references"
    exit 1
fi

# Test 5: Check if colorizer.sh references the correct color path
echo "✓ Checking colorizer.sh path references..."
if ! grep -q "\$HOME/.config/tmux/colors" colorizer.sh; then
    echo "❌ colorizer.sh missing expected path references"
    exit 1
fi

# Test 6: Validate flake.nix syntax (basic check)
echo "✓ Checking flake.nix basic syntax..."
if [[ -f "flake.nix" ]]; then
    # Check for required sections
    if ! grep -q "description" flake.nix; then
        echo "❌ flake.nix missing description"
        exit 1
    fi
    if ! grep -q "inputs" flake.nix; then
        echo "❌ flake.nix missing inputs"
        exit 1
    fi
    if ! grep -q "outputs" flake.nix; then
        echo "❌ flake.nix missing outputs"
        exit 1
    fi
    if ! grep -q "homeManagerModules" flake.nix; then
        echo "❌ flake.nix missing homeManagerModules"
        exit 1
    fi
else
    echo "❌ flake.nix not found"
    exit 1
fi

echo "✅ All tests passed! The tmux configuration flake is ready."
echo
echo "To use with home-manager, add to your flake inputs:"
echo "  config-tmux.url = \"github:irohn/config.tmux\";"
echo
echo "Then enable in your home-manager configuration:"
echo "  programs.tmux.irohn-config.enable = true;"