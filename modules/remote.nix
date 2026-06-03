{ config, lib, pkgs, ... }:

###############################################################################
# Remote access — so the box is reachable for management after first boot.
#
#   * OpenSSH, KEY-ONLY (passwords disabled) — hardened.
#   * Tailscale — mesh VPN; gives the PC a stable private IP reachable from
#     anywhere (incl. the nebula cloud box) with NO router port-forwarding and
#     NO public exposure.
#
# This is what lets Claude (running on nebula) SSH in over Tailscale to run
# `nixos-rebuild` for you. The PC must be powered on + online to be reachable.
###############################################################################

{
  ###########################################################################
  # SSH — key-only. NEVER exposes a password prompt to the network.
  ###########################################################################
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;       # keys only
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password"; # root only via key (for nixos-anywhere)
    };
    openFirewall = true; # ok: with Tailscale you can also set this false + rely on tailnet
  };

  # Authorized keys for the `rob` user. ADD your + nebula's public keys here.
  # Generate on nebula:  ssh-keygen -t ed25519 -C "nebula->nixos"
  # Then paste the .pub contents below.
  users.users.rob.openssh.authorizedKeys.keys = [
    # "ssh-ed25519 AAAA... nebula->nixos"   # <-- nebula's pubkey
    # "ssh-ed25519 AAAA... rob@phone"        # <-- any other client
  ];

  # Root authorized keys (only needed for nixos-anywhere remote install).
  users.users.root.openssh.authorizedKeys.keys = [
    # "ssh-ed25519 AAAA... nebula->nixos"
  ];

  ###########################################################################
  # Tailscale — private mesh, reachable from anywhere through NAT.
  ###########################################################################
  services.tailscale = {
    enable = true;
    # 'both' = accept routes + act as exit-node-capable if you ever want it.
    useRoutingFeatures = "client";
  };

  # After first boot, authenticate the machine once:
  #   sudo tailscale up
  # ...then it's reachable at its 100.x.y.z tailnet IP (and MagicDNS name).
  # Tailscale SSH (optional, even simpler — ACL-gated, no key files):
  #   sudo tailscale up --ssh

  # Keep firewall on; Tailscale manages its own interface.
  networking.firewall.enable = true;

  ###########################################################################
  # Mosh (optional) — resilient SSH over flaky links. Handy for a roaming box.
  ###########################################################################
  programs.mosh.enable = true;
}
