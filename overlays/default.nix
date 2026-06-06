# Custom packages not in nixpkgs, exposed as pkgs.<name> everywhere.
final: prev: {

  # (hyprbars fork removed — using stock nixpkgs hyprbars. Grabbing the bar
  #  drags from the window middle, which is the behavior the user wants back.)

  # hyprwinwrap — pin a window (glava audio-waves) as the desktop background.
  # Upstream DROPPED it from hyprland-plugins (commit 3aa21f2). We build the last
  # commit that still had it (22de29b, "winwrap: fix for 0.54.3") against our
  # Hyprland 0.55.2 via mkHyprlandPlugin. Close enough ABI; rebuilt if it breaks.
  hyprlandPlugins = prev.hyprlandPlugins // {
    hyprwinwrap =
      let
        pluginSrc = prev.fetchFromGitHub {
          owner = "hyprwm";
          repo = "hyprland-plugins";
          rev = "22de29bc1cf4126202df52691d0bc9a065089cba";
          hash = "sha256-hwtKSJcroZ++QAb9rI9L6Sp3XJlDIyWZN7UOVMiN8jY=";
        };
      in
      prev.hyprlandPlugins.mkHyprlandPlugin {
        pluginName = "hyprwinwrap";
        version = "0.54.3-unstable-2026";
        src = "${pluginSrc}/hyprwinwrap";
        nativeBuildInputs = [ prev.cmake ];
        unpackPhase = ''
          runHook preUnpack
          cp -r ${pluginSrc}/hyprwinwrap ./src
          chmod -R u+w ./src
          cd ./src
          runHook postUnpack
        '';
        meta.description = "Pin a window as the desktop background";
      };
  };

  # CLIAMP — terminal music player ("Winamp for shell"). Single Go binary.
  # Update: bump version + sha256 from https://github.com/bjarneo/cliamp/releases
  cliamp = prev.stdenv.mkDerivation rec {
    pname = "cliamp";
    version = "1.56.0";
    src = prev.fetchurl {
      url = "https://github.com/bjarneo/cliamp/releases/download/v${version}/cliamp-linux-amd64";
      sha256 = "3a3478b4cdae649cfb2b0de00ad20a5099a1c9c0d94062782e8f3e951572a01d";
    };
    dontUnpack = true;
    # The release is a generic-linux dynamically-linked binary. NixOS can't run
    # those as-is → autoPatchelfHook rewrites its interpreter/RPATH to the nix store.
    nativeBuildInputs = [ prev.autoPatchelfHook ];
    buildInputs = [ prev.stdenv.cc.cc.lib prev.zlib prev.alsa-lib ];
    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/cliamp
      runHook postInstall
    '';
    meta.mainProgram = "cliamp";
  };

  # opcode (winfunc) — Claude Code GUI. Wraps your native Claude sign-in (no API
  # key). AppImage-wrapped (reliable). Hash verified vs upstream's .sha256.
  #
  # NOTE on sudo: wrapType2 runs opcode in bubblewrap (PR_SET_NO_NEW_PRIVS), so
  # `sudo` is blocked INSIDE opcode's Claude. Workaround that DOES work: have
  # opcode's Claude run privileged commands over SSH to localhost —
  #   ssh boston@localhost 'sudo nixos-rebuild switch --flake ~/nixos-config#nebula-ext'
  # the ssh'd shell spawns OUTSIDE the sandbox, so passwordless sudo applies.
  # (Extracting the AppImage to escape bwrap made the Tauri/webkit app core-dump,
  #  so we keep the reliable sandbox + use the SSH escape hatch instead.)
  opcode = prev.appimageTools.wrapType2 {
    pname = "opcode";
    version = "0.2.0";
    src = prev.fetchurl {
      url = "https://github.com/winfunc/opcode/releases/download/v0.2.0/opcode_v0.2.0_linux_x86_64.AppImage";
      hash = "sha256-LsE9gweAOaru7J01r68V1aDblQ06t4qeCXp6mu1Ig3E=";
    };
  };

  # Windows_11_dark cursor — user's uploaded .cur/.ani set converted to XCursor
  # via win2xcur. CI builds this to verify the conversion works.
  win11-dark-cursors = prev.stdenv.mkDerivation {
    pname = "win11-dark-cursors";
    version = "1";
    src = ../stuff/Windows_11_dark.7z;
    nativeBuildInputs = [ prev.p7zip prev.win2xcur ];
    unpackPhase = ''
      runHook preUnpack
      7z x $src -o.
      runHook postUnpack
    '';
    buildPhase = ''
      runHook preBuild
      mkdir -p out
      win2xcur Windows_11_dark/*.cur Windows_11_dark/*.ani -o out/
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      THEME="$out/share/icons/Windows-11-dark"
      mkdir -p "$THEME/cursors"
      cp out/* "$THEME/cursors/"
      cat > "$THEME/index.theme" <<EOF
      [Icon Theme]
      Name=Windows-11-dark
      Comment=Windows 11 dark cursors (converted via win2xcur)
      EOF
      cd "$THEME/cursors"
      link() { [ -e "$2" ] && ln -sf "$2" "$1" || true; }
      link left_ptr pointer; link default pointer
      link text beam; link xterm beam
      link watch busy; link progress working
      link hand2 link; link pointer link
      link help help; link move move
      link size_ver vert; link size_hor horz
      link crosshair precision
      link not-allowed unavailable; link no-drop unavailable
      runHook postInstall
    '';
    meta.description = "Windows 11 dark cursor theme (converted to XCursor)";
  };
}
