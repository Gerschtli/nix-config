{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.boot;
in

{

  ###### interface

  options = {

    custom.boot = {

      mode = mkOption {
        type = types.enum [ "efi" "grub" "raspberry" ];
        description = ''
          Sets mode for boot options.
        '';
      };

      device = mkOption {
        type = types.str;
        default = "/dev/sda";
        description = ''
          Device for GRUB boot loader.
        '';
      };

    };

  };


  ###### implementation

  config = mkMerge [

    (mkIf (cfg.mode == "efi")
      {
        boot.loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot = {
            enable = true;
            editor = false;
          };
        };
      }
    )

    (mkIf (cfg.mode == "grub")
      {
        boot.loader.grub = {
          inherit (cfg) device;
          enable = true;
          version = 2;
        };
      }
    )

    (mkIf (cfg.mode == "raspberry")
      {
        boot = {
          loader = {
            grub.enable = false;
            generic-extlinux-compatible.enable = true;
          };

          kernel.sysctl = {
            "vm.dirty_background_ratio" = 5;
            "vm.dirty_ratio" = 80;
          };

          kernelParams = ["cma=32M"];
          kernelPackages = pkgs.linuxPackages_latest;
        };
      }
    )

  ];

}
