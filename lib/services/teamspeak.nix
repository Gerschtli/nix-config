{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.teamspeak;
in

{

  ###### interface

  options = {

    custom.services.teamspeak = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install and configure teamspeak.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall = {
      allowedTCPPorts = [
        10011
        30033
        41144
      ];

      allowedUDPPorts = [
        9987
      ];
    };

    nixpkgs.config.allowUnfree = true;

    services.teamspeak3.enable = true;

  };

}
