{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.applications.vereinsmanager;

  domain = "vereinsmanager.tobias-happ.de";
  mediaDir = "/var/lib/vereinsmanager/media";
in

{

  ###### interface

  options = {

    custom.applications.vereinsmanager.enable = mkEnableOption "vereinsmanager";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;
    custom.programs.podman.enable = true;

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:3000/";
      locations."/media" = {
        root = mediaDir;
        try_files = "$uri =404";
      };
    };

    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers.vereinsmanager = {
      image = "ghcr.io/gerschtli/vereinsmanager:latest";
      dependsOn = "jaeger";
      environment = {
        PUBLIC_BASE_URL = "https://${domain}";
        DATABASE_PATH = "/data/db/app.sqlite";
        ORIGIN = "https://${domain}";
        OPTL_BASE_URL = "http://127.0.0.1:4318";

        VAPID_PRIVATE_KEY_FILE = "/run/secrets/vapid-private-key";
        PUBLIC_VAPID_KEY = "BHKTf6jq-b8HcW0GngJg24nZj3d13nRybXHgPi0g6125jlEyGMyy63C37vHPfytfoJMtSx8-N-T95tAqfW8n2Ss";
        CONTACT_EMAIL = "info@tobias-happ.de";

        SMTP_HOST = "smtps.udag.de";
        SMTP_PORT = "465";
        SMTP_SECURE = "1";
        SMTP_USERNAME_FILE = "/run/secrets/smtp-username";
        SMTP_PASSWORD_FILE = "/run/secrets/smtp-password";

        SENDER_EMAIL = "info@tobias-happ.de";
        SENDER_NAME = "Vereinsmanager";

        MEDIA_BACKEND = "filesystem";
        MEDIA_DIRECTORY = "/data/media";
        PUBLIC_MEDIA_URL = "/media";

        PUBLIC_GOOGLE_MAPS_API_KEY = "AIzaSyBiJ-RCoilD316Ma2VJv5urZchTHJ9twcU";
      };
    };

  };

}
