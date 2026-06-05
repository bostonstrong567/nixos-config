{ config, pkgs, lib, inputs, ... }:

###############################################################################
# Home Manager — user apps + ghostty + spicetify + the riced showpiece look.
###############################################################################

{
  home.username = "boston";
  home.homeDirectory = "/home/boston";
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
    # vscode configured declaratively below via programs.vscode

    # --- Launchers / gaming side-tools (Steam/Heroic/Lutris are system-level) ---
    prismlauncher        # Minecraft launcher

    # --- Media ---
    haruna               # Qt/KDE mpv video player (matches Plasma; > Celluloid here)
    oculante             # Rust GPU image viewer (> qimgv: modern, fast)

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
  # Stylix sets a Firefox profile name "default"; declare it so Stylix's firefox
  # target applies cleanly (silences the profileNames warning).
  stylix.targets.firefox.profileNames = [ "default" ];

  ###########################################################################
  # VSCode — declarative port of your customized Windows look
  # (Dracula Soft + Material Icons + FiraCode + minimal chrome).
  ###########################################################################
  # Let the Dracula theme win — don't let Stylix recolor VSCode.
  stylix.targets.vscode.enable = false;

  # On KDE, Plasma themes Qt itself; Stylix's qt target only supports 'qtct'
  # and warns under KDE. Disable it (Plasma + Stylix's KDE target cover Qt).
  stylix.targets.qt.enable = false;

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions =
        let
          ext = inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system}.vscode-marketplace;
        in
        [
          ext.dracula-theme.theme-dracula
          ext.pkief.material-icon-theme
          ext.gruntfuggly.activitusbar
        ];

      userSettings = {
        "window.zoomLevel" = 2;

        "workbench.colorTheme" = "Dracula Theme Soft";
        "workbench.iconTheme" = "material-icon-theme";
        "material-icon-theme.hidesExplorerArrows" = true;

        "workbench.tree.renderIndentGuides" = "none";
        "workbench.statusBar.visible" = true;
        "workbench.editor.showTabs" = "none";
        "workbench.startupEditor" = "none";
        "workbench.tips.enabled" = false;
        "workbench.layoutControl.enabled" = false;
        "workbench.navigationControl.enabled" = false;
        "workbench.editor.editorActionsLocation" = "hidden";
        "workbench.sideBar.location" = "right";
        "workbench.activityBar.location" = "top";

        "workbench.colorCustomizations" = {
          "editorSuggestWidget.selectedBackground" = "#231739";
          "sideBar.background" = "#191521";
          "list.activeSelectionBackground" = "#231739";
          "list.inactiveSelectionBackground" = "#231739";
          "list.focusBackground" = "#231739";
          "list.hoverBackground" = "#231739";
          "terminalCursor.foreground" = "#C45DFF";
        };

        "editor.fontFamily" = "FiraCode Nerd Font Mono";
        "editor.fontLigatures" = true;
        "editor.tabSize" = 4;
        "editor.detectIndentation" = false;

        "editor.minimap.enabled" = false;
        "editor.guides.indentation" = false;
        "editor.renderWhitespace" = "none";
        "editor.renderLineHighlight" = "none";
        "editor.matchBrackets" = "never";
        "editor.lightbulb.enabled" = "off";
        "editor.hover.enabled" = false;
        "editor.showFoldingControls" = "never";
        "editor.overviewRulerBorder" = false;
        "editor.cursorBlinking" = "solid";
        "editor.cursorSmoothCaretAnimation" = "off";
        "editor.semanticHighlighting.enabled" = false;
        "editor.stickyScroll.enabled" = false;
        "editor.smoothScrolling" = false;
        "editor.bracketPairColorization.enabled" = false;
        "editor.guides.bracketPairs" = false;
        "editor.wordWrap" = "on";

        "breadcrumbs.enabled" = false;
        "explorer.compactFolders" = false;

        "git.decorations.enabled" = false;
        "scm.diffDecorations" = "none";

        "terminal.integrated.fontFamily" = "FiraCode Nerd Font Mono";
        "terminal.integrated.lineHeight" = 1.5;
        "terminal.integrated.fontSize" = 12;
        "terminal.integrated.gpuAcceleration" = "on";
        "terminal.integrated.stickyScroll.enabled" = false;

        "window.titleBarStyle" = "custom";
        "window.menuStyle" = "native";
        "window.menuBarVisibility" = "compact";

        "activitusbar.views" = [
          { name = "command.workbench.action.files.openFolder"; codicon = "empty-window"; tooltip = "Open Project Folder"; }
          { name = "extensions"; codicon = "extensions-view-icon"; }
          { name = "explorer"; codicon = "layout-sidebar-right"; }
        ];
      };
    };
  };

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
      # Windows/PowerShell-style clipboard: Ctrl+C copies, Ctrl+V pastes.
      # (When text is selected, Ctrl+C copies; with nothing selected it still
      #  sends SIGINT to cancel a command — best of both, like Windows Terminal.)
      copy-on-select = true;
      keybind = [
        "ctrl+c=copy_to_clipboard"
        "ctrl+v=paste_from_clipboard"
        # Keep a way to send a real interrupt (Ctrl+C's old job):
        "ctrl+shift+c=text:\\x03"
      ];
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
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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

  ###########################################################################
  # Hyprland — mouse-first showpiece session (pick at login; Plasma stays default)
  ###########################################################################
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # ---- monitors (auto; tweak refresh per your display) ----
      monitor = ",preferred,auto,1";

      # ---- MOUSE-FIRST window management ----
      "$mod" = "SUPER";
      bindm = [
        "$mod, mouse:272, movewindow"   # Super + LMB drag = move
        "$mod, mouse:273, resizewindow" # Super + RMB drag = resize
      ];

      # Minimal keybinds (the rest is clickable via waybar/wofi)
      bind = [
        "$mod, Return, exec, ghostty"
        "$mod, Q, killactive"
        "$mod, E, exec, dolphin"
        "$mod, R, exec, wofi --show drun"   # app launcher (mouse-driven)
        "$mod, F, fullscreen"
        "$mod, Space, togglefloating"
        "$mod, L, exec, hyprlock"
        # workspace switch by number (also clickable on waybar)
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"  # region screenshot
      ];
      # scroll on workspaces with mouse over an empty area
      bind_ = [ ];

      # ---- THE SHOWPIECE LOOK ----
      general = {
        gaps_in = 6;
        gaps_out = 14;
        border_size = 2;
        "col.active_border" = "rgba(fe8019ff) rgba(d65d0eff) 45deg"; # gruvbox orange gradient
        "col.inactive_border" = "rgba(3c3836aa)";
        layout = "dwindle";
        resize_on_border = true;  # drag window edges with the mouse, no mod
      };

      decoration = {
        rounding = 14;
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          xray = true;          # blur sees through to wallpaper = glassy
          ignore_opacity = true;
        };
        shadow = {
          enabled = true;
          range = 30;
          render_power = 3;
          color = "rgba(1d2021ee)";
        };
        active_opacity = 0.95;
        inactive_opacity = 0.85;
      };

      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "overshot, 0.13, 0.99, 0.29, 1.1"
          "smoothOut, 0.36, 0, 0.66, -0.56"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, overshot, slide"
          "windowsOut, 1, 5, smoothOut, slide"
          "fade, 1, 10, default"
          "workspaces, 1, 6, overshot, slidevert"
          "border, 1, 10, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # ---- autostart: bar, widgets, animated wallpaper, notifications ----
      exec-once = [
        "waybar"
        "swww-daemon"
        # animated gruvbox wallpaper (swap path to your own video/gif/image):
        # "mpvpaper -o 'no-audio --loop' '*' ~/Videos/wallpaper.mp4"
        "dunst"
        "eww daemon"
      ];
    };
  };

  # Waybar — clickable status bar (workspaces, clock, audio, net, tray).
  # Stylix colors it gruvbox automatically. Click workspaces to switch; click
  # modules for menus — no keybinds needed.
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 34;
      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "cpu" "memory" "tray" ];
      "hyprland/workspaces" = {
        on-click = "activate";   # click to switch workspace
        format = "{icon}";
      };
      clock.format = "{:%a %d %b  %H:%M}";
      pulseaudio = {
        format = "{icon} {volume}%";
        format-icons.default = [ "" "" "" ];
        on-click = "pavucontrol";   # click opens mixer
      };
      network = {
        format-wifi = "  {essid}";
        format-ethernet = "  {ipaddr}";
        on-click = "nm-connection-editor";
      };
      cpu.format = " {usage}%";
      memory.format = " {}%";
    };
  };

  # Stylix themes waybar/wofi/dunst automatically (gruvbox) via its targets.
}
