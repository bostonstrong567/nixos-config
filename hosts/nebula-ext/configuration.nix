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
  users.users.boston = {
    isNormalUser = true;
    description = "Boston";
    extraGroups = [
      "wheel" "networkmanager" "video" "audio" "gamemode"
      "input"   # Wooting / HID device udev access
      "i2c"     # OpenRGB / DDC monitor control
      "dialout" # serial devices
      "plugdev" # Solaar/Logitech hidraw read-write (fixes "can't read/write")
    ];
    shell = pkgs.zsh;
    # Hashed password for "1005" (sha-512). Plaintext is NOT stored in the nix
    # store this way. Change anytime with `passwd`. Regenerate with:
    #   mkpasswd -m sha-512 'yourpassword'
    initialHashedPassword = "$6$cZ3tAg6xOxBXnZvC$BR8PGygpCh9sOUz4earNyJH.NLGp6NCeUPb.6OpjNBX1pdYOd0F8y9lakOUCTkQgHEoI/zw83FbkLfQyEqDPF/";
  };
  programs.zsh.enable = true;

  # Passwordless sudo for wheel — boston owns this machine; the PC IS the sandbox.
  # Lets opcode/claude (and you) run sudo without a password prompt.
  security.sudo.wheelNeedsPassword = false;

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

  # Binary caches → fast installs (no compiling stylix/nix-community pkgs locally)
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  ###########################################################################
  # Performance — desktop/gaming tuned
  ###########################################################################
  # Zen kernel — lower latency, better gaming responsiveness.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Max-performance CPU governor (desktop, always plugged in).
  powerManagement.cpuFreqGovernor = "performance";

  # zram — compressed RAM swap. With 32GB this keeps things snappy under load
  # and avoids touching the (USB) disk for swap.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

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
  # Core system packages (desktop apps live in home/boston.nix)
  ###########################################################################
  environment.systemPackages = with pkgs; [
    git vim wget curl
    htop btop
    pciutils usbutils
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
