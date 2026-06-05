{ config, lib, ... }:

###############################################################################
# Declarative disk partitioning for the EXTERNAL SanDisk SSD (disko).
#
# Used by nixos-anywhere for remote install, and optionally for manual installs.
# This REPLACES hand-partitioning: disko wipes + formats the target per this spec.
#
#  ⚠️  SAFETY: the target disk is pinned by /dev/disk/by-id/ below. You MUST set
#      it to the SanDisk's real by-id path so disko can NEVER touch the internal
#      Windows NVMe. Find it on the live system with:
#
#          ls -l /dev/disk/by-id/ | grep -i sandisk
#
#      It'll look like: usb-SanDisk_Extreme_55AED... → copy that whole name.
#
#  Layout: GPT · 1GB ESP (FAT32) · rest = ext4 root.
#  (Swap to btrfs by changing the root content block — see README snapshot note.)
###############################################################################

{
  disko.devices = {
    disk = {
      sandisk = {
        type = "disk";

        # SanDisk Extreme Portable SSD 1TB — Model SDSSDE61-1T00, S/N 25167F40S552.
        # USB by-id usually embeds the serial. Claude VERIFIES this live with
        # `ls -l /dev/disk/by-id/ | grep -i sandisk` before any wipe (the real
        # path may have a trailing -0:0 or differ slightly by enclosure).
        device = "/dev/disk/by-id/usb-SanDisk_Extreme_25167F40S552-0:0";

        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
            root = {
              priority = 2;
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
