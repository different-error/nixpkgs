{
  callPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  symlinkJoin,
}:
let
  version = "5.2.0-pepper";
  rev = "8648697788c18fa5f8da8f9d3c8936bfd0ff2704";

  common = {
    inherit version;

    src = fetchFromGitHub {
      owner = "different-error";
      repo = "nordvpn-linux";
      inherit rev;
      hash = "sha256-gH6Zxt/DduY4xyh6hP2mrrNNCCxCWcJG/xZytFXZfuA=";
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

  strictDeps = true;
  __structuredAttrs = true;

  paths = [
    (callPackage ./cli.nix common)
    (callPackage ./gui.nix common)
  ];

  passthru = {
    cli = callPackage ./cli.nix common;
    gui = callPackage ./gui.nix common;
    updateScript = nix-update-script { };
  };

  meta = common.meta // {
    description = "NordVPN client and GUI for Linux";
    longDescription = ''
      NordVPN CLI and GUI applications for Linux.
      This package currently does not support meshnet.
      Additionally, if `networking.firewall.enable = true;`,
      then also set `networking.firewall.checkReversePath = "loose";`.
      The closed-source nordwhisper protocol is also not supported.
    '';
  };
}
