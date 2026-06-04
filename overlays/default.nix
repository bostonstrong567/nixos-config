# Custom packages not in nixpkgs, exposed as pkgs.<name> everywhere.
final: prev: {

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
    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/cliamp
      runHook postInstall
    '';
    meta.mainProgram = "cliamp";
  };

  # opcode (winfunc) — Claude Code GUI. Wraps your native Claude sign-in (no API
  # key). AppImage-wrapped. Hash verified against upstream's published .sha256.
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
