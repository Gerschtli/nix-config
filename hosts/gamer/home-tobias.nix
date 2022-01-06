{ config, lib, pkgs, ... }:

{
  custom = {
    base.non-nixos.enable = true;

    development.nix.home-manager.enable = true;

    misc.homeage.directory = "${config.xdg.dataHome}/secrets";

    programs.ssh.modules = [ "private" ];
  };
}
