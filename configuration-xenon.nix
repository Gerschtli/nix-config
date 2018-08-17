{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    boot.mode = "raspberry";

    server.enable = true;
  };

  hardware.bluetooth.enable = true;

  networking = {
    hostName = "xenon";

    # Need to run: wpa_passphrase ESSID PSK > /etc/wpa_supplicant.conf
    wireless.enable = true;
  };
}
