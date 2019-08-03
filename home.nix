{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom.dotfiles.modules = [ "atom" "home-manager" ];
}
