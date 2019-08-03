{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    misc.dotfiles.enable = true;

    programs.ssh.modules = [ "private" ];
  };

  home.packages = with pkgs; [
    nix
    cacert
    coreutils
    bashInteractive

    diffutils
    findutils
    gnugrep
    gnused
    hostname
    man
    openssh
  ];
}
