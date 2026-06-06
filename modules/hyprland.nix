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
    __GL_GSYNC_ALLOWED = "1";       # explicit-sync edge cases
    # Prefer server-side decorations so hyprbars titlebars show instead of each
    # app drawing its own. GTK/libadwaita apps honor this; Chromium/Electron too.
    GTK_CSD = "0";
    # If you ever see cursor flicker on Hyprland+NVIDIA, uncomment:
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Showpiece toolset (system-wide so the session always has them).
  environment.systemPackages = with pkgs; [
    waybar          # status bar (CSS-styled, clickable)
    # wofi removed — replaced by walker (programs.walker in home/boston.nix)
    dunst           # notifications
    awww            # animated wallpaper daemon (swww renamed → awww)
    mpvpaper        # video wallpaper (galaxy/matrix loop behind desktop)
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
    # removed: rofi (wofi covers it), hyprpaper (awww covers wallpaper),
    # nwg-look + nwg-displays (Stylix themes; Hyprland handles displays)
  ];

  # XDG portal for screenshare/file dialogs under Hyprland.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
