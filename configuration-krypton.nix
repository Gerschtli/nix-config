{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications = {
      car-stats = {
        enable = true;
        containerID = 1;
      };

      gitea.enable = true;

      pass = {
        enable = true;
        x11Support = false;
        ncurses = true;
      };

      tobias-happ.enable = true;

      weechat = {
        enable = true;
        port = 8000;
      };
    };


    boot.mode = "grub";

    server = {
      enable = true;
      ipv6Address = "2a01:4f8:1c0c:7161::2";
    };

    services = {
      backup.enable = true;

      openssh.rootLogin = true;

      teamspeak.enable = true;
    };
  };

  networking.hostName = "krypton";
}
