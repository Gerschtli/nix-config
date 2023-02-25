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

        nixpkgs-22-05 = import inputs.nixpkgs-22-05 {
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

        # FIXME: remove once 1.3 hits unstable
        inherit (inputs.cachix.packages.${system}) cachix;

        inherit (unstable)
          # need bleeding edge version
          jetbrains
          minecraft-server
          minecraftServers
          teamspeak_server

          # need >= 0.1.4
          nix-index

          # fails with version in stable
          nixos-shell
          ;

        # pin 22.05 release for removed packages
        inherit (nixpkgs-22-05)
          mysql57
          php74
          php74Extensions
          php74Packages
          ;

        gerschtli = prev.lib.composeManyExtensions gerschtliOverlays final prev;

        nixVersions = prev.nixVersions // {
          inherit (unstable.nixVersions) nix_2_13;
        };

        # the only alias that I need, this allows me to set allowAliases=false
        inherit system;
        inherit (prev.nixVersions) nix_2_4; # for nix-on-droid
      }
    )

    inputs.nixGL.overlays.default
  ]
  ++ inputs.nixpkgs.lib.optional nixOnDroid inputs.nix-on-droid.overlays.default;
}
