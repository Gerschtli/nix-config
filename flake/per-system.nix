{ inputs, rootPath, system }:

let
  config = {
    allowAliases = false;
    allowUnfree = true;
  };

  unstable = import inputs.unstable {
    inherit config system;
  };

  gerschtliOverlays = [
    inputs.dmenu.overlays.default
    inputs.dwm.overlays.default
    inputs.dwm-status.overlays.default
    inputs.teamspeak-update-notifier.overlays.default
  ];

  overlays = [
    (final: prev: {
      inherit (inputs.agenix-cli.packages.${system}) agenix-cli;
      inherit (inputs.nixpkgs-for-jdk15.legacyPackages.${system}) jdk15;

      inherit (unstable)
        # need bleeding edge version
        jetbrains
        minecraft-server
        minecraftServers
        portfolio
        teamspeak_server
        ;

      gerschtli = prev.lib.composeManyExtensions gerschtliOverlays final prev;

      # the only alias that I need, this allows me to set allowAliases=false
      inherit (prev.stdenv.hostPlatform) system;
      inherit (prev.nixVersions) nix_2_4; # for nix-on-droid
    })

    inputs.nixGL.overlays.default
  ];

  pkgs = import inputs.nixpkgs {
    inherit config overlays system;
  };
in

{
  inherit pkgs;

  pkgsNixOnDroid = import inputs.nixpkgs {
    inherit config system;
    overlays = overlays ++ [ inputs.nix-on-droid.overlays.default ];
  };

  customLib = import (rootPath + "/lib") {
    inherit (inputs.nixpkgs) lib;
    inherit pkgs;
  };
}
