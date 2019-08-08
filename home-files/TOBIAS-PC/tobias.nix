{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    misc.non-nixos.enable = true;

    programs.ssh.modules = [ "private" ];
  };

  home.packages = with pkgs; [
    openssh
  ];
}
