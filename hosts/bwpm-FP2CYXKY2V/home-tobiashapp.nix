{ config, lib, pkgs, ... }:

{
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

          python3 = pkgs.python3.withPackages (ps: with ps; with pkgs.python3Packages; [ jupyter ipython notebook ]);
        };
      };

      work = {
        randstad.directory = "randstad";
        randstad-db.directory = "randstad/db";
      };
    };

    programs = {
      go.enable = true;

      gradle.enable = true;
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
      earthly
      go-task
      k9s
      kubectl
      kubelogin-oidc
      mob
      natscli
      nixpkgs-fmt
      nodejs
      pnpm
      python3
    ];
  };

  programs.zsh.initExtra = lib.mkAfter ''
    source <(kubectl completion zsh)
  '';
}
