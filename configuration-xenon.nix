{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    boot.mode = "raspberry";

    server.enable = true;

    services.storage = {
      enable = true;
      mountDevice = "/dev/disk/by-uuid/e3cda2ab-9b36-4d60-9a9c-dfba6f00ab32";
      interval = "Wed *-*-* 04:00:00";
      expiresAfter = 90;
      server = [
        {
          name = "krypton";
          ip = "195.201.88.53";
        }
      ];
    };
  };

  hardware.bluetooth.enable = true;

  networking = {
    hostName = "xenon";

    # Need to run: wpa_passphrase ESSID PSK > /etc/wpa_supplicant.conf
    wireless.enable = true;
  };
}
