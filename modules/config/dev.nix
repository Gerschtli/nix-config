{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.dev;
in

{

  ###### interface

  options = {

    custom.dev = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable dev packages/services.
        '';
      };

    };

  };


  ###### implementation

  config = {

    custom.services.firewall.openPortsForIps = [
      # open php xdebug port
      { ip = "192.168.56.201"; port = 9000; }
      { ip = "192.168.56.202"; port = 9000; }
    ];

    networking.hosts = {
      # astarget
      "192.168.35.10" = [
        "www.astarget.local"
        "fb.astarget.local"
        "test.astarget.local"
        "test.fb.astarget.local"
      ];

      # profitmax/frontend
      "192.168.56.201" = [
        "www.accessoire.local.de"
        "www.getprice.local.at"
        "www.getprice.local.ch"
        "www.getprice.local.de"
        "www.handys.local.com"
        "www.preisvergleich.local.at"
        "www.preisvergleich.local.ch"
        "www.preisvergleich.local.eu"
        "www.preisvergleich.local.org"
        "www.shopping.local.at"
        "www.shopping.local.ch"
        "www.testit.local.de"
      ];

      # profitmax/backend
      "192.168.56.202" = [ "backend.local" ];
    };

    nixpkgs.config.allowUnfree = true;

    users.users.tobias.extraGroups = [ "docker" "vboxusers" ];

    virtualisation = {
      docker.enable = true;
      virtualbox.host.enable = true;
    };

  };

}
