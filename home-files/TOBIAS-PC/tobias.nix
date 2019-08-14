{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.programs.ssh.modules = [ "private" ];

  home.packages = with pkgs; [
    openssh
  ];
}
