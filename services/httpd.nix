{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.httpd = {
    enable = true;
    logPerVirtualHost = true;
    adminAddr = "tobias.happ@gmx.de";
  };
}
