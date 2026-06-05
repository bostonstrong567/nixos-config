# Live SSH install runbook (Claude executes this once user gives the IP)

This is the exact, ordered procedure Claude runs after the user boots the
installer USB and reports the IP. Designed to be SAFE: confirm the target disk
before any destructive action.

## 0. Connect
```bash
ssh -i ~/.ssh/nebula_nixos root@<USER_IP>
```
(Key already authorized in modules/installer.nix.)

## 1. Identify the target disk — SAFETY GATE
```bash
lsblk -o NAME,SIZE,MODEL,TRAN,SERIAL
ls -l /dev/disk/by-id/ | grep -i sandisk
```
- The external SanDisk is `TRAN=usb`, size ~1.8–2.0T, MODEL contains `SanDisk`/`Extreme`.
- Windows drives (Seagate 2TB, 860 EVO) are `TRAN=sata`/`nvme` — **never** usb.
- **STOP if:** zero SanDisk matches, OR more than one usb disk that size.
  Show the user `lsblk` output and confirm which `/dev/disk/by-id/...` is correct.
- Record the by-id path, e.g. `/dev/disk/by-id/usb-SanDisk_Extreme_XXXX-0:0`.

## 2. Pin the disk in disko
```bash
git clone https://github.com/bostonstrong567/nixos-config /tmp/cfg
cd /tmp/cfg
# Replace the placeholder with the REAL by-id path found above:
sed -i 's|/dev/disk/by-id/usb-SanDisk_Extreme_REPLACE_ME|<REAL_BYID>|' modules/disko.nix
git diff modules/disko.nix   # show the user the exact target before wiping
```

## 3. Partition + format (disko) — DESTRUCTIVE, confirmed target only
```bash
sudo nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- \
  --mode disko /tmp/cfg/modules/disko.nix
```

## 4. Install the system
```bash
sudo nixos-install --flake /tmp/cfg#nebula-ext --no-root-passwd
```
- Pulls from cache.nixos.org + nix-community over the user's ethernet.
- boston user + hashed password (1005) come from the config.

## 5. Post-install reachability (so Claude keeps access after reboot)
- SSH key + Tailscale already in the installed config (modules/remote.nix).
- If using Tailscale: drop the auth key before reboot:
```bash
echo "tskey-auth-XXXX" | sudo tee /mnt/etc/tailscale-authkey
sudo chmod 600 /mnt/etc/tailscale-authkey
```

## 6. Reboot into the real system
```bash
sudo reboot
```
- Remove USB. PC boots the SanDisk → greetd → Hyprland.
- Log in: user `boston`, password `1005`.

## 7. Verify (after it boots, over SSH/Tailscale)
```bash
nvidia-smi                 # 4080 recognized
echo $XDG_SESSION_TYPE     # wayland
hyprctl version            # Hyprland running
systemctl --user status waybar
```

## Rollback safety
Every rebuild = a generation. If a change breaks boot → pick the previous
generation in the GRUB menu. Nothing is unrecoverable.
