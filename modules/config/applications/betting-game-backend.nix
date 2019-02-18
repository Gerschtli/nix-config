{ config, lib, pkgs, ... } @ args:

let
  customLib = import ../../lib args;
in

customLib.containerApp rec {
  name = "betting-game-backend";

  hostName = "api.bg.tobias-happ.de";

  containerPort = 5000;

  extraConfig = cfg: {
    custom = {
      # Need to run:
      # CREATE DATABASE betting_game;
      # CREATE USER 'betting_game'@'10.233.%.2' IDENTIFIED BY 'password';
      # GRANT ALL PRIVILEGES ON betting_game.* TO 'betting_game'@'10.233.%.2';
      services.mysql = {
        enable = true;
        backups = [ "betting_game" ];
      };

      system.firewall.openPortsForIps = [
        {
          ip = cfg.containerAddress;
          port = config.services.mysql.port;
        }
      ];
    };
  };
}
