{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.atom;
in

{

  ###### interface

  options = {

    custom.programs.atom = {
      enable = mkEnableOption "atom";

      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "List of packages that should be put on PATH for atom.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.atom.packages = [
      pkgs.python3Packages.sqlparse
    ];

    home.packages = [
      (config.lib.custom.wrapProgram {
        inherit (cfg) packages;
        name = "atom";
        source = pkgs.atom;
        path = "/bin/atom";
      })
    ];

  };

}
