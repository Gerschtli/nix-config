{ config, lib, pkgs, ... }:

{
  custom = {
    base = {
      desktop = {
        enable = true;
        laptop = true;
      };

      non-nixos.enable = true;
    };

    development = {
      helm.enable = true;

      nix.home-manager.enable = true;
    };

    misc = {
      homeage.secrets = [ "sedo" ];

      sdks = {
        enable = true;
        links = {
          inherit (pkgs) jdk8 jdk11 jdk17 go;
        };
      };

      work = {
        enable = true;
        directory = "sedo";
        mailAddress = "tobias.happ@sedo.com";
      };
    };

    programs = {
      go.enable = true;

      idea-ultimate.enable = lib.mkForce false;

      maven.enable = true;

      shell.initExtra = ''
        . ${config.home.homeDirectory}/.aliases.sh
      '';

      ssh.modules = [ "sedo" ];

      watson.enable = true;
    };
  };

  home = {
    homeDirectory = "/home/tobhap";
    username = "tobhap";

    packages = with pkgs; [
      dbeaver
      gitflow
      k9s
      kubectl
      mariadb.client
      minikube
      nixpkgs-fmt # for vscode integration
      nodejs # for ide integration
      php # for ide integration
    ];

    sessionPath = [
      "${config.home.homeDirectory}/projects/sedo/devops-scripts/bin"
    ];

    sessionVariables = {
      # see: https://github.com/NixOS/nixpkgs/issues/38991#issuecomment-400657551
      LOCALE_ARCHIVE_2_11 = "/usr/bin/locale/locale-archive";
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";

      KUBECONFIG = lib.concatMapStringsSep ":" (path: "${config.home.homeDirectory}/.kube/${path}") [
        "config"
        "config.integration"
        "config.integration2"
        "config.stage"
        "config.production"
      ];
    };
  };
}
