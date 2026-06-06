{ config, lib, pkgs, ... }:

###############################################################################
# Full hardware enablement — firmware, bluetooth, audio devices, peripherals.
#
# MACHINE FACTS (confirmed by user):
#   * Mobo: X570 (no-WiFi variant) → WIRED Ethernet only. No wifi firmware
#     needed. NOTE: no-WiFi X570 boards also usually have NO onboard Bluetooth
#     (the WiFi/BT module is the same card). bluetooth.enable below is harmless
#     if absent; add a USB BT dongle later if you want it.
#   * Internal drives (Seagate 2TB + Samsung 860 EVO 1TB) belong to the WINDOWS
#     machine — NixOS NEVER touches them. We install ONLY to the external 1TB
#     SanDisk (pinned by-id in modules/disko.nix). Ethernet = online at boot.
#   * No Antlion mic. Mics in use: Fifine USB + Focusrite inputs.
#
# Audio devices and how they map on Linux:
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
    # (piper removed — it's for non-Logitech mice via ratbagd; your Logitech
    #  mouse is handled by Solaar, so piper found no device → "uh oh" error.)
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
  # Gaming peripherals — your actual devices
  ###########################################################################

  # Wooting keyboard — wootility GUI + udev rules (analog/rapid-trigger config).
  # (boston is in the 'input' group, set in configuration.nix, for device access.)
  hardware.wooting.enable = true;

  # Logitech mice/keyboards/receivers — Solaar + udev (manage without root).
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true; # Solaar GUI

  # ratbagd/piper removed — your Logitech mouse uses Solaar (above). ratbagd is
  # for non-Logitech gaming mice; with none present, piper just errored. Re-enable
  # services.ratbagd.enable + add piper if you ever get a Razer/SteelSeries/etc.

  ###########################################################################
  # Misc peripherals
  ###########################################################################
  hardware.keyboard.qmk.enable = true; # custom mech keyboards (harmless if none)
  services.hardware.openrgb.enable = true; # RGB control (mobo/RAM/GPU)
}
