{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.programs.ssh.modules = [ "private" ];
}
