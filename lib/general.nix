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
      unzip
      wget
      xz
      zip
      zsh
    ] ++ (optionals cfg.pass [
      gnupg1
      pass
    ]) ++ (optional (cfg.pass && config.custom.server.enable) pinentry_ncurses);

    i18n = {
      consoleKeyMap = "de";
      defaultLocale = "en_US.UTF-8";
    };

    networking.usePredictableInterfaceNames = false;

    programs.zsh.enable = true;

    system.stateVersion = "17.03";

    time.timeZone = "Europe/Berlin";

    users = {
      defaultUserShell = pkgs.zsh;

      users.tobias = {
        extraGroups = [ "wheel" ];
        isNormalUser = true;
      };
    };

  };

}
