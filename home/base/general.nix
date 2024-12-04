{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    mkMerge
    optionals
    ;

  cfg = config.custom.base.general;

  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";
in

{

  ###### interface

  options = {

    custom.base.general = {
      enable = mkEnableOption "basic config" // { default = true; };

      lightWeight = mkEnableOption "light weight config for low performance hosts";

      minimal = mkEnableOption "minimal config";

      darwin = mkEnableOption "darwin specific config";
    };

  };


  ###### implementation

  config = mkIf cfg.enable (mkMerge [

    {
      custom.programs = {
        bash.enable = true;
        htop.enable = true;
        neovim.enable = true;
        nix-index.enable = true;
        prompts = {
          liquidprompt.enable = mkIf (!cfg.lightWeight) true;
          pure.enable = mkIf cfg.lightWeight true;
        };
        tmux.enable = true;
        zsh.enable = true;
      };

      home = {
        language = {
          base = localeEnglish;
          address = localeEnglish;
          collate = localeEnglish;
          ctype = localeEnglish;
          measurement = localeGerman;
          messages = localeEnglish;
          monetary = localeEnglish;
          name = localeEnglish;
          numeric = localeEnglish;
          paper = localeGerman;
          telephone = localeEnglish;
          time = localeGerman;
        };

        packages = with pkgs; [
          bc
          file
          httpie
          jq
          mmv-go
          nmap
          pwgen
          ripgrep
          tree
          wget
          yq-go

          gzip
          unzip
          xz
          zip

          bind # dig
          netcat
        ]
        ++ optionals (!cfg.darwin) [
          iotop
          ncdu
          nload # network traffic monitor
          psmisc # killall
          whois
        ];

        sessionVariables = {
          LESS = concatStringsSep " " [
            "--RAW-CONTROL-CHARS"
            "--no-init"
            "--quit-if-one-screen"
            "--tabs=4"
          ];
          PAGER = "${pkgs.less}/bin/less";
        };

        stateVersion = "24.11";
      };

      programs.fzf.enable = true;

      systemd.user.startServices = true;
    }

    (mkIf (!cfg.minimal) {
      custom = {
        misc.util-bins.enable = true;

        programs = {
          git.enable = true;
          nnn.enable = true;
          rsync.enable = true;
          ssh = {
            enable = true;
            modules = [ "vcs" ];
          };
        };
      };

      programs.home-manager.enable = true;
    })

  ]);

}
