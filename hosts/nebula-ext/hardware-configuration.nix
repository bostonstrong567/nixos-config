{ config, lib, pkgs, modulesPath, ... }:

###############################################################################
# Hardware config — kernel modules + microcode + platform.
#
# NOTE: fileSystems.* and swapDevices are NOT defined here — they are generated
# by disko from modules/disko.nix. This avoids the "defined in two places"
# conflict. If you ever DROP disko and go manual, run:
#     sudo nixos-generate-config --root /mnt
# and paste its fileSystems block back in (and remove disko from flake.nix).
#
# Key external-SSD specifics:
#   * USB storage modules forced into initrd so the SSD is found at boot
###############################################################################

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Force USB + NVMe/SATA modules early so an external USB SSD enumerates in initrd.
  boot.initrd.availableKernelModules = [
    "xhci_pci" "usbhid" "usb_storage" "uas"   # USB / UASP enclosures
    "nvme" "ahci" "sd_mod"                       # NVMe / SATA bridges
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];            # Ryzen
  boot.extraModulePackages = [ ];

  # Ryzen 7 3800XT
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
