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

      virtualbox = mkOption {
        type = types.bool;
        default = cfg.enable;
        description = ''
          Whether to install and configure virtualbox.
        '';
      };

      hosts = mkOption {
        type = types.bool;
        default = cfg.enable;
        description = ''
          Whether to append custom hosts to /etc/hosts file.
        '';
      };

    };

  };


  ###### implementation

  config = mkMerge [

    (mkIf cfg.virtualbox
      {
        nixpkgs.config.allowUnfree = true;

        users.users.tobias.extraGroups = [ "vboxusers" ];

        virtualisation.virtualbox.host.enable = true;
      }
    )

    (mkIf cfg.hosts
      {
        networking.extraHosts = ''
          # astarget
          192.168.35.10   www.astarget.local   fb.astarget.local
          192.168.35.10   test.astarget.local  test.fb.astarget.local

          # cbn/backend
          192.168.56.202  backend.local

          # cbn/frontend
          192.168.56.201  www.accessoire.local.de
          192.168.56.201  www.getprice.local.at
          192.168.56.201  www.getprice.local.ch
          192.168.56.201  www.getprice.local.de
          192.168.56.201  www.handys.local.com
          192.168.56.201  www.preisvergleich.local.at
          192.168.56.201  www.preisvergleich.local.ch
          192.168.56.201  www.preisvergleich.local.eu
          192.168.56.201  www.preisvergleich.local.org
          192.168.56.201  www.shopping.local.at
          192.168.56.201  www.shopping.local.ch
          192.168.56.201  www.testit.local.de

          # snippie
          192.168.56.101  snippie.local
          94.130.105.174  snippie.de
        '';
      }
    )

  ];

}
