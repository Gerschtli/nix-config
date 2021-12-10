# Setup for raspberry pi
# 1. Build
#       nix-build "<nixpkgs/nixos>" -I nixos-config=misc/sd-image.nix -A config.system.build.sdImage
# 2. Copy (dd) result/sd-image/*.img to sd-card
# 3. Mount sd-card and run
#       wpa_passphrase ESSID PSK > /mnt/etc/wpa_supplicant.conf
# 4. Unmount, inject sd-card in raspberry and boot

{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  networking = {
    usePredictableInterfaceNames = false;

    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
  };

  sdImage.compressImage = false;

  services.openssh.enable = true;

  # needed because wpa_supplicant fails on startup
  # see https://github.com/NixOS/nixpkgs/issues/82462
  systemd.services.wpa_supplicant.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
  };

  users.users.root = {
    password = "nixos";
    openssh.authorizedKeys.keyFiles = [ ../files/keys/id_rsa.tobias.pub ];
  };
}
