{ config, lib, pkgs, ... }:

{
  custom = {
    base = {
      general.lightWeight = true;

      non-nixos = {
        enable = true;
        installNix = false;
      };
    };

    development.nix.nix-on-droid.enable = true;

    programs.ssh.modules = [ "private" ];
  };
}
