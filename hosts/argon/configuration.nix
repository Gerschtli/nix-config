{ config, lib, pkgs, rootPath, ... }:

{
  imports = [
    ./configuration-steini.nix
  ];

  custom = {
    applications = {
      original-chattengauer.enable = true;

      vereinsmanager.enable = true;
    };

    base.server.enable = true;

    programs.docker = {
      enable = true;

      autoPrune.enable = true;
    };

    services = {
      backup.enable = true;

      minecraft-server.enable = true;

      openssh.enable = true;
    };

    system.boot.mode = "efi";
  };

  zramSwap.enable = true;
}
