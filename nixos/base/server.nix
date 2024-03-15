{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.base.server;
in

{

  ###### interface

  options = {

    custom.base.server = {
      enable = mkEnableOption "basic server config";

      ipv6Address = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "IPv6 address.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.openssh.enable = true;

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
        dates = "*-*-* 00:00:00";
        options = "--delete-older-than 14d";
      };

      optimise = {
        automatic = true;
        dates = [ "Mon *-*-* 01:00:00" ];
      };
    };

    services.journald.extraConfig = ''
      SystemMaxUse=2G
    '';

  };

}
