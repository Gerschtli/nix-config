{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.services.dynv6;

  inherit (config.networking) hostName;

  stateDir = "/var/lib/dynv6";
  dynv6Hostname = "gerschtli-${hostName}.v6.rocks";
in

{

  ###### interface

  options = {

    custom.services.dynv6 = {
      enable = mkEnableOption "dynv6";

      device = mkOption {
        type = types.str;
        description = "Network interface name.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      agenix.secrets = [ "dynv6-token-${hostName}" ];

      utils.systemd.timers.dynv6 = {
        description = "dynv6";
        interval = "*-*-* *:00/10:00"; # run every 10 minutes

        serviceConfig.script = toString (config.lib.custom.mkScriptPlain
          "dynv6.sh"
          ./dynv6.sh
          [
            pkgs.curl
            pkgs.gnugrep
            pkgs.gnused
            pkgs.iproute2
          ]
          {
            inherit (cfg) device;
            inherit dynv6Hostname stateDir;
            passwordFile = config.age.secrets."dynv6-token-${hostName}".path;
          }
        );
      };
    };

    systemd.tmpfiles.rules = [
      "d ${stateDir} 755 root root"
    ];

  };

}
