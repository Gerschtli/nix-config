{ config, lib, pkgs, ... }:

{
  custom = {
    agenix.secrets = [ "wireless-config" ];

    base.server.enable = true;

    services.storage = {
      enable = true;
      mountDevice = "/dev/disk/by-uuid/e3cda2ab-9b36-4d60-9a9c-dfba6f00ab32";
      interval = "Wed *-*-* 04:00:00";
      expiresAfter = 90;
      server = [
        {
          name = "argon";
          ip = "141.147.62.247";
        }
        {
          name = "krypton";
          ip = "195.201.88.53";
        }
      ];
    };

    system.boot.mode = "raspberry";
  };

  environment.systemPackages = with pkgs; [
    exfat
    ntfs3g
  ];

  # hardware.bluetooth.enable = true;

  networking.wireless = {
    enable = true;
    environmentFile = config.age.secrets.wireless-config.path;
    networks."Vodafone-12345".psk = "@PSK@";
  };

  # needed because wpa_supplicant fails on startup
  # see https://github.com/NixOS/nixpkgs/issues/82462
  systemd.services.wpa_supplicant.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };
}
