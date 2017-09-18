{ config, pkgs, ... }:

{
  imports = [
    ./lib/interface.nix
  ];

  custom = {
    applications = {
      auto-golden-river-jazztett.enable = true;
      golden-river-jazztett.enable = true;
    };

    general.pass = true;

    server.enable = true;

    services.teamspeak.enable = true;
  };

  environment.systemPackages = [ pkgs.weechat ];

  networking.hostName = "neon";
}
