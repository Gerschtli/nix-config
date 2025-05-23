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

        nixpkgs-23-11 = import inputs.nixpkgs-23-11 {
          inherit config system;
        };

        nixpkgs-22-05 = import inputs.nixpkgs-22-05 {
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

        inherit (nixpkgs-23-11)
          # needed for interop with php74
          apacheHttpd
          ;

        # pin 22.05 release for removed packages
        inherit (nixpkgs-22-05)
          mysql57
          php74
          php74Extensions
          php74Packages
          php80
          php80Extensions
          php80Packages
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
