{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.minecraft-server;
in

{

  ###### interface

  options = {

    custom.services.minecraft-server.enable = mkEnableOption "minecraft-server";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.backup.services.minecraft-server = {
      description = "Minecraft server";
      user = "minecraft";
      interval = "Tue *-*-* 05:10:00";
      expiresAfter = 28;

      script =
        let
          inherit (config.services.minecraft-server) dataDir;
        in

        ''
          ${pkgs.gnutar}/bin/tar -cpzf minecraft-server-$(date +%s).tar.gz -C ${dirOf dataDir} ${baseNameOf dataDir}
        '';

      extraOptions = {
        path = [ pkgs.gzip ];
      };
    };

    services.minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      jvmOpts = concatStringsSep " " [
        "-Xms4G"
        "-Xmx16G"
      ];
    };

  };

}
