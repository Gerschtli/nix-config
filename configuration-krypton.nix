{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications = {
      # betting-game-backend = {
      #   enable = true;
      #   containerID = 2;
      # };

      # betting-game-frontend = {
      #   enable = true;
      #   containerID = 3;
      # };

      car-stats = {
        enable = true;
        containerID = 1;
      };

      downloads.enable = true;

      tobias-happ.enable = true;
    };

    base = {
      general.hostName = "krypton";

      server = {
        enable = true;
        ipv6Address = "2a01:4f8:1c0c:7161::2";
      };
    };

    programs.weechat = {
      enable = true;
      port = 8000;
    };

    services = {
      backup.enable = true;

      gitea.enable = true;

      # hercules-ci-agent.enable = true;

      ip-watcher.server.enable = true;

      openssh.rootLogin = true;

      teamspeak.enable = true;
    };

    system.boot.mode = "grub";
  };
}
