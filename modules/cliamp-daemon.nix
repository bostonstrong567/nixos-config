{ config, lib, pkgs, ... }:

###############################################################################
# CLIAMP as a background audio service.
#
# cliamp has --daemon (headless playback) + MPRIS (D-Bus) so:
#   * Plasma's panel media widget controls it (play/pause/skip)
#   * Hardware media keys work (XF86Audio* -> playerctl -> cliamp)
#   * It exposes now-playing to the whole desktop
#
# This wires the *system* bits (playerctl available, MPRIS allowed). The actual
# user service + a scratchpad launcher live under home-manager (home/rob.nix
# imports nothing extra — the systemd user service is defined here at system
# level via `systemd.user.services` so it's available to every login).
###############################################################################

{
  environment.systemPackages = with pkgs; [
    playerctl   # CLI MPRIS controller (media keys glue)
  ];

  # Background cliamp daemon as a user service (starts on login, restarts if it
  # dies). Disabled by default so it doesn't fight you on day one — enable with:
  #   systemctl --user enable --now cliamp
  systemd.user.services.cliamp = {
    description = "CLIAMP background music daemon (MPRIS)";
    # Not wanted-by default target → opt-in. Flip to [ "default.target" ] to
    # autostart at login once you've confirmed your music sources are set up.
    wantedBy = lib.mkDefault [ ];
    serviceConfig = {
      ExecStart = "${pkgs.cliamp}/bin/cliamp --daemon";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
