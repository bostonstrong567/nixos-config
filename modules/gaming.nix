{ config, lib, pkgs, ... }:

###############################################################################
# Gaming stack — Steam + Proton + GameMode + MangoHud + Gamescope.
# Tuned for RTX 4080 AAA gaming on Wayland.
###############################################################################

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    # Disabled: when combined with programs.gamescope.capSysNice, the steam module
    # forces Steam's FHS env to use a *setuid* bwrap wrapper. This nixpkgs builds
    # bubblewrap without setuid support, so it aborts with
    # "setuid use of bubblewrap is not supported in this build" and Steam won't launch.
    # Unprivileged user namespaces are enabled on this host, so the normal (non-setuid)
    # bwrap works fine. Per-game gamescope still works via `gamescope -- %command%`.
    gamescopeSession.enable = false;

    # Proton-GE via Steam's compatibilitytools dir is easiest; or use proton-ge here:
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      # Pin GPU to max perf while a game runs
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1; # prefer max performance
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud         # FPS/temp/usage overlay
    protonplus       # Proton-GE manager (GTK4/libadwaita — replaces protonup-qt)
    lutris           # non-Steam games / launchers
    heroic           # Epic / GOG
    bottles          # Wine prefix manager (Windows apps/games)
    vkbasalt         # post-processing (sharpening, etc.)
    goverlay         # MangoHud GUI config
    steamtinkerlaunch # per-game launch options / mod tooling
    corectrl         # GPU/CPU monitor + control (AMD CPU + NVIDIA GPU)
  ];

  # Bigger pipe for shader caches / downloads
  boot.kernel.sysctl."vm.max_map_count" = 2147483642; # some games (e.g. Star Citizen) need this
}
