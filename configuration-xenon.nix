{ config, pkgs, ... }:

let
  krypton-ip = "195.201.88.53";
in

{
  imports = [ ./modules ];

  custom = {
    base.server.enable = true;

    services = {
      ip-watcher.client = {
        enable = true;
        interval = "*-*-* *:00:00";
        ssh.ip = krypton-ip;
      };

      storage = {
        enable = true;
        mountDevice = "/dev/disk/by-uuid/e3cda2ab-9b36-4d60-9a9c-dfba6f00ab32";
        interval = "Wed *-*-* 04:00:00";
        expiresAfter = 90;
        server = [
          {
            name = "krypton";
            ip = krypton-ip;
          }
        ];
      };
    };

    system.boot.mode = "raspberry";
  };

  hardware.bluetooth.enable = true;

  networking = {
    hostName = "xenon";

    # Need to run: wpa_passphrase ESSID PSK > /etc/wpa_supplicant.conf
    wireless.enable = true;
  };
}
