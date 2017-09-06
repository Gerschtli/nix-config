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
        default = false;
        description = ''
          Whether to enable basic config.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      bc
      git
      gzip
      htop
      keychain
      neovim
      tmux
      tree
      wget
      xz
      zip
      zsh
    ];

    i18n = {
      consoleKeyMap = "de";
      defaultLocale = "en_US.UTF-8";
    };

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
