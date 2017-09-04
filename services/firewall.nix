{ config, pkgs, ... }:

{
  networking.firewall.enable = true;

  services.fail2ban.enable = true;
}
