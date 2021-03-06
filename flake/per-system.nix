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
        portfolio
        teamspeak_server
        ;

      gerschtli = prev.lib.composeManyExtensions gerschtliOverlays final prev;
    })
  ];

  pkgs = import inputs.nixpkgs {
    inherit config overlays system;
  };
in

{
  inherit pkgs;

  pkgsNixOnDroid = import inputs.nixpkgs {
    inherit system;
    # allowAliases is needed for nix-on-droid overlays (system <- stdenv.hostPlatform.system)
    config = config // { allowAliases = true; };
    overlays = overlays ++ [ inputs.nix-on-droid.overlay ];
  };

  customLib = import (rootPath + "/lib") {
    inherit (inputs.nixpkgs) lib;
    inherit pkgs;
  };
}
