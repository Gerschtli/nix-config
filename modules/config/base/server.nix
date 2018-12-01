{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.base.server;
in

{

  ###### interface

  options = {

    custom.base.server = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable basic server config.
        '';
      };

      ipv6Address = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          IPv6 address.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.openssh.enable = true;

    environment.noXlibs = true;

    networking = mkIf (cfg.ipv6Address != null) {
      defaultGateway6 = {
        address = "fe80::1";
        interface = "eth0";
      };

      interfaces.eth0.ipv6.addresses = [
        {
          address = cfg.ipv6Address;
          prefixLength = 64;
        }
      ];
    };

    nix = {
      gc = {
        automatic = true;
        dates = "Mon *-*-* 00:00:00";
        options = "--delete-older-than 14d";
      };

      optimise = {
        automatic = true;
        dates = [ "Mon *-*-* 01:00:00" ];
      };
    };

    system.autoUpgrade = {
      enable = true;
      dates = "Mon *-*-* 07:00:00";
    };

  };

}
