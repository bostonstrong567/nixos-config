{ config, pkgs, lib, inputs, ... }:

###############################################################################
# Home Manager — user apps + ghostty + spicetify + the riced showpiece look.
###############################################################################

{
  home.username = "rob";
  home.homeDirectory = "/home/rob";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  ###########################################################################
  # User apps (mouse-driven, modern). Native nixpkgs unless noted.
  ###########################################################################
  home.packages = with pkgs; [
    # --- Web / chat ---
    vesktop              # Discord client w/ better Wayland screenshare+audio (> discord)
    # firefox configured below via programs.firefox

    # --- Dev ---
    vscode

    # --- Launchers / gaming side-tools (Steam/Heroic/Lutris are system-level) ---
    prismlauncher        # Minecraft launcher

    # --- Media ---
    haruna               # Qt/KDE mpv video player (matches Plasma; > Celluloid here)
    oculante             # Rust GPU image viewer (> qimgv: modern, fast)
    vlc

    # --- Utilities ---
    peazip               # archive manager
    flameshot            # screenshot tool
    fsearch              # instant file search (Everything-like; angrysearch not in nixpkgs)
    collector            # mijorus — file collection tray (also on Flathub)
    easyeffects          # PipeWire EQ + RNNoise mic denoise (> NoiseTorch on PipeWire)
    # stremio — plain `stremio` REMOVED from nixpkgs (qt5 webengine vuln) and the
    # replacement `stremio-linux-shell` currently has build issues (#503024).
    # Install via Flatpak instead (flatpak enabled in desktop.nix):
    #   flatpak install flathub com.stremio.Stremio
    # (Stremio-Glass-Theme applied manually after.)
    playerctl            # MPRIS control for media keys → cliamp/Spotify/browsers

    # --- Theming ---
    # (Kvantum intentionally omitted — breaks Stylix on Plasma 6, issue #835.
    #  Stylix's KDE target themes Qt instead. Colors/fonts/cursor come from
    #  modules/theme.nix, NOT set here, to avoid double-theming conflicts.)
    papirus-icon-theme
  ];

  ###########################################################################
  # Firefox
  ###########################################################################
  programs.firefox.enable = true;

  ###########################################################################
  # Ghostty — fast GPU terminal + animated custom cursor shaders
  ###########################################################################
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    # Colors/font/opacity come from Stylix (stylix.targets.ghostty). Only set
    # behavior + the cursor shader here to avoid fighting Stylix.
    settings = {
      background-blur-radius = 20;
      window-padding-x = 12;
      window-padding-y = 12;
      cursor-style = "block";
      mouse-hide-while-typing = true;
      # Animated cursor shader (file installed below). 'always' = keep animating.
      custom-shader = "${config.home.homeDirectory}/.config/ghostty/shaders/cursor_smear.glsl";
      custom-shader-animation = "always";
    };
  };

  # Pull sahaj-b/ghostty-cursor-shaders into place. Swap the file for any shader
  # from the repo (cursor_smear / cursor_blaze / ripple, etc.).
  # We vendor ONE shader inline so first boot has a working animated cursor with
  # no network fetch. Replace/extend by dropping more .glsl files in that dir.
  xdg.configFile."ghostty/shaders/cursor_smear.glsl".text = ''
    // Minimal animated cursor trail. Replace with a full shader from
    // https://github.com/sahaj-b/ghostty-cursor-shaders for fancier effects.
    void mainImage(out vec4 fragColor, in vec2 fragCoord) {
        vec2 uv = fragCoord / iResolution.xy;
        vec4 base = texture(iChannel0, uv);
        float d = distance(iCurrentCursor.xy / iResolution.xy, uv);
        float glow = smoothstep(0.05, 0.0, d) * (0.5 + 0.5 * sin(iTime * 6.0));
        fragColor = base + vec4(0.20, 0.60, 1.0, 0.0) * glow;
    }
  '';

  ###########################################################################
  # Shell — zsh + zoxide (smart cd) + fastfetch greeting
  ###########################################################################
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons";
      ll = "eza -la --icons";
      cat = "bat";
      cd = "z";        # zoxide
      rebuild = "nh os switch /etc/nixos";
    };
    initContent = "fastfetch";
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  ###########################################################################
  # Spicetify — patched/themed Spotify (replaces plain spotify pkg)
  ###########################################################################
  # NOTE: theme + colorScheme are driven by Stylix (stylix.targets.spicetify),
  # so we do NOT set them here — that caused a conflict (Stylix sets "stylix",
  # we were setting "text"). Only add extensions.
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        shuffle                                # true shuffle
        keyboardShortcut
      ];
    };

  ###########################################################################
  # KDE Plasma 6 ricing via plasma-manager — blur/transparency showpiece
  ###########################################################################
  programs.plasma = {
    enable = true;

    # NOTE: colorScheme / lookAndFeel are driven by Stylix (modules/theme.nix).
    # Here we only set icon theme + window-decoration + layout/behavior.
    workspace = {
      iconTheme = "Papirus-Dark";
      windowDecorations = {
        library = "org.kde.klassy";   # rounded, customizable (from theme.nix)
        theme = "Klassy";
      };
    };

    kwin = {
      effects = {
        blur.enable = true;
        translucency.enable = true;
        desktopSwitching.animation = "slide";
        wobblyWindows.enable = false;
      };
      virtualDesktops = {
        rows = 1;
        number = 4;
      };
    };

    panels = [
      {
        location = "bottom";
        height = 48;
        floating = true;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    configFile = {
      "kdeglobals"."KDE"."SingleClick" = false; # double-click (Windows-like)
      "kwinrc"."Windows"."FocusPolicy" = "ClickToFocus";
    };
  };

  # Media keys: Plasma's global shortcuts target the active MPRIS player out of
  # the box. cliamp publishes MPRIS, so once its daemon runs, Play/Pause/Next/
  # Prev keys + the panel media widget control it (playerctl is installed above).
  # Force-target cliamp with: playerctl --player=cliamp play-pause
}
