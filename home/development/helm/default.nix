{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.development.helm;

  helm-upgrade = config.lib.custom.mkScript
    "helm-upgrade"
    ./helm-upgrade.sh
    (with pkgs; [ kubernetes-helm ])
    { };
in

{

  ###### interface

  options = {

    custom.development.helm.enable = mkEnableOption "helm aliases";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.shellAliases = {
      helm-int = "helm --kube-context integration --namespace integration";
      helm-stage = "helm --kube-context stage --namespace stage";
      helm-int-tobhap-cleanup = "helm-int uninstall $(helm-int list | grep '^tobhap-' | awk '{print $1}')";
    };

    home.packages = [
      pkgs.kubernetes-helm

      helm-upgrade

      (config.lib.custom.mkZshCompletion
        "helm-upgrade"
        ./helm-upgrade-completion.zsh
        { }
      )

      (config.lib.custom.mkScript
        "helm-upgrade-this"
        ./helm-upgrade-this.sh
        (with pkgs; [ git gnused helm-upgrade kubernetes-helm ])
        { }
      )

      (config.lib.custom.mkZshCompletion
        "helm-upgrade-this"
        ./helm-upgrade-this-completion.zsh
        { }
      )
    ];

  };

}
