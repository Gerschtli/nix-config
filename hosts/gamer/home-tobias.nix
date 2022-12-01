{ config, lib, pkgs, ... }:

{
  custom = {
    base.non-nixos.enable = true;

    development.nix.home-manager.enable = true;

    programs.ssh.modules = [ "private" ];
  };

  home = {
    homeDirectory = "/home/tobias";
    username = "tobias";
  };
}
