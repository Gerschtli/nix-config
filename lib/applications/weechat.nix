{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.weechat;
in

{

  ###### interface

  options = {

    custom.applications.weechat = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install weechat.
        '';
      };

      port = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Port for relay.  Set null if disabled.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.users.tobias.packages = [ pkgs.weechat ];

    networking.firewall.allowedTCPPorts = optional (cfg.port != null) cfg.port;

  };

}
