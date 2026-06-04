{ config, lib, pkgs, ... }:

###############################################################################
# NVIDIA RTX 4080 (Ada Lovelace) — Wayland-first, open kernel module.
#
# Ryzen 7 3800XT has NO integrated GPU → pure NVIDIA, single-GPU.
# No PRIME / offload config needed (that's only for laptops/iGPU hybrids).
###############################################################################

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit for Steam/Proton/Wine
  };

  hardware.nvidia = {
    # Open kernel module — NVIDIA's recommended default for Ada (40-series).
    open = true;

    # Required for Wayland; enables nvidia-drm.modeset=1.
    modesetting.enable = true;

    # nvidia-settings GUI control panel.
    nvidiaSettings = true;

    # Suspend/resume fix — preserves VRAM across sleep. Recommended for desktop.
    powerManagement.enable = true;
    powerManagement.finegrained = false; # finegrained is for laptop PRIME only

    # Driver branch. 'production' = most stable; switch to 'beta' for newest.
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # Coolbits — unlocks GPU fan curve + clock/power offset control so post-connect
  # overclocking is possible (via nvidia-settings / lact). 28 = fan + overclock +
  # overvolt bits. Tuning happens AFTER connect with real stability testing.
  # (nvidiaSettings already enabled in hardware.nvidia above.)
  services.xserver.deviceSection = ''
    Option "Coolbits" "28"
  '';

  # Explicit sync is the big Wayland-NVIDIA flicker/stutter fix (driver 555+).
  # It's on by default in current drivers; this env var is belt-and-suspenders
  # for apps that still misbehave.
  environment.sessionVariables = {
    # Hardware cursor can glitch on some NVIDIA+Wayland setups; uncomment if you
    # see cursor artifacts:
    # WLR_NO_HARDWARE_CURSORS = "1";
    NVD_BACKEND = "direct";       # VA-API via nvidia for video decode
    LIBVA_DRIVER_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = "1";     # allow G-Sync/VRR
  };
}
