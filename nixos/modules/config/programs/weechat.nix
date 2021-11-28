{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.weechat;
in

{

  ###### interface

  options = {

    custom.programs.weechat = {
      enable = mkEnableOption "weechat";

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

    networking.firewall.allowedTCPPorts = optional (cfg.port != null) cfg.port;

    programs.screen.screenrc = ''
      multiuser on
      acladd tobias
      escape ^Bb
    '';

    services.weechat.enable = true;

  };

}
