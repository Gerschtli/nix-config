{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.server;
in

{

  ###### interface

  options = {

    custom.server = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable basic desktop config with dwm.
        '';
      };

      rootLogin = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable root login via pubkey.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      boot.isEFI = false;

      services = {
        firewall.dropPackets =
          let
            path = ../secrets/blocked-ips.nix;
          in
            if builtins.pathExists path
            then import path
            else [];

        openssh = {
          enable = true;
          rootLogin = cfg.rootLogin;
        };
      };
    };

    environment.noXlibs = true;

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
      dates = "07:00";
    };

  };

}
