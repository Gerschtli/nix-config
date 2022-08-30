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
          basename = baseNameOf dataDir;
        in

        ''
          ${pkgs.gnutar}/bin/tar \
            --exclude="${basename}/libraries" \
            --exclude="${basename}/logs" \
            --exclude="${basename}/versions" \
            -cpzf minecraft-server-$(date +%s).tar.gz -C ${dirOf dataDir} ${basename}
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
        "-Xms4092M"
        "-Xmx20480M"
      ];
    };

  };

}
