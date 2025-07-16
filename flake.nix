{
  description = "Personal tmux configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "config-tmux";
          version = "1.0.0";
          
          src = ./.;
          
          nativeBuildInputs = with pkgs; [ ];
          
          buildInputs = with pkgs; [
            tmux
            bash
            coreutils
            findutils
            fzf
            fd
          ];
          
          dontBuild = true;
          
          installPhase = ''
            runHook preInstall
            
            mkdir -p $out/share/tmux
            
            # Copy all configuration files
            cp tmux.conf $out/share/tmux/
            cp menu.conf $out/share/tmux/
            cp colorizer.sh $out/share/tmux/
            cp sessionizer.sh $out/share/tmux/
            cp tssh.sh $out/share/tmux/
            
            # Copy colors directory
            cp -r colors $out/share/tmux/
            
            # Make scripts executable
            chmod +x $out/share/tmux/colorizer.sh
            chmod +x $out/share/tmux/sessionizer.sh
            chmod +x $out/share/tmux/tssh.sh
            
            # Create wrapper script that sets up the configuration
            mkdir -p $out/bin
            cat > $out/bin/setup-tmux-config << 'EOF'
            #!/bin/bash
            set -e
            
            # Ensure ~/.config directory exists
            mkdir -p "$HOME/.config"
            
            # Remove existing tmux config if it's a symlink
            if [[ -L "$HOME/.config/tmux" ]]; then
              rm "$HOME/.config/tmux"
            fi
            
            # Create ~/.config/tmux directory if it doesn't exist
            mkdir -p "$HOME/.config/tmux"
            
            # Copy all configuration files to ~/.config/tmux
            cp -r TMUX_CONFIG_PATH/* "$HOME/.config/tmux/"
            
            # Ensure scripts are executable
            chmod +x "$HOME/.config/tmux/colorizer.sh"
            chmod +x "$HOME/.config/tmux/sessionizer.sh"
            chmod +x "$HOME/.config/tmux/tssh.sh"
            
            echo "Tmux configuration installed to ~/.config/tmux"
            EOF
            
            # Replace placeholder with actual path
            sed -i "s|TMUX_CONFIG_PATH|$out/share/tmux|g" $out/bin/setup-tmux-config
            chmod +x $out/bin/setup-tmux-config
            
            runHook postInstall
          '';
          
          meta = with pkgs.lib; {
            description = "Personal tmux configuration with sessionizer and theming";
            homepage = "https://github.com/irohn/config.tmux";
            license = licenses.mit;
            maintainers = [];
            platforms = platforms.unix;
          };
        };

        # Provide a home-manager module
        homeManagerModules.default = { config, lib, pkgs, ... }:
          let
            cfg = config.programs.tmux.irohn-config;
            tmuxConfig = self.packages.${system}.default;
          in
          {
            options.programs.tmux.irohn-config = {
              enable = lib.mkEnableOption "irohn's tmux configuration";
              
              package = lib.mkOption {
                type = lib.types.package;
                default = pkgs.tmux;
                description = "The tmux package to use";
              };
            };

            config = lib.mkIf cfg.enable {
              programs.tmux = {
                enable = true;
                package = cfg.package;
                extraConfig = ''
                  # Source the tmux configuration
                  source-file "${tmuxConfig}/share/tmux/tmux.conf"
                '';
              };

              # Install the configuration files to ~/.config/tmux
              home.activation.tmuxConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
                $DRY_RUN_CMD mkdir -p $HOME/.config/tmux
                $DRY_RUN_CMD cp -r ${tmuxConfig}/share/tmux/* $HOME/.config/tmux/
                $DRY_RUN_CMD chmod +x $HOME/.config/tmux/colorizer.sh
                $DRY_RUN_CMD chmod +x $HOME/.config/tmux/sessionizer.sh
                $DRY_RUN_CMD chmod +x $HOME/.config/tmux/tssh.sh
              '';

              # Add required dependencies to PATH
              home.packages = with pkgs; [
                fzf
                fd
                tmux
              ];
            };
          };

        # Alternative: just provide the config files as a package
        packages.tmux-config = pkgs.runCommand "tmux-config-files" {} ''
          mkdir -p $out
          cp -r ${./.}/* $out/
          chmod +x $out/colorizer.sh
          chmod +x $out/sessionizer.sh  
          chmod +x $out/tssh.sh
        '';
      });
}