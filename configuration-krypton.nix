{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications = {
      betting-game-backend = {
        enable = true;
        containerID = 2;
      };

      car-stats = {
        enable = true;
        containerID = 1;
      };

      downloads.enable = true;

      tobias-happ.enable = true;
    };

    base.server = {
      enable = true;
      ipv6Address = "2a01:4f8:1c0c:7161::2";
    };

    programs = {
      pass = {
        enable = true;
        ncurses = true;
      };

      weechat = {
        enable = true;
        port = 8000;
      };
    };

    services = {
      backup.enable = true;

      gitea.enable = true;

      ip-watcher.server.enable = true;

      openssh.rootLogin = true;

      teamspeak.enable = true;
    };

    system.boot.mode = "grub";
  };

  networking.hostName = "krypton";
}
