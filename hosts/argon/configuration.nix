{ config, lib, pkgs, ... }:

{
  custom = {
    base.server.enable = true;

    services.openssh.enable = true;

    system.boot.mode = "oracle";
  };

  zramSwap.enable = true;
}
