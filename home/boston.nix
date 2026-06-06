{ config, pkgs, lib, inputs, ... }:

###############################################################################
# Home Manager — user apps + ghostty + spicetify + the riced showpiece look.
###############################################################################

{
  home.username = "boston";
  home.homeDirectory = "/home/boston";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # Launcher (wofi) entries for apps that ship no .desktop file.
  xdg.desktopEntries = {
    opcode = {
      name = "opcode";
      comment = "Claude Code GUI (native sign-in, no API key)";
      exec = "opcode";
      terminal = false;
      categories = [ "Development" ];
    };
    cliamp = {
      name = "CLIAMP";
      comment = "Terminal music player";
      exec = "ghostty -e cliamp";
      terminal = false;
      categories = [ "AudioVideo" "Audio" ];
    };
  };

  # Fix "gtk-xft-dpi has invalid value (-1)" spam from GTK apps (ghostty etc.).
  # Set a real Xft DPI. 96 = standard 1x. Bump to 144 for 1.5x or 192 for 2x
  # scaling on the 4K panel if everything looks too small.
  xresources.properties = {
    "Xft.dpi" = 96;
  };

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
    # flameshot — home-manager service below (programs.flameshot), grim adapter.
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
      cursor-style-blink = false;   # no blinking cursor
      mouse-hide-while-typing = true;
      # (Removed the animated cursor shader — it drew the blinking blue trail.)
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

  # Flameshot — Wayland/Hyprland needs grim adapter + wlr support, else black
  # screenshot. enableWlrSupport builds it with the wlroots grabber.
  services.flameshot = {
    enable = true;
    package = pkgs.flameshot.override { enableWlrSupport = true; };
    settings.General = {
      useGrimAdapter = true;
      disabledGrimWarning = true;
      showStartupLaunchMessage = false;
    };
  };

  ###########################################################################
  # Hyprland — THE desktop, mouse-first (Plasma removed)
  ###########################################################################
  # Hyprland — NATIVE LUA config (Hyprland 0.55's modern format).
  #
  # We do NOT use HM's `settings` (its settings->Lua translator is broken,
  # issue #9341 — emits non-existent hl.animations()/hl.exec-once() calls).
  # Instead we hand-author correct Lua in hypr/hyprland.lua, validated against
  # this exact Hyprland's API stub (share/hypr/stubs/hl.meta.lua), and inject it
  # verbatim via configType=lua + extraConfig. settings left empty so HM writes
  # nothing broken; our extraConfig is appended raw to ~/.config/hypr/hyprland.lua.
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    extraConfig = builtins.readFile ../hypr/hyprland.lua;
    # hyprbars — clickable titlebars on every window. Grab the bar with the mouse
    # to MOVE (no Super needed), buttons to close/maximize. Keeps tiling.
    # nixpkgs build = ABI-matched to our Hyprland 0.55, no source flake.
    plugins = [
      pkgs.hyprlandPlugins.hyprbars
      # hyprwinwrap REMOVED — the 0.54.3 plugin crashed Hyprland at session start
      # on 0.55.2 (loaded fine live, but autoload-at-boot = ABI crash). Using a
      # safer bg method below instead (mpvpaper video wallpaper).
    ];
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
      # Clean minimal bar — no workspace pills/"1" container on the left (you
      # switch workspaces by mouse scroll over the desktop + gestures anyway).
      modules-left = [ ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "cpu" "memory" "tray" ];
      clock = {
        # 12-hour clock, Boston time (America/New_York = EST/EDT).
        timezone = "America/New_York";
        format = "{:%a %b %d  %I:%M %p}";       # e.g. "Fri Jun 06  11:42 PM"
        format-alt = "{:%I:%M %p}";
        tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
      };
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
    (defpoll TIME   :interval "5s"  "TZ='America/New_York' date '+%I:%M %p'")
    (defpoll DATE   :interval "60s" "TZ='America/New_York' date '+%a %d %b'")
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
