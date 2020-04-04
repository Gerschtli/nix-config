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

      enable = mkEnableOption "basic config" // { default = true; };

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
        "https://hercules-ci.cachix.org"
        "https://nix-on-droid.cachix.org"
      ];
      binaryCachePublicKeys = mkForce [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
        "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
        "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      ];
      trustedUsers = [ "root" "tobias" ];
    };

    nixpkgs.overlays = map import (customLib.getFileList ../../overlays);

    programs.zsh = {
      enable = true;
      enableGlobalCompInit = false;
      promptInit = "";
    };

    system.stateVersion = "19.09";

    time.timeZone = "Europe/Berlin";

    users = {
      groups.secret-files = {
        gid = config.ids.gids.secret-files;
      };

      users = {
        root.shell = pkgs.zsh;

        tobias = {
          uid = config.ids.uids.tobias;
          extraGroups = [ "secret-files" "wheel" ];
          isNormalUser = true;
          shell = pkgs.zsh;
        };
      };
    };

  };

}
