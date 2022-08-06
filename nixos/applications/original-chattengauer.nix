{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.original-chattengauer;

  location = "/var/lib/original-chattengauer/app";
in

{

  ###### interface

  options = {

    custom.applications.original-chattengauer.enable = mkEnableOption "original-chattengauer.de";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services = {
      backup.services.oc-uploads = {
        description = "Uploads of original_chattengauer.de";
        interval = "Tue *-*-* 03:00:00";
        expiresAfter = 28;

        script = ''
          ${pkgs.gnutar}/bin/tar --xz -cpf oc-uploads-$(date +%s).tar.xz -C ${location} uploads
        '';

        extraOptions = {
          path = [ pkgs.xz ];
        };
      };

      httpd.enable = true;

      mysql = {
        enable = true;
        backups = [ "original_chattengauer" ];
      };
    };

    services = {
      httpd = {
        enablePHP = true;
        phpPackage = pkgs.php74;
        extraModules = [ "rewrite" ];

        virtualHosts."original-chattengauer.de" = {
          #enableACME = true;
          #forceSSL = true;
          documentRoot = location;
          locations."/".index = "index.php";

          extraConfig = ''
            <Directory "${location}">
              AllowOverride All
            </Directory>
          '';
        };
      };

      mysql.package = mkForce pkgs.mysql57;
    };

  };

}
