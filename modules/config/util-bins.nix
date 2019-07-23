{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.util-bins;
in

{

  ###### interface

  options = {

    custom.util-bins = {

      enable = mkEnableOption "some utility binaries";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [
      # TODO: add system-update and csv-check
      (pkgs.stdenv.mkDerivation {
        name = "util-bins";

        src = ../files/util-bins;

        installPhase = ''
          mkdir -p $out/bin

          install -m 0755 $ $out/bin
          install -m 0755 256colors.pl $out/bin
        '';
      })
    ];

  };

}
