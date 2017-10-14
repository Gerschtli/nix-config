{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.firewall;
in

{

  ###### interface

  options = {

    custom.services.firewall = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable firewall.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall = {
      enable = true;
      allowPing = true;
    };

    services.fail2ban.enable = true;

  };

}
