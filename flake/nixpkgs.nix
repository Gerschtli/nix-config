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

        nixpkgs-jq-1-6 = import inputs.nixpkgs-jq-1-6 {
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
          # need bleeding edge version
          cachix
          #jetbrains
          minecraft-server
          minecraftServers
          portfolio
          teamspeak_server
          vscode
          ;

        # FIXME: pin 23.11 release for broken packages
        inherit (nixpkgs-23-11)
          audacity
          jetbrains
          libreoffice
          openshot-qt
          thunderbird

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

        # FIXME: use jq 1.6 for homeage
        inherit (nixpkgs-jq-1-6) jq;

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
