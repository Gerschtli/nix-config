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

        nixpkgs-for-linux-5-19 = import inputs.nixpkgs-for-linux-5-19 {
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

        # FIXME: remove after 22.11
        linuxKernel = prev.linuxKernel // {
          packages = prev.linuxKernel.packages // {
            inherit (nixpkgs-for-linux-5-19.linuxKernel.packages) linux_5_19;
          };
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
