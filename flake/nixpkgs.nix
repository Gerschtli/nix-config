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

        gerschtliOverlays = map (x: x.overlays.default) [
          inputs.dmenu
          inputs.dwm
          inputs.dwm-status
          inputs.teamspeak-update-notifier
        ];
      in
      {
        inherit (inputs.agenix-cli.packages.${system}) agenix-cli;

        inherit (unstable)
          # FIXME: stable fails on darwin
          pnpm

          # need bleeding edge version
          cachix
          #jetbrains
          k9s
          minecraft-server
          minecraftServers
          portfolio
          teamspeak_server
          vscode
          ;

        gerschtli = prev.lib.composeManyExtensions gerschtliOverlays final prev;

        # the only alias that I need, this allows me to set allowAliases=false
        inherit system;
      }
    )

    inputs.nixGL.overlays.default
  ]
  ++ inputs.nixpkgs.lib.optionals nixOnDroid [
    inputs.nix-on-droid.overlays.default

    # prevent uploads to remote builder
    (final: prev: prev.prefer-remote-fetch final prev)
  ];
}
