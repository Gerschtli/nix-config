{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.base.general;

  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";

  sessionVariables = {
    LC_CTYPE = localeEnglish;
    LC_NUMERIC = localeEnglish;
    LC_TIME = localeGerman;
    LC_COLLATE = localeEnglish;
    LC_MONETARY = localeEnglish;
    LC_MESSAGES = localeEnglish;
    LC_PAPER = localeGerman;
    LC_NAME = localeEnglish;
    LC_ADDRESS = localeEnglish;
    LC_TELEPHONE = localeEnglish;
    LC_MEASUREMENT = localeGerman;
    LC_IDENTIFICATION = localeEnglish;
    LC_ALL = "";

    LANG = localeEnglish;
    LANGUAGE = localeEnglish;

    LESS = builtins.concatStringsSep " " [
      "--RAW-CONTROL-CHARS"
      "--no-init"
      "--quit-if-one-screen"
      "--tabs=4"
    ];
    PAGER = "${pkgs.less}/bin/less";
  };
in

{

  ###### interface

  options = {

    custom.base.general = {
      enable = mkEnableOption "basic config" // { default = true; };

      lightWeight = mkEnableOption "light weight config for low performance hosts";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      misc.util-bins.enable = true;

      programs = {
        bash.enable = true;
        git.enable = true;
        htop.enable = true;
        neovim.enable = true;
        nnn.enable = true;
        prompts = {
          liquidprompt.enable = mkIf (!cfg.lightWeight) true;
          pure.enable = mkIf cfg.lightWeight true;
        };
        rsync.enable = true;
        ssh = {
          enable = true;
          modules = [ "vcs" ];
        };
        tmux.enable = true;
        zsh.enable = true;
      };
    };

    home = {
      inherit sessionVariables;

      packages = with pkgs; [
        bc
        file
        httpie
        iotop
        jq
        mmv-go
        nmap
        ncdu
        nload # network traffic monitor
        pwgen
        ripgrep
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

      stateVersion = "21.11";
    };

    programs = {
      fzf.enable = true;
      home-manager.enable = true;
    };

    # FIXME: set to sd-switch once it works for krypton
    systemd.user.startServices = "legacy";

  };

}
