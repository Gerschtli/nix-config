{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications = {
      car-stats = {
        enable = true;
        containerID = 1;
      };

      gitea.enable = true;
      tobias-happ.enable = true;
    };

    server = {
      enable = true;
      ipv6Address = "2a01:4f8:1c0c:7161::2";
    };

    services.openssh.rootLogin = true;
  };

  networking.hostName = "krypton";
}
