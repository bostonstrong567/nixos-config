{ config, lib, pkgs, inputs, ... }:

###############################################################################
# Nix dev tooling — the quality-of-life set for editing THIS repo + dev work.
###############################################################################

{
  # comma: run any package without installing — `, cowsay hi`. Needs nix-index
  # database to know what provides each command. Build it once after install:
  #   nix-index   (populates ~/.cache/nix-index/files)
  programs.nix-index.enable = true;

  environment.systemPackages = with pkgs; [
    # --- run-without-install ---
    comma               # `, <pkg>` run anything once
    # nix-index provides `nix-locate` (which pkg has this file) via the module above

    # --- dev environments ---
    direnv              # per-dir env auto-load
    nix-direnv          # fast nix/flake caching for direnv
    devenv              # reproducible dev shells

    # --- editing .nix (LSP + formatters) ---
    nixd                # Nix language server (best; nixpkgs-aware)
    nil                 # alt Nix LSP (lighter)
    alejandra           # opinionated fast formatter

    # --- inspection ---
    nix-tree            # browse dep graph / find bloat
    nvd                 # generation/version diff (also in apps.nix; harmless dup)

    # --- foreign binaries ---
    inputs.nix-alien.packages.${pkgs.system}.nix-alien  # run unpatched bins
  ];

  # direnv shell hook (system-wide). Per-user zsh hook also fine; this covers all.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
