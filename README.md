# Tmux Configuration Flake

This repository provides a Nix flake for my personal tmux configuration, making it easy to use with home-manager.

## Features

- Personal tmux configuration with custom key bindings
- Sessionizer script for quick project switching
- SSH session management script
- Dynamic color theme switching
- Context menus for common operations
- Optimized for development workflow

## Usage with Home Manager

Add this flake to your home-manager configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    config-tmux.url = "github:irohn/config.tmux";
  };

  outputs = { nixpkgs, home-manager, config-tmux, ... }: {
    homeConfigurations.yourusername = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        config-tmux.homeManagerModules.default
        {
          programs.tmux.irohn-config.enable = true;
          # Your other home-manager configuration...
        }
      ];
    };
  };
}
```

## Manual Installation

If you prefer to install manually:

```bash
# Clone the repository
git clone https://github.com/irohn/config.tmux.git
cd config.tmux

# Build the package
nix build

# Run the setup script
./result/bin/setup-tmux-config
```

## Dependencies

The configuration requires the following tools:
- `tmux` - Terminal multiplexer
- `fzf` - Fuzzy finder for interactive selections
- `fd` - Fast file finder (optional, falls back to `find`)
- `bash` - For running the scripts

These dependencies are automatically included when using the home-manager module.

## Configuration Details

The configuration sets up:
- `~/.config/tmux/tmux.conf` - Main tmux configuration
- `~/.config/tmux/sessionizer.sh` - Project/directory switching script
- `~/.config/tmux/tssh.sh` - SSH session management script
- `~/.config/tmux/colorizer.sh` - Theme switching script
- `~/.config/tmux/menu.conf` - Context menu configuration
- `~/.config/tmux/colors/` - Color scheme definitions

## Key Bindings

- `<prefix> + f` - Open sessionizer (fuzzy find and switch to projects)
- `<prefix> + t` - Open SSH session manager
- `<prefix> + T` - Toggle color themes
- `<prefix> + R` - Reload configuration
- `Alt + h/l` - Switch between windows
- `Alt + H/L` - Move windows left/right
- `Alt + 1-9` - Jump to window by number
- Right-click - Context menu with common operations

## Customization

After installation, you can customize the configuration by editing files in `~/.config/tmux/`. The configuration will behave exactly as if you had cloned this repository to `~/.config/tmux`.

## License

MIT License