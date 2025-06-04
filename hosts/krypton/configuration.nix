{ config, lib, pkgs, ... }:

{
  custom = {
    applications = {
      downloads.enable = true;

      tobias-happ.enable = true;
    };

    base.server = {
      enable = true;
      ipv6Address = "2a01:4f8:1c0c:7161::2";
    };

    ids.enable = false;

    services = {
      backup.enable = true;

      gitea.enable = true;

      teamspeak.enable = true;
    };

    system.boot = {
      mode = "grub";
      device = "/dev/sda";
    };
  };
}
