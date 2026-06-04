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
}
