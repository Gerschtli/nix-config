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

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    boot.cleanTmpDir = true;

    custom.system.firewall.enable = true;

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
        iotop
        keychain
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

        ( # FIXME: use always neovim after https://github.com/NixOS/nixpkgs/issues/45026 got fixed
          if stdenv.hostPlatform.system == "aarch64-linux"
          then vim
          else neovim
        )
      ];
    };

    home-manager.useUserPackages = true;

    i18n = {
      consoleKeyMap = "de";
      defaultLocale = "en_US.UTF-8";
    };

    networking.usePredictableInterfaceNames = false;

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
