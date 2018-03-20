{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.boot;
in

{

  ###### interface

  options = {

    custom.boot = {

      isEFI = mkOption {
        type = types.bool;
        description = ''
          Whether to boot in efi mode.
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

    (mkIf cfg.isEFI
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

    (mkIf (! cfg.isEFI)
      {
        boot.loader.grub = {
          inherit (cfg) device;
          enable = true;
          version = 2;
        };
      }
    )

  ];

}
