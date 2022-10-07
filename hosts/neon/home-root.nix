{ config, lib, pkgs, ... }:

{
  custom = {
    development.nix.nixos.enable = true;

    programs.ssh.modules = [ "nixinate" ];
  };
}
