{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.non-nixos.enable = true;

    programs.ssh.modules = [ "private" ];
  };
}
