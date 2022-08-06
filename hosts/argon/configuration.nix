{ config, lib, pkgs, ... }:

{
  custom = {
    applications.original-chattengauer.enable = true;

    base.server.enable = true;

    services = {
      backup.enable = true;

      openssh.enable = true;
    };

    system.boot.mode = "oracle";
  };

  zramSwap.enable = true;
}
