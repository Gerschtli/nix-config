{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

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
      helm-stage = "helm --kube-context stage --namespace stage";
      helm-int-tobhap-cleanup = "helm-int uninstall $(helm-int list --filter '^tobhap-' --short)";
    };

    home.packages = [
      pkgs.kubernetes-helm
    ];

  };

}
