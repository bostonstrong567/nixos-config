{ config, lib, pkgs, ... }:

###############################################################################
# Hyprland — THE desktop (Plasma removed). Configured MOUSE-FIRST:
#   * Super + left-drag  = move window
#   * Super + right-drag = resize window
#   * drag any window EDGE = resize (resize_on_border, no key)
#   * waybar / wofi / wlogout = clickable (no keybinds to launch/switch/power)
# Only daily key = SUPER (for drag). Everything else clicks.
#
# Visuals: full blur, rounded corners, animations, animated wallpaper, eww
# glass widgets. Colors come from Stylix (gruvbox) like everything else.
###############################################################################

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;       # modern session manager (recommended)
    xwayland.enable = true; # run X11 apps (Steam games etc.) under Hyprland
  };

  # NVIDIA + Hyprland environment (4080, Wayland-safe).
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";           # Electron/Chromium apps go Wayland
    # Explicit-sync is default in current drivers; these help edge cases:
    __GL_GSYNC_ALLOWED = "1";
    # If you ever see cursor flicker on Hyprland+NVIDIA, uncomment:
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Showpiece toolset (system-wide so the session always has them).
  environment.systemPackages = with pkgs; [
    waybar          # status bar (CSS-styled, clickable)
    eww             # widgets (glass HUD tiles)
    wofi            # mouse-driven app launcher
    rofi            # alt launcher (rofi-wayland merged into rofi)
    dunst           # notifications
    swww            # animated wallpaper daemon (GPU transitions)
    mpvpaper        # video wallpaper (galaxy/matrix loop behind desktop)
    hyprpaper       # simple static wallpaper fallback
    hyprlock        # lockscreen (blurred, themed)
    hypridle        # idle daemon
    hyprpicker      # color picker (mouse eyedropper)
    hyprsunset      # blue-light / night-light filter (2026 Hypr-ecosystem tool)
    hyprcursor      # modern scalable cursor format support
    wl-clipboard    # clipboard
    cliphist        # clipboard history (mouse-pick via wofi)
    grim slurp      # screenshots (region select w/ mouse)
    swappy          # annotate screenshots (mouse)
    brightnessctl   # brightness keys
    pavucontrol     # click volume control
    networkmanagerapplet # click wifi menu
    wlogout         # mouse-driven power menu (logout/reboot/shutdown buttons)
    nwg-look        # GTK theme settings GUI (mouse)
    nwg-displays    # monitor arrangement GUI (mouse drag displays)
  ];

  # XDG portal for screenshare/file dialogs under Hyprland.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
