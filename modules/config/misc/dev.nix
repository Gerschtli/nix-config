{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.misc.dev;
in

{

  ###### interface

  options = {

    custom.misc.dev.enable = mkEnableOption "dev packages/services";

  };


  ###### implementation

  config = mkIf cfg.enable {

    nixpkgs.config.allowUnfree = true;

    users.users.tobias.extraGroups = [
      # "docker"
      "vboxusers"
    ];

    virtualisation = {
      # docker.enable = true;

      virtualbox.host.enable = true;
    };

  };

}
