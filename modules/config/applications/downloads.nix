{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.downloads;
in

{

  ###### interface

  options = {

    custom.applications.downloads = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install downloads.tobias-happ.de.
        '';
      };

      location = mkOption {
        type = types.str;
        default = "/var/lib/downloads.tobias-happ.de";
        description = ''
          Directory for downloadable files.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    services.nginx.virtualHosts."downloads.tobias-happ.de" = {
      enableACME = true;
      forceSSL = true;
      root = cfg.location;

      extraConfig = ''
        error_page 403 /403.html;
        error_page 404 /404.html;
      '';

      locations = {
        "/403.html".alias = pkgs.writeText "403.html" "403 - Forbidden";

        "/404.html".alias = pkgs.writeText "404.html" "404 - Not Found";

        "/robots.txt".alias = pkgs.writeText "robots.txt" ''
          User-agent: *
          Disallow: /
        '';
      };
    };

    system.activationScripts.downloads = ''
      mkdir -p ${cfg.location}
      chown -R ${config.services.nginx.user}:${config.services.nginx.group} ${cfg.location}
    '';

  };

}
