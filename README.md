# NixOS on an External SSD — RTX 4080 / Ryzen 7 3800XT

A complete, reproducible NixOS config for a **portable external-SSD install** that
leaves your Windows machine **completely untouched**. Pull the SSD out and the PC
boots Windows exactly as before — no boot entries, no NVRAM changes, nothing written
to the internal disk.

- **Desktop:** KDE Plasma 6 (Wayland) — mouse-native, riced into a blur/transparency showpiece
- **GPU:** RTX 4080 (Ada) with the open kernel module, Wayland-safe
- **Gaming:** Steam + Proton-GE + GameMode + MangoHud + Gamescope + Lutris + Heroic
- **Safety:** every rebuild is a bootable "generation"; bad change → reboot → pick the last good one

---

## How the Windows-safe boot works

The risky part of any second-OS install is the bootloader writing entries into your
PC's firmware (NVRAM) or onto the internal Windows disk. This config disables that:

| Setting | Effect |
|---|---|
| `boot.loader.efi.canTouchEfiVariables = false` | Never writes a boot entry to the PC's NVRAM |
| `grub.efiInstallAsRemovable = true` | Installs GRUB to the **removable fallback path** (`/EFI/BOOT/BOOTX64.EFI`) on the **SSD's own ESP** |
| `grub.useOSProber = false` | Never scans or touches the internal Windows disk |

**You boot NixOS by pressing your motherboard's boot-menu key (often F12 / F11 / F8)
and choosing the external SSD.** Windows' own bootloader is never modified.

---

## ⚠️ Before you touch any disk — read this

> **Warning:** The install partitions a disk. If you select the wrong disk you will
> destroy your Windows install or your data. There is no undo for `mkfs`/partitioning.
>
> **Mitigations — do all of them:**
> 1. **Physically unplug every other external drive** before starting. Leave only the
>    target external SSD and your install USB connected.
> 2. After booting the installer, run `lsblk -o NAME,SIZE,MODEL,TRAN` and **identify
>    the SSD by its model name and size**, not by guessing `/dev/sdX`. The `TRAN`
>    column shows `usb` for the external SSD vs `nvme`/`sata` for internal disks.
> 3. Write the device name on paper. Use that exact name in every command below.

In the steps below the external SSD is called `/dev/sdX`. **Replace `/dev/sdX` with the
real device you confirmed.** The internal Windows disk is typically `/dev/nvme0n1` — do
**not** touch it.

---

## Install steps

### 1. Boot the official NixOS installer

Download the **NixOS 26.05** minimal or graphical ISO from <https://nixos.org/download>,
write it to a USB stick (Rufus/Ventoy on Windows, or `dd` on Linux), boot it, and pick
the external SSD from the firmware boot menu.

### 2. Partition the external SSD (GPT + ESP + root)

```bash
# Confirm the target FIRST:
lsblk -o NAME,SIZE,MODEL,TRAN

# Partition /dev/sdX  (REPLACE sdX). Creates a 1GB EFI partition + rest as root.
sudo parted /dev/sdX -- mklabel gpt
sudo parted /dev/sdX -- mkpart ESP fat32 1MiB 1025MiB
sudo parted /dev/sdX -- set 1 esp on
sudo parted /dev/sdX -- mkpart root ext4 1025MiB 100%

# Format. (sdX1 = ESP, sdX2 = root)
sudo mkfs.fat -F32 -n BOOT /dev/sdX1
sudo mkfs.ext4 -L nixos /dev/sdX2
```

> Prefer **Btrfs** for free snapshots? Use `mkfs.btrfs -L nixos /dev/sdX2` instead and
> set `fsType = "btrfs"` in `hardware-configuration.nix`. (Btrfs subvolume layout is
> beyond this quick guide — ext4 is the simple, safe default.)

### 3. Mount

```bash
sudo mount /dev/sdX2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/sdX1 /mnt/boot
```

### 4. Generate hardware config, then drop in this repo

```bash
sudo nixos-generate-config --root /mnt
```

This writes **real UUIDs** for your SSD into `/mnt/etc/nixos/hardware-configuration.nix`.

Now put this repo's files in place:

```bash
# Get this repo onto the machine (git clone, USB copy, whatever).
# Then copy everything EXCEPT the placeholder hardware-configuration.nix:
sudo cp -r /path/to/this/repo/* /mnt/etc/nixos/

# CRITICAL: keep the GENERATED hardware-configuration.nix (it has the real UUIDs).
# Overwrite the repo's placeholder with the generated one:
sudo cp /mnt/etc/nixos/hardware-configuration.nix \
        /mnt/etc/nixos/hosts/nebula-ext/hardware-configuration.nix
```

Open `hosts/nebula-ext/hardware-configuration.nix` and confirm it has the
**USB initrd modules** block (the generated file may drop it — re-add from this repo's
version if so). Without `usb_storage`/`uas` in initrd, an external USB SSD won't be
found at boot.

### 5. Install

```bash
sudo nixos-install --flake /mnt/etc/nixos#nebula-ext
```

Set the root password when prompted. The `rob` user has `initialPassword = "changeme"`
— **change it immediately** after first login with `passwd`.

### 6. Reboot

```bash
reboot
```

Remove the USB stick, press the boot-menu key, choose the external SSD. You should land
in SDDM → Plasma 6 Wayland.

---

## After first boot

```bash
passwd                 # change your password NOW
nvidia-smi             # confirm the 4080 is recognized
echo $XDG_SESSION_TYPE # should print: wayland
```

Apply config changes any time by editing files in `/etc/nixos` and running:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nebula-ext
```

Roll back a bad change: **reboot → pick the previous generation in the GRUB menu.**
Or from a working session:

```bash
sudo nixos-rebuild switch --rollback
```

---

## Letting Claude maintain it (your plan)

This repo *is* your system. To let an agent manage it safely:

1. Keep `/etc/nixos` as a git repo (push to a private GitHub repo).
2. The agent edits files and runs `nixos-rebuild switch --flake ...`.
3. You review the git diff before each rebuild; if anything breaks, reboot to the last
   generation. Nothing is permanent until you're happy.

---

## File layout

```
flake.nix                              # inputs (nixpkgs 26.05, home-manager, plasma-manager) + host output
hosts/nebula-ext/
  configuration.nix                    # Windows-safe bootloader, user, audio, nix settings
  hardware-configuration.nix           # PLACEHOLDER — replace with nixos-generate-config output
modules/
  nvidia.nix                           # RTX 4080 open module, Wayland-safe
  gaming.nix                           # Steam/Proton/GameMode/MangoHud/Gamescope
  desktop.nix                          # KDE Plasma 6 Wayland + SDDM
home/rob.nix                           # user apps + plasma-manager ricing
```

## Things to personalize

- `configuration.nix`: `time.timeZone`, username (`rob` → yours — also rename in `flake.nix` and `home/`)
- `home/rob.nix`: apps, theme, cursor (`Bibata-Modern-Ice`), panel widgets
- `modules/nvidia.nix`: swap `.production` → `.beta` for newest driver if needed
