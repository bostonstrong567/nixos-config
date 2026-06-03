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

        # >>> REPLACE THIS with the real by-id path of the SanDisk <<<
        device = "/dev/disk/by-id/usb-SanDisk_Extreme_REPLACE_ME";

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
