{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom.server = {
    enable = true;
    ipv6Address = "2a01:4f8:1c0c:7168::2";
  };

  networking.hostName = "neon";
}
