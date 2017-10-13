{ config, pkgs, ... }:

{
  config._module.args.fetchBitBucket = import ./util/fetchBitBucket.nix { };

  imports = [
    ../hardware-configuration.nix
    ./applications/auto-golden-river-jazztett.nix
    ./applications/golden-river-jazztett.nix
    ./applications/pass.nix
    ./applications/snippie.nix
    ./applications/tobias-happ.nix
    ./applications/weechat.nix
    ./boot.nix
    ./desktop.nix
    ./dev.nix
    ./general.nix
    ./server.nix
    ./services/firewall.nix
    ./services/httpd.nix
    ./services/mysql.nix
    ./services/nginx.nix
    ./services/openssh.nix
    ./services/teamspeak.nix
    ./xserver.nix
  ];
}
