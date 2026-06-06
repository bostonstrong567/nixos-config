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
    inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien  # run unpatched bins

    # --- language runtimes (needed by Claude plugins/MCP + general dev) ---
    nodejs_22           # node + npm + npx (claude-mem, many tools)
    bun                 # fast JS runtime (claude-mem MCP uses it)
    python313           # python3
    uv                  # fast python pkg/venv manager
    go                  # go toolchain
    rustup              # rust toolchain manager

    # --- CLI power tools (modern, fast) — no dups with apps.nix/configuration.nix ---
    jq yq-go            # JSON / YAML processors
    sqlite              # inspect opcode's agents.db etc.
    fzf                 # fuzzy finder
    tldr                # concise man pages
    dust                # better du (disk usage)
    duf                 # better df
    procs               # better ps
    sd                  # better sed
    delta               # better git diff
    lazygit             # git TUI
    gh                  # GitHub CLI (not elsewhere)
    yazi                # terminal file manager
    tokei               # code stats
    hyperfine           # benchmark tool
    unzip p7zip         # archives
    file tree           # inspection
    ripgrep-all         # rg for PDFs/archives too
  ];

  # direnv shell hook (system-wide). Per-user zsh hook also fine; this covers all.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
