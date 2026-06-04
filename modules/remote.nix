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

  # Authorized keys for the `boston` user.
  # nebula's pubkey is pre-filled so Claude (on nebula) can SSH in after boot.
  # Add your phone/laptop pubkeys to the list as needed.
  users.users.boston.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1sPBK8ygLP3AZc7LXhchpfPtm71syew1Yic/wbDpRI nebula->nixos-boston"
    # "ssh-ed25519 AAAA... boston@phone"   # <-- add other clients here
  ];

  # Root authorized keys (needed for nixos-anywhere remote install).
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1sPBK8ygLP3AZc7LXhchpfPtm71syew1Yic/wbDpRI nebula->nixos-boston"
  ];

  ###########################################################################
  # Tailscale — private mesh, reachable from anywhere through NAT.
  ###########################################################################
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";

    # PRE-LOGIN to YOUR existing tailnet, no manual browser auth.
    # Generate a reusable auth key (tied to your account) at:
    #   https://login.tailscale.com/admin/settings/keys  → "Generate auth key"
    #   (tick Reusable + Pre-approved; optionally Ephemeral=off so it persists)
    # Put the key in a file ON THE MACHINE (NOT committed) at /etc/tailscale-authkey
    # then this auto-joins the tailnet on first boot.
    authKeyFile = "/etc/tailscale-authkey";

    # Extra flags applied on auto-up. --ssh enables Tailscale SSH (ACL-gated,
    # no key files needed → simplest way for nebula to reach this box).
    extraUpFlags = [ "--ssh" ];
  };

  # The auth-key file must exist before tailscaled starts. Two ways to place it:
  #   * Manual (simplest): after first boot, `echo tskey-auth-XXXX | sudo tee \
  #       /etc/tailscale-authkey` then `sudo systemctl restart tailscaled`.
  #   * Remote install: nixos-anywhere can copy it via --extra-files. See
  #     REMOTE-INSTALL.md.
  # For a committed-secret workflow later, switch to agenix/sops-nix (encrypted).

  # Keep firewall on; Tailscale manages its own interface.
  networking.firewall.enable = true;

  ###########################################################################
  # Mosh (optional) — resilient SSH over flaky links. Handy for a roaming box.
  ###########################################################################
  programs.mosh.enable = true;
}
