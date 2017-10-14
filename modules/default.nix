{ config, pkgs, ... }:

{
  config._module.args.fetchBitBucket = import ./lib/fetchBitBucket.nix { };

  imports = [
    ../hardware-configuration.nix
    ./config/applications/auto-golden-river-jazztett.nix
    ./config/applications/golden-river-jazztett.nix
    ./config/applications/pass.nix
    ./config/applications/snippie.nix
    ./config/applications/tobias-happ.nix
    ./config/applications/weechat.nix
    ./config/boot.nix
    ./config/desktop.nix
    ./config/dev.nix
    ./config/general.nix
    ./config/server.nix
    ./config/services/firewall.nix
    ./config/services/httpd.nix
    ./config/services/mysql.nix
    ./config/services/nginx.nix
    ./config/services/openssh.nix
    ./config/services/teamspeak.nix
    ./config/xserver.nix
  ];
}
