{ config, lib, pkgs, ... }:

{
  imports = [ (import ./modules "krypton") ];

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

    programs.weechat = {
      enable = true;
      port = 8000;
    };

    services = {
      backup.enable = true;

      gitea.enable = true;

      ip-watcher.server.enable = true;

      openssh.rootLogin = true;

      teamspeak.enable = true;
    };

    system.boot = {
      mode = "grub";
      device = "/dev/sda";
    };
  };

  # FIXME: pinentry needs gtk, this prevents recompiling it
  environment.noXlibs = lib.mkForce false;
}
