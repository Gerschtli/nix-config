{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.general;
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

      pass = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable pass.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    boot.cleanTmpDir = true;

    custom.services.firewall.enable = true;

    environment.systemPackages = with pkgs; [
      bc
      file
      git
      gzip
      htop
      keychain
      neovim
      psmisc
      tmux
      tree
      wget
      xz
      zip
      zsh
    ] ++ (
      if cfg.pass
      then [
        gnupg1
        pass
        pinentry_ncurses
      ]
      else []
    );

    i18n = {
      consoleKeyMap = "de";
      defaultLocale = "en_US.UTF-8";
    };

    networking.usePredictableInterfaceNames = false;

    programs.zsh.enable = true;

    system.stateVersion = "17.03";

    time.timeZone = "Europe/Berlin";

    users.users = {
      root.shell = pkgs.zsh;

      tobias = {
        group = "wheel";
        home = "/home/tobias";
        isNormalUser = true;
        shell = pkgs.zsh;
        uid = 1000;
      };
    };

  };

}
