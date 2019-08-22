{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.base.general;

  customLib = import ../../lib args;
in

{
  imports = [ <home-manager/nixos> ];

  ###### interface

  options = {

    custom.base.general = {

      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable basic config.
        '';
      };

      hostName = mkOption {
        type = types.str;
        description = ''
          Host name.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    boot.cleanTmpDir = true;

    custom.system.firewall.enable = true;

    environment.shellAliases = mkForce { };

    home-manager = {
      backupFileExtension = "hm-bak";
      useUserPackages = true;

      users = {
        root = import (../../../home-manager-configurations/home-files + "/${cfg.hostName}/root.nix");
        tobias = import (../../../home-manager-configurations/home-files + "/${cfg.hostName}/tobias.nix");
      };
    };

    i18n = {
      consoleKeyMap = "de";
      defaultLocale = "en_US.UTF-8";
    };

    networking = {
      inherit (cfg) hostName;
      usePredictableInterfaceNames = false;
    };

    nix = {
      binaryCaches = [
        "https://cache.nixos.org"
        "https://gerschtli.cachix.org"
      ];
      binaryCachePublicKeys = [
        "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
      ];
    };

    nixpkgs.overlays = map (file: import file) (customLib.getFileList ../../overlays);

    programs.zsh = {
      enable = true;
      enableGlobalCompInit = false;
      promptInit = "";
    };

    system.stateVersion = "19.03";

    time.timeZone = "Europe/Berlin";

    users = {
      groups.secret-files = { };

      users = {
        root.shell = pkgs.zsh;

        tobias = {
          extraGroups = [ "secret-files" "wheel" ];
          isNormalUser = true;
          shell = pkgs.zsh;
        };
      };
    };

  };

}
