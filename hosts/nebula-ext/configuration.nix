{ config, pkgs, lib, ... }:

{
  ###########################################################################
  # External-SSD / Windows-safe bootloader
  #
  # GOAL: NixOS lives entirely on the external SSD. Pulling the SSD leaves
  # the Windows machine 100% untouched — no NVRAM boot entries written,
  # bootloader installed in the *removable* fallback path on the SSD's own
  # ESP. You boot NixOS by picking the USB/external disk in the firmware
  # boot menu (F12 / F11 / etc.), NOT from a Windows-side menu entry.
  ###########################################################################
  boot.loader = {
    efi.canTouchEfiVariables = false; # <-- CRITICAL: never write to the PC's NVRAM
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true; # writes to /EFI/BOOT/BOOTX64.EFI on the SSD's ESP
      useOSProber = false;          # don't scan/alter the internal Windows disk
      configurationLimit = 20;      # keep 20 bootable generations in the menu
    };
    timeout = 5;
  };

  # The ESP on the EXTERNAL SSD. Confirm the real device in hardware-configuration.nix.
  # (mountpoint declared in hardware-configuration.nix — kept here as a reminder)

  networking.hostName = "nebula-ext";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York"; # adjust if needed
  i18n.defaultLocale = "en_US.UTF-8";

  # Keyboard / console
  console.keyMap = "us";

  ###########################################################################
  # User
  ###########################################################################
  users.users.rob = {
    isNormalUser = true;
    description = "Rob";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "gamemode" ];
    shell = pkgs.zsh;
    # Set a password after first boot with `passwd`, or use initialPassword below
    initialPassword = "changeme"; # CHANGE IMMEDIATELY after first login
  };
  programs.zsh.enable = true;

  # Passwordless-ish sudo for wheel (still prompts for password by default)
  security.sudo.wheelNeedsPassword = true;

  ###########################################################################
  # Nix settings — flakes + helpful defaults
  ###########################################################################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nixpkgs.config.allowUnfree = true; # NVIDIA, Steam, etc.

  ###########################################################################
  # Audio — PipeWire (modern, low-latency, gaming-friendly)
  ###########################################################################
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  ###########################################################################
  # Core system packages (desktop apps live in home/rob.nix)
  ###########################################################################
  environment.systemPackages = with pkgs; [
    git vim wget curl
    htop btop
    pciutils usbutils
    nvtopPackages.nvidia # GPU monitor
    ntfs3g                # read Windows NTFS drives if you want to mount them
  ];

  # SSD over USB can be slow to enumerate; give it room at boot.
  boot.initrd.systemd.enable = true;

  # Firmware (NVIDIA, etc.)
  hardware.enableRedistributableFirmware = true;

  # Trim for the SSD
  services.fstrim.enable = true;

  system.stateVersion = "26.05";
}
