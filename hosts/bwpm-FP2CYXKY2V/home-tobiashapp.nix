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
          inherit (pkgs) jdk21 python3;

          # python3 = pkgs.python3.withPackages (ps: with ps; with pkgs.python3Packages; [ jupyter ipython notebook ]);
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

      ssh.cleanKeysOnShellStartup = false;
    };

    wm.yabai.enable = true;
  };

  home = {
    homeDirectory = "/Users/tobiashapp";
    username = "tobiashapp";

    sessionVariables.KUBECONFIG = "${config.home.homeDirectory}/.kube/ardks-iat-nzfcw.kubeconfig:${config.home.homeDirectory}/.kube/ardks-iat-vtso-a-ff278.kubeconfig";

    file.".mob".text = ''
      MOB_TIMER_USER="Tobias"
      MOB_DONE_SQUASH="squash-wip"
    '';

    packages = with pkgs; [
      asciidoctor
      bat
      earthly
      fd
      go-task
      just
      k9s
      kubectl
      kubelogin-oidc
      kubernetes-helm
      kustomize
      mob
      natscli
      nixpkgs-fmt
      nodejs_22
      pnpm
      postgresql_15
      python3
    ];
  };

  programs.zsh.initContent = lib.mkAfter ''
    source <(kubectl completion zsh)
  '';
}
