{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.downloads;

  location = "/var/lib/downloads.tobias-happ.de";
in

{

  ###### interface

  options = {

    custom.applications.downloads.enable = mkEnableOption "downloads.tobias-happ.de";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    services.nginx.virtualHosts."downloads.tobias-happ.de" = {
      enableACME = true;
      forceSSL = true;
      root = location;

      extraConfig = ''
        autoindex on;
        disable_symlinks off;

        error_page 403 /403.html;
        error_page 404 /404.html;
      '';

      locations = {
        "= /403.html".alias = pkgs.writeText "403.html" "403 - Forbidden";

        "= /404.html".alias = pkgs.writeText "404.html" "404 - Not Found";

        "= /robots.txt".alias = pkgs.writeText "robots.txt" ''
          User-agent: *
          Disallow: /
        '';
      };
    };

    system.activationScripts.downloads = ''
      mkdir -p ${location}
    '';

  };

}
