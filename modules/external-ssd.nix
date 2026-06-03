{ config, lib, pkgs, ... }:

###############################################################################
# External-SSD-as-root hardening.
# SanDisk Extreme Portable (USB 3.2 Gen2, UASP) running as the main OS disk.
#
# Goal: kill the failure modes of USB-attached root —
#   1. USB autosuspend putting the root drive to sleep -> stall/corruption
#   2. Silent bit-flips over the USB bridge (Btrfs checksums catch them)
#   3. Aggressive writeback losing data on a surprise disconnect
###############################################################################

{
  # ---- 1. Never autosuspend USB storage --------------------------------------
  # Kernel-level: disable USB autosuspend globally (simplest, safe on a desktop).
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  # udev belt-and-suspenders: force the SanDisk bridge to stay 'on'.
  # (VID 0781 = SanDisk. Matches the Extreme Portable bridge.)
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0781", TEST=="power/control", ATTR{power/control}="on"
    # Ensure UASP-capable scheduler on the external SSD (mq-deadline is good for flash)
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
  '';

  # ---- 2. Filesystem robustness ---------------------------------------------
  # If you chose Btrfs (recommended for USB root): periodic scrub catches/repairs
  # checksum errors from bridge bit-flips. Harmless if you used ext4 (unit just
  # won't find a btrfs mount).
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  # ---- 3. Survive a surprise unplug a bit better ----------------------------
  # Flush dirty pages more eagerly so a yanked cable loses less. Slightly more
  # write traffic, worth it on a removable root disk.
  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 500;   # flush every 5s (default 30s)
    "vm.dirty_expire_centisecs" = 1000;     # data 'old' after 10s
  };

  # Trim works over UASP for the SanDisk; weekly is plenty.
  services.fstrim.enable = lib.mkDefault true;
}
