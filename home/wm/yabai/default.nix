{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.wm.yabai;
in

{

  ###### interface

  options = {

    custom.wm.yabai.enable = mkEnableOption "config for yabai";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.file = {
      ".skhdrc" = {
        source = ./skhdrc;
        onChange = "skhd --restart-service";
      };

      ".yabairc" = {
        source = ./yabairc;
        onChange = "yabai --restart-service";
      };
    };

  };

}
