{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.helm;
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
    };

    home.packages = [
      pkgs.kubernetes-helm

      (config.lib.custom.mkScript
        "helm-upgrade"
        ./helm-upgrade.sh
        (with pkgs; [ kubernetes-helm ])
        { }
      )
    ];

  };

}
