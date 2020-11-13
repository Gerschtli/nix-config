{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.idea-ultimate;
in

{

  ###### interface

  options = {

    custom.programs.idea-ultimate = {
      enable = mkEnableOption "idea-ultimate";

      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "List of packages that should be put on PATH for idea-ultimate.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.idea-ultimate.packages = with pkgs; [
      pipenv
    ];

    home.packages = [
      (config.lib.custom.wrapProgram {
        inherit (cfg) packages;
        name = "idea-ultimate";
        source = pkgs.jetbrains.idea-ultimate;
        path = "/bin/idea-ultimate";
      })
      pkgs.rustup # needs to be globally installed for ide integration
    ];

  };

}
