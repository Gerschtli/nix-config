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

    # FIXME: solve dependency to teamspeak3-server service via systemd and change user to non-root
    custom.backup.services.teamspeak3 = {
      description = "Teamspeak3 server";
      user = "root";
      interval = "Tue *-*-* 10:00:00";
      expiresAfter = 28;

      script =
        let
          inherit (config.services.teamspeak3) dataDir;
        in

        ''
          ${config.systemd.package}/bin/systemctl stop teamspeak3-server.service
          ${pkgs.gnutar}/bin/tar -cpzf ts3-$(date +%s).tar.gz -C ${dirOf dataDir} ${baseNameOf dataDir}
          ${config.systemd.package}/bin/systemctl start teamspeak3-server.service
        '';

      extraOptions = {
        path = [ pkgs.gzip ];
      };
    };

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

    # FIXME: remove when https://github.com/NixOS/nixpkgs/pull/45161 gets merged
    systemd.services.teamspeak3-server.serviceConfig.Environment = "TS3SERVER_LICENSE=accept";

  };

}
