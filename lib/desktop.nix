{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.desktop;
in

{

  ###### interface

  options = {

    custom.desktop = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable basic desktop config with dwm.
        '';
      };

      laptop = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to activate services for battery, network, backlight.
        '';
      };

      grubDevice = mkOption {
        type = types.str;
        default = "/dev/sda";
        description = ''
          Device for GRUB boot loader.
        '';
      };

      additionalPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = ''
          List of additional packages.
        '';
      };

      dev = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable virtualbox and set /etc/hosts.
        '';
      };

      cups = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to activate cups.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {

      boot = {
        isEFI = true;
        device = cfg.grubDevice;
      };

      general.enable = true;

      xserver = {
        enable = true;
        laptop = cfg.laptop;
      };

    };

  };

}
