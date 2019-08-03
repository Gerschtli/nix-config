{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.util-bins;

  bins = [ "$" "256colors.pl" ] ++ cfg.bins;
in

{

  ###### interface

  options = {

    custom.util-bins = {

      enable = mkEnableOption "some utility binaries";

      bins = mkOption {
        type = types.listOf (types.enum [ "csv-check" "dotfiles-update" "system-update" ]);
        default = [];
        description = "List of bins to install.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [
      (pkgs.stdenv.mkDerivation {
        name = "util-bins";

        src = ../files/util-bins;

        installPhase = ''
          mkdir -p $out/bin

          ${lib.concatMapStringsSep "\n" (bin: "install -m 0755 ${bin} $out/bin") bins}
        '';
      })
    ];

  };

}
