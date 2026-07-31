{
  callPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  symlinkJoin,
}:
let
  version = "5.3.0-meshnet-pepper";
  rev = "380a440ddee638ad1b0783d36b077f07aaa7f907";

  common = {
    inherit version;

    src = fetchFromGitHub {
      owner = "different-error";
      repo = "nordvpn-linux";
      inherit rev;
      hash = "sha256-YURjHMjBpxQIJpT3xC4AhyMKcgvKQKLTtQYm7kApGbk=";
    };

    # rec so that changelog can reference homepage
    meta = rec {
      homepage = "https://github.com/different-error/nordvpn-linux";
      changelog = "${homepage}/commit/${rev}";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ different-error ];
      platforms = lib.platforms.linux;
    };

    desktopItemArgs = {
      categories = [ "Network" ];
      genericName = "VPN Client";
      icon = "nordvpn";
      type = "Application";
    };
  };
in
symlinkJoin {
  pname = "nordvpn";
  inherit version;
  inherit (common) src;

  strictDeps = true;
  __structuredAttrs = true;

  paths = [
    (callPackage ./cli.nix common)
    (callPackage ./gui.nix common)
  ];

  passthru = {
    cli = callPackage ./cli.nix common;
    gui = callPackage ./gui.nix common;
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "cli"
        "--subpackage"
        "gui"
      ];
    };
  };

  meta = common.meta // {
    description = "NordVPN client and GUI for Linux";
    longDescription = ''
      NordVPN CLI and GUI applications for Linux.
      This package does not support the closed-source nordwhisper protocol.
    '';
  };
}
