{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.misc.nix-channels;

  mainChannel = "https://nixos.org/channels/nixos-19.09" + optionalString cfg.small "-small";
  mainChannelName = if cfg.nixpkgs then "nixpkgs" else "nixos";
in

{

  ###### interface

  options = {

    custom.misc.nix-channels = {

      enable = mkEnableOption "nix-channels config";

      small = mkEnableOption "small main channel";

      nixpkgs = mkEnableOption "nixpkgs as name for main channel";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    nix-channels = {
      "${mainChannelName}" = "${mainChannel}";
      unstable = "https://nixos.org/channels/nixos-unstable";
      home-manager = "https://github.com/Gerschtli/home-manager/archive/local.tar.gz";
      nur-gerschtli = "https://github.com/Gerschtli/nur-packages/archive/master.tar.gz";
    };

  };

}
