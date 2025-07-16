# Example Home Manager Configuration

This directory contains example configurations showing how to integrate this tmux configuration flake with home-manager.

## Basic Usage

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    config-tmux.url = "github:irohn/config.tmux";
  };

  outputs = { nixpkgs, home-manager, config-tmux, ... }: {
    homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        config-tmux.homeManagerModules.default
        {
          home.username = "your-username";
          home.homeDirectory = "/home/your-username";
          home.stateVersion = "23.05";
          
          programs.tmux.irohn-config.enable = true;
          
          # Other home-manager configuration...
        }
      ];
    };
  };
}
```

## Advanced Usage with Custom Tmux Package

```nix
# home.nix
{
  programs.tmux.irohn-config = {
    enable = true;
    package = pkgs.tmux;  # Use specific tmux version
  };
}
```

## Manual Installation Alternative

If you prefer not to use the home-manager module:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    config-tmux.url = "github:irohn/config.tmux";
  };

  outputs = { nixpkgs, config-tmux, ... }: {
    homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        {
          home.packages = [
            config-tmux.packages.x86_64-linux.default
          ];
          
          # Then run the setup script manually:
          # ~/.nix-profile/bin/setup-tmux-config
        }
      ];
    };
  };
}
```

## Building and Testing

```bash
# Test the configuration
nix flake check

# Build the package
nix build

# Run the setup script
./result/bin/setup-tmux-config
```