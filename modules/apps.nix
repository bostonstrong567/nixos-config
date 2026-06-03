{ config, lib, pkgs, inputs, ... }:

###############################################################################
# System-level apps + tooling that aren't desktop/gaming/nvidia specific.
# User-facing GUI apps mostly live in home/rob.nix; this is system glue +
# things that want to be system-wide.
###############################################################################

{
  # cliamp + opcode come from overlays/default.nix (pkgs.cliamp / pkgs.opcode).
  # Nix dev tooling (nh/nom/comma/direnv/LSP/etc.) lives in modules/dev-tools.nix.
  environment.systemPackages = with pkgs; [
    # --- Nix build UX ---
    nix-output-monitor  # pretty build output (nom)
    cachix              # binary cache client

    # --- CLI power tools ---
    zoxide              # smart cd (z)
    fastfetch           # system info (replaces archey4)
    ripgrep fd bat eza  # modern unix replacements
    git

    # --- Claude Code (always-fresh via overlay) ---
    claude-code

    # --- CLIAMP terminal music player (pinned Go binary, verified hash) ---
    cliamp

    # --- opcode GUI (AppImage-wrapped; hash verified) ---
    opcode
  ];

  # nh needs to know where your flake lives for `nh os switch`
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };
  # (zoxide shell integration is configured per-user in home/rob.nix)

  # Waydroid — run Android apps in a container. Enable the system service;
  # first run needs `sudo waydroid init` after boot.
  virtualisation.waydroid.enable = true;
}
