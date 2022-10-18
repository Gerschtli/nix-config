{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.nodejs;
in

{

  ###### interface

  options = {

    custom.development.nodejs.enable = mkEnableOption "nodejs config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.dynamicShellInit = [
      {
        condition = "available npm && is_bash";

        initExtra = ''
          eval "$(npm completion)"
        '';
      }
    ];

    home.file.".npmrc".text = ''
      engine-strict=true
    '';

    programs.zsh.plugins = [
      {
        name = "zsh-better-npm-completion";
        src = "${pkgs.zsh-better-npm-completion}/share/zsh-better-npm-completion";
      }
    ];

  };

}
