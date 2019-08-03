{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  nix-channels = {
    nixos = "https://nixos.org/channels/nixos-19.03";
    home-manager = "https://github.com/Gerschtli/home-manager/archive/local.tar.gz";
  };
}
