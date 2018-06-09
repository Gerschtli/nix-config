{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications = {
      auto-golden-river-jazztett.enable = true;
      golden-river-jazztett.enable = true;

      pass = {
        enable = true;
        ncurses = true;
      };

      weechat = {
        enable = true;
        port = 8000;
      };
    };

    server = {
      enable = true;
      ipv6Address = "2a01:4f8:1c0c:7168::2";
    };

    services.teamspeak.enable = true;
  };

  networking.hostName = "neon";
}
