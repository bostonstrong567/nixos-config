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

  # Our Hyprland block owns its own colors (gruvbox hardcoded). Stylix's hyprland
  # target ALSO writes decoration.shadow.color etc. → "defined multiple times".
  # Disable it so our config is the single source for Hyprland styling.
  stylix.targets.hyprland.enable = false;

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

  # Media keys: Hyprland binds XF86Audio* keys to playerctl (see hyprland block).
  # cliamp publishes MPRIS, so once its daemon runs, Play/Pause/Next/Prev keys
  # control it. Force-target cliamp with: playerctl --player=cliamp play-pause

  # Polkit agent (GUI privilege prompts) — ships its own user service.
  services.hyprpolkitagent.enable = true;

  ###########################################################################
  # Hyprland — THE desktop, mouse-first (Plasma removed)
  ###########################################################################
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland 0.55 + HM stateVersion 26.05 defaults to a Lua config backend whose
    # translator mis-handles values like `e-1`, `5%-`, `mouse:272` (syntax errors).
    # Pin the stable native hyprlang (conf) backend — our settings translate cleanly.
    configType = "hyprlang";
    settings = {
      # ---- monitors (auto; tweak refresh per your display) ----
      monitor = ",preferred,auto,1";

      # ---- MOUSE-FIRST window management ----
      bindm = [
        "SUPER, mouse:272, movewindow"   # Super + LMB drag = move
        "SUPER, mouse:273, resizewindow" # Super + RMB drag = resize
      ];

      # Mouse-only workspace switching: scroll wheel over empty desktop area.
      bind = [
        "SUPER, Return, exec, ghostty"
        "SUPER, Q, killactive"
        "SUPER, E, exec, dolphin"
        "SUPER, R, exec, wofi --show drun"   # app launcher (mouse-driven)
        "SUPER, F, fullscreen"
        "SUPER, Space, togglefloating"
        "SUPER, P, pseudo"                   # pseudotile (moved to dispatcher in 0.55)
        "SUPER, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy" # clipboard history (mouse-pick)
        "SUPER, L, exec, hyprlock"
        "SUPER, X, exec, wlogout"            # power menu (mouse buttons)
        # workspace switch by number (also clickable on waybar)
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"  # region screenshot + annotate (mouse)
        # scroll wheel over desktop = switch workspace (pure mouse)
        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"
      ];

      # Media keys → playerctl (controls cliamp/Spotify/browsers via MPRIS)
      bindl = [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];

      # Gestures — Hyprland 0.51+ reworked syntax (`gesture = fingers, dir, action`).
      # Touchscreen + touchpad ready (works if you ever move to a touch device):
      #   3-finger horizontal swipe = switch workspace
      #   4-finger pinch            = toggle floating
      #   3-finger swipe up         = fullscreen
      gestures = {
        gesture = [
          "3, horizontal, workspace"
          "4, pinch, float"
          "3, up, fullscreen"
        ];
        workspace_swipe_invert = false;
      };

      # ---- THE SHOWPIECE LOOK ----
      general = {
        gaps_in = 6;
        gaps_out = 14;
        border_size = 2;
        "col.active_border" = "rgba(fe8019ff) rgba(d65d0eff) 45deg"; # gruvbox orange gradient
        "col.inactive_border" = "rgba(3c3836aa)";
        layout = "dwindle";
        resize_on_border = true;        # drag window edges with the mouse, no mod
        extend_border_grab_area = 15;   # fat invisible grab zone = easy edge-drag resize
        hover_icon_on_border = true;    # show resize cursor on hover
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
          color = lib.mkForce "rgba(1d2021ee)"; # override HM module's default shadow color
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
        # pseudotile is now a dispatcher (bound to SUPER+P above), not a config key.
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # ---- autostart: bar, widgets, animated wallpaper, notifications ----
      exec-once = [
        "waybar"
        "awww-daemon"
        # animated gruvbox wallpaper (swap path to your own video/gif/image):
        # "mpvpaper -o 'no-audio --loop' '*' ~/Videos/wallpaper.mp4"
        "dunst"
        "eww daemon && eww open hud"        # floating glass system-monitor HUD
        "wl-paste --watch cliphist store"  # clipboard history daemon
        "nm-applet --indicator"             # network tray icon
        "blueman-applet"                    # bluetooth tray icon
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

  ###########################################################################
  # eww — clean floating GLASS HUD widget (top-right): clock + system stats.
  # Gruvbox orange/black, rounded, semi-transparent. Pure eye-candy, no clicks
  # needed. Opened by `eww open hud` in exec-once below.
  ###########################################################################
  xdg.configFile."eww/eww.yuck".text = ''
    ;; ---- data pollers ----
    (defpoll TIME   :interval "5s"  "date '+%H:%M'")
    (defpoll DATE   :interval "60s" "date '+%a %d %b'")
    (defpoll CPU    :interval "2s"  "LC_ALL=C top -bn1 | awk '/Cpu/{printf \"%d\", 100-$8}'")
    (defpoll MEM    :interval "3s"  "free | awk '/Mem/{printf \"%d\", $3/$2*100}'")
    (defpoll DISK   :interval "30s" "df / | awk 'END{print $5}' | tr -d '%'")

    ;; ---- the HUD window ----
    (defwidget hud []
      (box :class "hud" :orientation "v" :space-evenly false :spacing 8
        (label :class "clock" :text TIME)
        (label :class "date"  :text DATE)
        (box :class "stats" :orientation "v" :space-evenly false :spacing 6
          (metric :name "CPU" :val CPU)
          (metric :name "RAM" :val MEM)
          (metric :name "DISK" :val DISK))))

    (defwidget metric [name val]
      (box :class "metric" :orientation "h" :space-evenly false :spacing 8
        (label :class "mname" :text name)
        (progress :class "mbar" :value val :orientation "h")
        (label :class "mval" :text "''${val}%")))

    (defwindow hud
      :monitor 0
      :geometry (geometry :x "18px" :y "52px" :anchor "top right"
                          :width "230px" :height "200px")
      :stacking "bg" :exclusive false :focusable false
      (hud))
  '';

  xdg.configFile."eww/eww.scss".text = ''
    * { all: unset; font-family: "JetBrainsMono Nerd Font"; }
    .hud {
      background-color: rgba(29,32,33,0.78);
      border: 2px solid #fe8019;
      border-radius: 16px;
      padding: 14px 16px;
    }
    .clock { color: #fe8019; font-size: 30px; font-weight: bold; }
    .date  { color: #ebdbb2; font-size: 13px; margin-bottom: 6px; }
    .metric { margin: 2px 0; }
    .mname { color: #fabd2f; font-size: 11px; min-width: 38px; }
    .mval  { color: #ebdbb2; font-size: 11px; min-width: 36px; }
    .mbar trough {
      background-color: rgba(60,56,54,0.8);
      border-radius: 8px; min-height: 8px; min-width: 90px;
    }
    .mbar progress {
      background-color: #fe8019; border-radius: 8px; min-height: 8px;
    }
  '';
}
