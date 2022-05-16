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

    development.nix.home-manager.enable = true;

    misc = {
      homeage.secrets = [ "sedo" ];

      sdks = {
        enable = true;
        links = {
          inherit (pkgs) jdk8 jdk11 jdk15;
          jdk17 = pkgs.jdk17_headless;
        };
      };

      work = {
        enable = true;
        directory = "sedo";
        mailAddress = "tobias.happ@sedo.com";
      };
    };

    programs = {
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
    packages = with pkgs; [
      kubectl
      kubernetes-helm
      mariadb.client
      minikube
      nodejs # for ide integration
      php # for ide integration
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
