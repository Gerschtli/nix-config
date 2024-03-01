{ config, lib, pkgs, ... }:

{
  # run manually:
  # $ brew install graphviz

  custom = {
    base = {
      general.darwin = true;

      desktop = {
        enable = true;
        laptop = true;
      };

      non-nixos.enable = true;
    };

    development.nix.home-manager.enable = true;

    misc = {
      sdks = {
        enable = true;
        links = {
          inherit (pkgs) jdk17 jdk21;
        };
      };

      work = {
        enable = true;
        directory = "randstad/db";
        mailAddress = "tobias.happ@deutschebahn.com";
      };
    };

    wm.yabai.enable = true;
  };

  home = {
    homeDirectory = "/Users/tobiashapp";
    username = "tobiashapp";

    packages = with pkgs; [
      asciidoctor
      kubectl
      nixpkgs-fmt
      natscli
      nodejs
    ];
  };

  programs.zsh.initExtra = lib.mkAfter ''
    source <(kubectl completion zsh)
  '';
}
