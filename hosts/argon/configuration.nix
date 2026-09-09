{ config, lib, pkgs, rootPath, ... }:

{
  custom = {
    applications = {
      vaultwarden.enable = true;
    };

    base.server.enable = true;

    services = {
      backup.enable = true;
    };

    system.boot.mode = "efi";
  };

  zramSwap.enable = true;
}
