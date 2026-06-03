{ config, lib, pkgs, ... }:

###############################################################################
# Full hardware enablement — firmware, bluetooth, audio devices, peripherals.
#
# Your audio devices (from Windows inventory) and how they map on Linux:
#   * Focusrite Scarlett (USB)  → class-compliant USB audio, works on PipeWire,
#                                  ZERO driver needed. Full I/O + low latency.
#   * Fifine USB microphone     → class-compliant USB audio, works out of box.
#   * Realtek onboard audio     → snd_hda_intel kernel module, auto-loaded.
#   * NVIDIA HDMI/DP audio       → comes with nvidia driver (monitor speakers).
#   (NVIDIA Broadcast / FxSound / AudioRelay = Windows-only apps, N/A on Linux.
#    Equivalents: easyeffects RNNoise = NVIDIA-Broadcast-style mic denoise.)
###############################################################################

{
  ###########################################################################
  # Firmware — load everything redistributable (covers NIC, BT, GPU, etc.)
  ###########################################################################
  hardware.enableAllFirmware = true;            # needs allowUnfree (set in configuration.nix)
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;                  # firmware update daemon (UEFI/SSD/etc.)

  ###########################################################################
  # Bluetooth (most AM4 boards + add-in cards)
  ###########################################################################
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true; # battery reporting etc.
  };
  services.blueman.enable = true; # tray applet (works under Plasma too)

  ###########################################################################
  # Audio — PipeWire is configured in configuration.nix. Here: extra control
  # tools + low-latency niceties for the Focusrite/Fifine.
  ###########################################################################
  environment.systemPackages = with pkgs; [
    pavucontrol           # PulseAudio volume control (works w/ PipeWire)
    pwvucontrol           # native PipeWire mixer
    qpwgraph              # PipeWire patchbay, Qt (helvum removed; matches KDE; route Focusrite/mic)
    alsa-utils            # alsamixer, aplay, etc.
  ];

  ###########################################################################
  # Printing / scanning (enable if you have a printer; cheap to leave on)
  ###########################################################################
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ gutenprint hplip ];
  # Network printer auto-discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  ###########################################################################
  # Misc peripherals
  ###########################################################################
  hardware.keyboard.qmk.enable = true; # custom mech keyboards (harmless if none)
  services.hardware.openrgb.enable = true; # RGB control (mobo/RAM/GPU) — your call
}
