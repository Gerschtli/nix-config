{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.coinbase-plans;

  appName = "coinbase-plans";
  port = 8080;
in

{

  ###### interface

  options = {

    custom.applications.coinbase-plans.enable = mkEnableOption appName;

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    services.nginx.virtualHosts."coinbase-plans.tobias-happ.de" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:${toString port}/";
    };

    # FIXME: wait for https://github.com/NixOS/nixpkgs/pull/115615 to be merged
    systemd.services.${"docker-" + appName} = {
      preStart = ''
        docker rm -f ${appName} || true
        cat "${config.lib.custom.path.secrets}/github-registry-token" | docker login https://docker.pkg.github.com -u Gerschtli --password-stdin
      '';

      serviceConfig = {
        StandardOutput = lib.mkForce "journal";
        StandardError = lib.mkForce "journal";
      };
    };

    virtualisation.oci-containers.containers.${appName} = {
     image = "docker.pkg.github.com/gerschtli/coinbase-plans/coinbase-plans:test";
     ports = [ "${toString port}:${toString port}" ];
     /* FIXME: wait for https://github.com/NixOS/nixpkgs/pull/115615 to be merged
     login = {
       username = "Gerschtli";
       passwordFile = "${config.lib.custom.path.secrets}/github-registry-token";
       registry = "https://docker.pkg.github.com";
     }; */
    };

  };
}
