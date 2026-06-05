{ config, lib, pkgs, modulesPath, ... }:

###############################################################################
# Installer USB — the "doorway" image.
#
# This is NOT the final system. It's a minimal live NixOS you Rufus onto the
# 64GB USB. On boot it:
#   * brings up wired ethernet (DHCP)
#   * starts SSH with the nebula pubkey authorized (so Claude can get in)
#   * prints its IP address big on the console (the ONE thing the user reports)
#
# Then Claude SSHes in and runs the real install onto the SanDisk live.
#
# Built as the `installer` ISO output in flake.nix.
###############################################################################

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  # --- Networking: wired DHCP, SSH open ---
  networking.useDHCP = lib.mkForce true;
  networking.wireless.enable = lib.mkForce false; # X570 no-wifi; wired only

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password"; # key-only root for install
  };

  # nebula's pubkey → root, so Claude can SSH in and drive the install.
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1sPBK8ygLP3AZc7LXhchpfPtm71syew1Yic/wbDpRI nebula->nixos-boston"
  ];

  # Also allow the live `nixos` user in (some flows use it).
  users.users.nixos.openssh.authorizedKeys.keys =
    config.users.users.root.openssh.authorizedKeys.keys;

  # --- Tools the live install needs ---
  environment.systemPackages = with pkgs; [
    git
    parted gptfdisk
    disko
    nixos-install-tools
    tmux htop
    pciutils usbutils
  ];

  # Flakes available in the installer too.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Print the IP big on every console so the user can read + report it ---
  systemd.services.show-ip-banner = {
    description = "Print IP address banner for the user to report";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      IP=$(${pkgs.iproute2}/bin/ip -4 -o addr show scope global | ${pkgs.gawk}/bin/awk '{print $4}' | ${pkgs.coreutils}/bin/cut -d/ -f1 | ${pkgs.coreutils}/bin/head -n1)
      MSG="/etc/issue"
      {
        echo ""
        echo "  ============================================================"
        echo "    NixOS installer ready."
        echo ""
        echo "    >>> TEXT THIS IP TO CLAUDE:   ''${IP:-NO-IP-YET}"
        echo ""
        echo "    (ethernet must be plugged in; if NO-IP-YET, wait 20s or"
        echo "     run 'ip a' and look for a 192.168.x.x / 10.x.x.x line)"
        echo "  ============================================================"
        echo ""
      } | ${pkgs.coreutils}/bin/tee "$MSG"
    '';
  };

  # Let the installer pull our config + binary caches fast over ethernet.
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # Bigger ISO is fine; make sure firmware for the NIC is present.
  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "26.05";
}
