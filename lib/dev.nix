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
        networking.hosts = {
          # astarget
          "192.168.35.10" = [
            "www.astarget.local"
            "fb.astarget.local"
            "test.astarget.local"
            "test.fb.astarget.local"
          ];

          # cbn/backend
          "192.168.56.202" = [ "backend.local" ];

          # cbn/frontend
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

          # snippie
          "192.168.56.101" = [ "snippie.local" ];
        };
      }
    )

  ];

}
