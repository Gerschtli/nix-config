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

      golden-river-jazztett.enable = true;

      pass = {
        enable = true;
        ncurses = true;
      };

      tobias-happ.enable = true;

      weechat = {
        enable = true;
        port = 8000;
      };
    };

    backup.enable = true;

    server = {
      enable = true;
      ipv6Address = "2a01:4f8:1c0c:7161::2";
    };

    services = {
      openssh.rootLogin = true;

      teamspeak.enable = true;
    };
  };

  networking.hostName = "krypton";
}
