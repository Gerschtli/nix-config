{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  users.users.tobias.extraGroups = [ "vboxusers" ];

  virtualisation.virtualbox.host.enable = true;
}
