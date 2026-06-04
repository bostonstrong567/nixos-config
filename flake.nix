{
  description = "External-SSD NixOS — RTX 4080 / Ryzen 7 3800XT — KDE Plasma 6 showpiece (Windows-safe portable install)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Lix — modern Nix daemon. Use the TARBALL-URL form (archive/<ver>.tar.gz)
    # not git+https — the tarball form avoids the ?rev= url-normalization
    # mismatch that broke `nix flake check` earlier.
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = { self, nixpkgs, home-manager, plasma-manager, claude-code, spicetify-nix, stylix, nix-alien, disko, lix-module, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.nebula-ext = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # Lix as the Nix implementation (lixFromNixpkgs = no source build).
          lix-module.nixosModules.lixFromNixpkgs

          ./hosts/nebula-ext/configuration.nix
          ./hosts/nebula-ext/hardware-configuration.nix
          ./modules/nvidia.nix
          ./modules/hardware.nix
          ./modules/gaming.nix
          ./modules/desktop.nix
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
              plasma-manager.homeModules.plasma-manager
              spicetify-nix.homeManagerModules.default
            ];
            home-manager.users.boston = import ./home/boston.nix;
          }
        ];
      };
    };
}
