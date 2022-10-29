{ inputs, system, nixOnDroid ? false }:

let
  config = {
    allowAliases = false;
    allowUnfree = true;
  };
in

import inputs.nixpkgs {
  inherit config system;

  overlays = [
    (final: prev:
      let
        inherit (prev.stdenv.hostPlatform) system;

        unstable = import inputs.unstable {
          inherit config system;
        };

        gerschtliOverlays = [
          inputs.dmenu.overlays.default
          inputs.dwm.overlays.default
          inputs.dwm-status.overlays.default
          inputs.teamspeak-update-notifier.overlays.default
        ];
      in
      {
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

        # FIXME: remove this once git 2.38.0 is in stable
        git_gte_2_38 = unstable.git;

        gerschtli = prev.lib.composeManyExtensions gerschtliOverlays final prev;

        # the only alias that I need, this allows me to set allowAliases=false
        inherit system;
        inherit (prev.nixVersions) nix_2_4; # for nix-on-droid
      }
    )

    inputs.nixGL.overlays.default
  ]
  ++ inputs.nixpkgs.lib.optional nixOnDroid inputs.nix-on-droid.overlays.default;
}