{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.boot;
in

{

  ###### interface

  options = {

    custom.system.boot = {

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
            generic-extlinux-compatible.enable = true;

            grub.enable = false;
          };

          kernel.sysctl = {
            "vm.dirty_background_ratio" = 5;
            "vm.dirty_ratio" = 80;
          };

          # FIXME: use default or latest as soon as https://github.com/NixOS/nixpkgs/issues/82455 gets resolved
          kernelPackages = pkgs.linuxPackages_4_19;
          kernelParams = ["cma=32M"];
        };
      }
    )

  ];

}
