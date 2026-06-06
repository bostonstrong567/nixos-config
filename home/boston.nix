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
      icon = "multimedia-player";   # media icon (was blank in walker)
      terminal = false;
      categories = [ "AudioVideo" "Audio" ];
    };
    glava = {
      name = "GLava";
      comment = "OpenGL audio spectrum visualizer";
      exec = "env DISPLAY=:0 glava";   # needs XWayland DISPLAY or it crashes
      icon = "multimedia-volume-control";
      terminal = false;
      categories = [ "AudioVideo" "Audio" ];
    };
  };

  # Hide junk .desktop entries from walker (apps you'll never click; shipped by
  # transitively-pulled packages). NoDisplay hides them from the launcher.
  xdg.dataFile = lib.genAttrs [
    "applications/gvim.desktop"
    "applications/vim.desktop"
    "applications/nvim.desktop"
    "applications/cmake-gui.desktop"
    "applications/avahi-discover.desktop"
    "applications/bssh.desktop"
    "applications/bvnc.desktop"
    "applications/qv4l2.desktop"
    "applications/qvidcap.desktop"
    "applications/nixos-manual.desktop"
    "applications/org.freedesktop.IBus.Setup.desktop"
  ] (_: { text = ''
    [Desktop Entry]
    Type=Application
    NoDisplay=true
  ''; });

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
    easyeffects          # PipeWire EQ + RNNoise mic denoise (> NoiseTorch on PipeWire)
    cava                 # terminal audio spectrum (the sound-wave look)
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
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # enable userChrome
        "browser.uidensity" = 1;                  # compact toolbar (Zabooby vibe)
        "browser.tabs.drawInTitlebar" = true;
        "svg.context-properties.content.enabled" = true;
        "browser.newtabpage.activity-stream.feeds.topsites" = true;
        "browser.compactmode.show" = true;
      };
      # Gruvbox userChrome — colors only, minimal. Don't fight the native layout
      # (the aggressive version jammed tabs to the edge + doubled the titlebar).
      userChrome = ''
        :root {
          --gb-bg: #1d2021; --gb-bg2: #282828; --gb-fg: #ebdbb2;
          --gb-accent: #fe8019; --gb-dim: #3c3836;
        }
        /* gruvbox colors on toolbar/tabs — keep default spacing/layout */
        #navigator-toolbox { background: var(--gb-bg) !important; }
        #nav-bar, #PersonalToolbar { background: var(--gb-bg) !important; }
        #TabsToolbar { background: var(--gb-bg) !important; }
        /* breathing room: tabs start with a left gap, not jammed to the edge */
        #tabbrowser-tabs { padding-inline-start: 8px !important; }
        .tabbrowser-tab[selected] .tab-background {
          background: var(--gb-dim) !important;
          box-shadow: inset 0 -2px 0 var(--gb-accent) !important;
        }
        .tab-label { color: var(--gb-fg) !important; }
        #urlbar { background: var(--gb-bg2) !important; border: 1px solid var(--gb-dim) !important; }
        #urlbar[focused] { border-color: var(--gb-accent) !important; }
        #urlbar-input { color: var(--gb-fg) !important; }
        toolbarbutton { color: var(--gb-fg) !important; }
        /* hide Firefox's own window-control buttons (min/max/X) — hyprbars
           provides the window controls, so Firefox's are redundant. */
        .titlebar-buttonbox-container,
        .titlebar-min, .titlebar-max, .titlebar-restore, .titlebar-close {
          display: none !important;
        }
      '';
      userContent = ''
        /* gruvbox the new-tab + about: pages background */
        @-moz-document url("about:home"), url("about:newtab"), url("about:blank") {
          body, html { background: #1d2021 !important; }
        }
      '';
    };
  };
  # Stylix firefox target colors the content (silences profileNames warning).
  stylix.targets.firefox.profileNames = [ "default" ];

  ###########################################################################
  # Walker — modern Wayland app launcher (replaces wofi). Gruvbox themed.
  # Runs as a service (elephant backend auto-managed) for instant open.
  # SUPER+R launches it (hypr/hyprland.lua).
  ###########################################################################
  programs.walker = {
    enable = true;
    runAsService = true;
    config = {
      close_when_open = true;
      click_to_close = true;
      single_click_activation = true;
      theme = "gruvbox";
    };
    themes.gruvbox.style = ''
      /* Gruvbox dark-hard palette */
      @define-color window_bg_color #1d2021;
      @define-color accent_bg_color #fe8019;
      @define-color theme_fg_color  #ebdbb2;
      @define-color error_bg_color  #fb4934;
      @define-color error_fg_color  #1d2021;

      * { all: unset; font-family: "JetBrainsMono Nerd Font"; font-size: 14px; }

      .box-wrapper {
        background: alpha(@window_bg_color, 0.92);
        padding: 18px;
        border-radius: 18px;
        border: 2px solid @accent_bg_color;
        box-shadow: 0 18px 50px rgba(0,0,0,0.45);
      }
      .search-container {
        background: alpha(#3c3836, 0.6);
        border-radius: 12px;
        padding: 10px 14px;
        margin-bottom: 12px;
        border: 1px solid alpha(@accent_bg_color, 0.5);
      }
      .input { color: @theme_fg_color; font-size: 16px; }
      .input placeholder { color: alpha(@theme_fg_color, 0.45); }
      scrollbar { opacity: 0; }
      .normal-icons { -gtk-icon-size: 20px; }
      .large-icons  { -gtk-icon-size: 36px; }
      child {
        padding: 8px 12px;
        border-radius: 10px;
        color: @theme_fg_color;
      }
      child:selected, child:hover {
        background: alpha(@accent_bg_color, 0.22);
        color: #fe8019;
      }
      .item-text .title { color: @theme_fg_color; font-weight: bold; }
      .item-text .description { color: alpha(@theme_fg_color, 0.6); font-size: 12px; }
    '';
  };

  ###########################################################################
  # Vesktop (Discord) — gruvbox QuickCSS. Enables custom CSS + writes a gruvbox
  # palette that recolors the whole client to match the system.
  ###########################################################################
  xdg.configFile."vesktop/settings/quickCss.css".text = ''
    /* Gruvbox dark-hard for Discord/Vesktop */
    :root {
      --background-primary: #1d2021;
      --background-secondary: #282828;
      --background-secondary-alt: #32302f;
      --background-tertiary: #1b1b1b;
      --background-accent: #3c3836;
      --background-floating: #1d2021;
      --channeltextarea-background: #282828;
      --text-normal: #ebdbb2;
      --text-muted: #a89984;
      --header-primary: #fbf1c7;
      --header-secondary: #d5c4a1;
      --interactive-normal: #d5c4a1;
      --interactive-hover: #fe8019;
      --interactive-active: #fe8019;
      --brand-experiment: #fe8019;
      --brand-experiment-560: #d65d0e;
      --button-background: #fe8019;
      --link: #83a598;
      --mention-foreground: #fe8019;
    }
    .theme-dark {
      --background-primary: #1d2021;
      --background-secondary: #282828;
      --background-tertiary: #1b1b1b;
    }
    /* accent the selected channel + send button gruvbox-orange */
    [class*="selected"] [class*="link"] { background: alpha(#fe8019, 0.15) !important; }
  '';

  # Enable QuickCSS in vesktop's settings WITHOUT clobbering the rest (account,
  # prefs live there too). Flip useQuickCss=true in place via jq, only if needed.
  home.activation.vesktopQuickCss = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    vf="${config.home.homeDirectory}/.config/vesktop/settings/settings.json"
    if [ -f "$vf" ]; then
      run ${pkgs.jq}/bin/jq '.useQuickCss = true' "$vf" > "$vf.tmp" && run mv "$vf.tmp" "$vf"
    fi
  '';

  ###########################################################################
  # VSCode — declarative port of your customized Windows look
  # (Dracula Soft + Material Icons + FiraCode + minimal chrome).
  ###########################################################################
  # Let the Dracula theme win — don't let Stylix recolor VSCode.
  stylix.targets.vscode.enable = false;

  # On KDE, Plasma themes Qt itself; Stylix's qt target only supports 'qtct'
  # and warns under KDE. Disable it (Plasma + Stylix's KDE target cover Qt).
  # Qt theming RE-ENABLED — Plasma is gone, so Stylix's qt target now drives
  # Qt/KDE apps (dolphin, ark, haruna) to gruvbox via qtct. Was disabled only
  # because Plasma used to own Qt; nothing owns it now → let Stylix theme it.
  stylix.targets.qt.enable = true;

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

      # NOTE: userSettings intentionally NOT set here — HM writes it as a
      # READ-ONLY store symlink, so VSCode's GUI "Save settings" fails with EROFS.
      # We seed the same settings as a WRITABLE file via home.activation below,
      # so you can edit settings in the VSCode UI freely.
    };
  };

  # Seed VSCode settings.json as a writable file (only if missing), so the GUI
  # can edit it. Mirrors the old declarative defaults. Delete the file + rebuild
  # to reset to these defaults.
  home.activation.seedVscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    vsdir="${config.home.homeDirectory}/.config/Code/User"
    vsfile="$vsdir/settings.json"
    if [ ! -e "$vsfile" ]; then
      run mkdir -p "$vsdir"
      run cp ${pkgs.writeText "vscode-settings.json" (builtins.toJSON {
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
      })} "$vsfile"
      run chmod u+w "$vsfile"
    fi
  '';

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
      # Workspace pills as CUSTOM clickable buttons. The normal hyprland/workspaces
      # module's click ("activate") sends legacy IPC dispatch, which Hyprland's
      # Lua-config mode REJECTS (waybar #5008) → clicks did nothing. These custom
      # buttons call the working `hl.dispatch(hl.dsp.focus{...})` eval instead.
      modules-left = [ "custom/ws1" "custom/ws2" "custom/ws3" "custom/ws4" "cava" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "cpu" "memory" "tray" ];
      # Sound-wave spectrum in the bar (Sly-Harvey look), gruvbox via stylix.
      # Higher sensitivity + more bars + faster frames = more reactive to sound.
      cava = {
        framerate = 60;
        bars = 16;
        sensitivity = 130;     # higher = more reactive to quiet sound
        lower_cutoff_freq = 30;
        higher_cutoff_freq = 18000;
        method = "pulse";
        bar_delimiter = 0;
        format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
        actions.on-click-right = "mode";
      };
      # Each pill = a script that prints {text,class}. class="active" when you're
      # on that workspace → CSS fills it in to show the toggled area. Home=ws1.
      "custom/ws1" = {
        exec = "${pkgs.writeShellScript "ws1" ''
          a=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r .id)
          if [ "$a" = "1" ]; then echo '{"text":"Home","class":"active"}'; else echo '{"text":"Home","class":"inactive"}'; fi
        ''}";
        return-type = "json";
        interval = 1;
        on-click = "hyprctl eval 'hl.dispatch(hl.dsp.focus({workspace=1}))'";
        tooltip = false;
      };
      "custom/ws2" = {
        exec = "${pkgs.writeShellScript "ws2" ''
          a=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r .id)
          if [ "$a" = "2" ]; then echo '{"text":"Music","class":"active"}'; else echo '{"text":"Music","class":"inactive"}'; fi
        ''}";
        return-type = "json";
        interval = 1;
        on-click = "hyprctl eval 'hl.dispatch(hl.dsp.focus({workspace=2}))'";
        tooltip = false;
      };
      "custom/ws3" = {
        exec = "${pkgs.writeShellScript "ws3" ''
          a=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r .id)
          if [ "$a" = "3" ]; then echo '{"text":"Chat","class":"active"}'; else echo '{"text":"Chat","class":"inactive"}'; fi
        ''}";
        return-type = "json";
        interval = 1;
        on-click = "hyprctl eval 'hl.dispatch(hl.dsp.focus({workspace=3}))'";
        tooltip = false;
      };
      "custom/ws4" = {
        exec = "${pkgs.writeShellScript "ws4" ''
          a=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r .id)
          if [ "$a" = "4" ]; then echo '{"text":"Coding","class":"active"}'; else echo '{"text":"Coding","class":"inactive"}'; fi
        ''}";
        return-type = "json";
        interval = 1;
        on-click = "hyprctl eval 'hl.dispatch(hl.dsp.focus({workspace=4}))'";
        tooltip = false;
      };
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

    # Modern Sly-Harvey-style waybar — floating gruvbox pills, glow, rounded.
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 12px;
        min-height: 0;
      }
      window#waybar {
        background: transparent;
      }
      /* floating pill container per module group */
      .modules-left, .modules-center, .modules-right {
        background: alpha(#1d2021, 0.85);
        border-radius: 14px;
        border: 1px solid alpha(#fe8019, 0.35);
        margin: 6px 8px;
        padding: 2px 8px;
      }
      #custom-ws1, #custom-ws2, #custom-ws3, #custom-ws4 {
        padding: 0 14px; margin: 3px 2px;
        border-radius: 10px;
        color: #a89984;
        background: transparent;
        transition: all 0.25s ease;
      }
      #custom-ws1:hover, #custom-ws2:hover, #custom-ws3:hover, #custom-ws4:hover {
        background: alpha(#fe8019, 0.18); color: #fe8019;
      }
      /* ACTIVE pill = filled gruvbox-orange, dark text — shows the toggled area */
      #custom-ws1.active, #custom-ws2.active, #custom-ws3.active, #custom-ws4.active {
        background: #fe8019;
        color: #1d2021;
        font-weight: bold;
        box-shadow: 0 0 10px alpha(#fe8019, 0.5);
      }
      #clock { color: #fe8019; font-weight: bold; padding: 0 10px; }
      #cava  { color: #b8bb26; padding: 0 8px; }
      #pulseaudio { color: #fabd2f; padding: 0 8px; }
      #network    { color: #83a598; padding: 0 8px; }
      #cpu        { color: #8ec07c; padding: 0 8px; }
      #memory     { color: #d3869b; padding: 0 8px; }
      #tray       { padding: 0 8px; }
      tooltip {
        background: #1d2021; border: 1px solid #fe8019; border-radius: 10px;
      }
      tooltip label { color: #ebdbb2; }
    '';
  };

  # Stylix themes waybar/wofi/dunst automatically (gruvbox) via its targets.

  # fsearch DB builder — fsearch 0.2.3's CLI --update-database fails headless;
  # it needs a running GTK/graphical session. This user service builds the index
  # shortly after graphical login (where it works), so search has data on first
  # open. fsearch GUI also re-indexes on launch (update_database_on_launch=true).
  systemd.user.services.fsearch-index = {
    Unit = {
      Description = "Build fsearch database after login";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      # Small delay so the session/dbus is fully up, then build the DB.
      ExecStart = "${pkgs.bash}/bin/bash -lc 'sleep 8; ${pkgs.fsearch}/bin/fsearch --update-database || true'";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

}
