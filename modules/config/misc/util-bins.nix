{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.misc.util-bins;

  bins = [ "$" "256colors.pl" "conf-status" "system-update" ] ++ cfg.bins;
in

{

  ###### interface

  options = {

    custom.misc.util-bins = {

      enable = mkEnableOption "some utility binaries";

      bins = mkOption {
        type = types.listOf (types.enum [ "csv-check" ]);
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

        src = config.lib.custom.path.files + "/util-bins";

        installPhase = ''
          mkdir -p $out/bin

          ${lib.concatMapStringsSep "\n" (bin: "install -m 0755 ${bin} $out/bin") bins}
        '';
      })
    ];

  };

}
