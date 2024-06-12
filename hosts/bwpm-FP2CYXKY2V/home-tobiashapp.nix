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
        randstad.directory = "randstad";
        randstad-db.directory = "randstad/db";
      };
    };

    wm.yabai.enable = true;
  };

  home = {
    homeDirectory = "/Users/tobiashapp";
    username = "tobiashapp";

    sessionVariables.KUBECONFIG = "${config.home.homeDirectory}/.kube/ardks-iat-nzfcw.kubeconfig";

    file.".mob".text = ''
      MOB_TIMER_USER="Tobias"
      MOB_DONE_SQUASH="squash-wip"
    '';

    packages = with pkgs; [
      asciidoctor
      kubectl
      kubelogin-oidc
      k9s
      mob
      nixpkgs-fmt
      natscli
      nodejs
    ];
  };

  programs.zsh.initExtra = lib.mkAfter ''
    source <(kubectl completion zsh)
  '';
}
