{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.base.general;
in

{

  ###### interface

  options = {

    custom.base.general = {
      enable = mkEnableOption "basic config" // { default = true; };

      hostName = mkOption {
        type = types.enum [ "argon" "krypton" "neon" "xenon" ];
        description = "Host name.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    boot.cleanTmpDir = true;

    console.keyMap = "de";

    custom.system.firewall.enable = true;

    environment = {
      defaultPackages = [ ];
      shellAliases = mkForce { };
    };

    home-manager = {
      backupFileExtension = "hm-bak";
      useGlobalPkgs = true;
      useUserPackages = true;

      users = {
        root = import (config.lib.custom.path.homeFiles + "/${cfg.hostName}/root.nix");
        tobias = import (config.lib.custom.path.homeFiles + "/${cfg.hostName}/tobias.nix");
      };
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

    programs.zsh = {
      enable = true;
      enableGlobalCompInit = false;
      promptInit = "";
    };

    system.stateVersion = "21.05";

    time.timeZone = "Europe/Berlin";

    users.users = {
      root.shell = pkgs.zsh;

      tobias = {
        # FIXME: move mkIf to ids module
        uid = mkIf config.custom.ids.enable config.custom.ids.uids.tobias;
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        shell = pkgs.zsh;
      };
    };

  };

}
