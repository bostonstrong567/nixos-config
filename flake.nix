{
  description = "External-SSD NixOS — RTX 4080 / Ryzen 7 3800X — Hyprland showpiece (Windows-safe portable install)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lix — DROPPED. Its nixos-module pins an internal `lix` sub-input using the
    # `?rev=` tarball form, which trips a Nix url-normalization mismatch in
    # `nix flake check` no matter how the top-level input is written (tried
    # git+https AND archive/.tar.gz — both fail on the transitive sub-input).
    # Not load-bearing — stock CppNix works perfectly. Install Lix post-boot if
    # wanted:  curl -sSf -L https://install.lix.systems/lix | sh -s -- install

    # Always-fresh Claude Code (hourly updates from Anthropic releases)
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Spicetify (Spotify theming). the-argus archived → Gerg-L maintained fork.
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix — single-palette theming fanned out to GTK/Qt/terminal/VSCode/etc.
    # Pinned to release-26.05 to match nixpkgs (avoids version-mismatch warnings).
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-alien — run unpatched/foreign binaries on NixOS (FHS auto-deps).
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disko — declarative disk partitioning (used by nixos-anywhere remote install).
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-vscode-extensions — marketplace/OpenVSX extensions as Nix pkgs
    # (material-icon-theme + activitusbar aren't in nixpkgs base).
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, claude-code, spicetify-nix, stylix, nix-alien, disko, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.nebula-ext = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nebula-ext/configuration.nix
          ./hosts/nebula-ext/hardware-configuration.nix
          ./modules/nvidia.nix
          ./modules/hardware.nix
          ./modules/gaming.nix
          ./modules/desktop.nix
          ./modules/hyprland.nix
          ./modules/external-ssd.nix
          ./modules/apps.nix
          ./modules/theme.nix
          ./modules/cliamp-daemon.nix
          ./modules/dev-tools.nix
          ./modules/visualizer.nix

          # disko — declarative partitioning. Module + our SanDisk layout.
          # disko generates fileSystems.* from modules/disko.nix, so the
          # hardware-configuration.nix fileSystems block is NOT needed when
          # using this (they'd conflict). See REMOTE-INSTALL.md.
          disko.nixosModules.disko
          ./modules/disko.nix
          ./modules/remote.nix

          # Stylix — system-wide unified theming
          stylix.nixosModules.stylix

          # Overlays: claude-code (always-fresh) + our custom pkgs (cliamp, opcode)
          { nixpkgs.overlays = [
              claude-code.overlays.default
              (import ./overlays/default.nix)
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.sharedModules = [
              spicetify-nix.homeManagerModules.default
            ];
            home-manager.users.boston = import ./home/boston.nix;
          }
        ];
      };

      # Installer ISO — the "doorway" USB. Boots, gets ethernet + SSH + my key,
      # prints its IP. Build: nix build .#nixosConfigurations.installer.config.system.build.isoImage
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./modules/installer.nix ];
      };
    };
}
