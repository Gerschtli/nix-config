{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.base;

  customLib = import ../lib args;

  overlays = customLib.getFileList ../overlays;
in

{

  ###### interface

  options = {

    custom.base.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable basic config.
      '';
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.htop.enable = true;

    home.stateVersion = "19.03";

    nixpkgs = {
      config = import ../files/config.nix;
      overlays = map (file: import file) overlays;
    };

    programs.home-manager.enable = true;

    xdg.configFile = {
      "nixpkgs/config.nix".source = ../files/config.nix;
    } // builtins.listToAttrs (
      map (file: {
        name = "nixpkgs/overlays/${baseNameOf file}";
        value.source = file;
      }) overlays
    );

  };

}
