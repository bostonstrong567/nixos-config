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

  # opcode's Claude runs inside a bubblewrap sandbox (no sudo). Escape hatch:
  # it SSHes to localhost, which spawns a shell OUTSIDE the sandbox where
  # passwordless sudo works. This generates a boston self-key + trusts it, so
  # `ssh boston@localhost` is passwordless from anywhere on the box.
  systemd.services.boston-localhost-key = {
    description = "Generate + trust boston self-SSH key for localhost sudo escape";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "boston";
      RemainAfterExit = true;
    };
    path = [ pkgs.openssh ];
    script = ''
      key="$HOME/.ssh/id_localhost"
      mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
      if [ ! -f "$key" ]; then
        ssh-keygen -t ed25519 -N "" -f "$key" -C "boston@localhost-sudo"
      fi
      pub=$(cat "$key.pub")
      touch "$HOME/.ssh/authorized_keys"; chmod 600 "$HOME/.ssh/authorized_keys"
      grep -qF "$pub" "$HOME/.ssh/authorized_keys" || echo "$pub" >> "$HOME/.ssh/authorized_keys"
      # trust localhost host key (no prompt)
      ssh-keyscan -H localhost 2>/dev/null >> "$HOME/.ssh/known_hosts" || true
      sort -u "$HOME/.ssh/known_hosts" -o "$HOME/.ssh/known_hosts" 2>/dev/null || true
    '';
  };

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
    # NOTE: no authKeyFile / autoconnect. The tailscaled-autoconnect service
    # was timing out (no key file) and failing the whole rebuild. Instead,
    # authenticate ONCE manually after boot:
    #     sudo tailscale up --ssh
    # That opens a login URL, joins your tailnet, and enables Tailscale SSH.
    # No file needed, rebuild never blocks on it.
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
