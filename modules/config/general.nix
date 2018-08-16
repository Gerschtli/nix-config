{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.general;

  customLib = import ../lib args;
in

{

  ###### interface

  options = {

    custom.general = {

      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable basic config.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    boot.cleanTmpDir = true;

    custom.services.firewall.enable = true;

    environment = {
      shellAliases = mkForce { };

      systemPackages = with pkgs; [
        bc
        file
        fzf
        git
        gitAndTools.tig
        htop
        httpie
        keychain
        neovim
        nox
        pwgen
        ripgrep
        tmux
        tree
        wget

        gzip
        unzip
        xz
        zip

        bind # dig
        netcat
        psmisc # killall
        whois
      ];
    };

    i18n = {
      consoleKeyMap = "de";
      defaultLocale = "en_US.UTF-8";
    };

    networking.usePredictableInterfaceNames = false;

    nixpkgs.overlays = map (file: import file) (customLib.getRecursiveFileList ../overlays);

    programs.zsh = {
      enable = true;
      promptInit = "";
    };

    system.stateVersion = "18.03";

    time.timeZone = "Europe/Berlin";

    users.users = {
      root.shell = pkgs.zsh;

      tobias = {
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        shell = pkgs.zsh;
      };
    };

  };

}
