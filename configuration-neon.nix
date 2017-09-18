{ config, pkgs, ... }:

{
  imports = [
    ./lib/interface.nix
  ];

  custom = {
    applications = {
      auto-golden-river-jazztett.enable = true;
      golden-river-jazztett.enable = true;

      weechat = {
        enable = true;
        port = 8000;
      };
    };

    general.pass = true;

    server.enable = true;

    services.teamspeak.enable = true;
  };


  networking.hostName = "neon";
}
