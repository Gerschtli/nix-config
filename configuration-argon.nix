{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom.base = {
    desktop = {
      enable = true;
      laptop = true;
    };

    general.hostName = "argon";
  };

  home-manager.users = {
    root = import ./home-manager-configurations/home-files/argon/root.nix;
    tobias = import ./home-manager-configurations/home-files/argon/tobias.nix;
  };
}
