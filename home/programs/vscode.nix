{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.vscode;
in

{

  ###### interface

  options = {

    custom.programs.vscode = {
      enable = mkEnableOption "vscode";

      packages = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "List of packages that should be put on PATH for vscode.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.vscode.packages = [
      pkgs.nixpkgs-fmt
    ];

    home.packages = [
      (config.lib.custom.wrapProgram {
        inherit (cfg) packages;
        name = "code";
        source = pkgs.vscode;
        path = "/bin/code";
      })
    ];

  };

}
