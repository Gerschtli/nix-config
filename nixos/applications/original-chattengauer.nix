{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    ;

  cfg = config.custom.applications.original-chattengauer;

  location = "/var/lib/original-chattengauer/app";
  httpdPort = 8080;
  domain = "original-chattengauer.de";
in

{

  ###### interface

  options = {

    custom.applications.original-chattengauer.enable = mkEnableOption domain;

  };


  ###### implementation

  config = mkIf cfg.enable {

    containers.oc = {
      autoStart = true;
      bindMounts.${location} = {
        hostPath = location;
        isReadOnly = false;
      };

      config =
        let
          pkgs' = pkgs;
        in
        { pkgs, ... }:
        {
          nixpkgs.pkgs = pkgs';

          services.httpd = {
            enable = true;
            adminAddr = "tobias.happ@gmx.de";
            enablePHP = true;
            phpPackage = pkgs.php74;
            extraModules = [ "rewrite" ];

            virtualHosts.${domain} = {
              documentRoot = location;
              locations."/".index = "index.php";
              listen = [{ port = httpdPort; }];

              extraConfig = ''
                <Directory "${location}">
                  AllowOverride All
                </Directory>
              '';
            };
          };

          system = { inherit (config.system) stateVersion; };
        };
    };

    custom = {
      services = {
        backup.services.oc-uploads = {
          description = "Uploads of ${domain}";
          interval = "Tue *-*-* 03:00:00";

          directoryToBackup = "${location}/uploads";
        };

        mysql = {
          enable = true;
          backups = [ "original_chattengauer" ];
        };

        nginx.enable = true;
      };
    };

    security.acme.certs.${domain}.extraDomainNames = [ "www.${domain}" ];

    services = {
      mysql.package = mkForce pkgs.mysql57;

      nginx.virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "www.${domain}" ];
        locations."/".proxyPass = "http://127.0.0.1:${toString httpdPort}/";
      };
    };

  };

}
