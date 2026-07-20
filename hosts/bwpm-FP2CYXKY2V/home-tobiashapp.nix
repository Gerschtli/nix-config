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
          inherit (pkgs) go python3;

          jdk21 = pkgs.javaPackages.compiler.openjdk21;
          jdk25 = pkgs.javaPackages.compiler.openjdk25;
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

    sessionVariables.KUBECONFIG = "${config.home.homeDirectory}/.kube/ardks-iat-nzfcw.kubeconfig:${config.home.homeDirectory}/.kube/ardks-iat-staging-zmft9.kubeconfig";

    file.".mob".text = ''
      MOB_TIMER_USER="Tobias"
      MOB_DONE_SQUASH="squash-wip"
    '';

    packages = with pkgs; [
      asciidoctor
      bat
      earthly
      fd
      glab
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
      sem
      uv
    ];
  };

  #programs.git.settings.diff.external = toString (
  #  config.lib.custom.mkScriptPlain
  #    "sem-git-diff"
  #    ./sem-git-diff.sh
  #    [ pkgs.sem ]
  #    { }
  #);

  programs.zsh.initContent = lib.mkAfter ''
    source <(docker completion zsh)
    source <(kubectl completion zsh)
  '';
}
