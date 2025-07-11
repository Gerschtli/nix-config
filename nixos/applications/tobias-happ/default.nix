{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.applications.tobias-happ;

  website = pkgs.runCommand "tobias-happ.de" { } ''
    install -D -m 0400 ${./index.html} $out/index.html
    install -D -m 0400 ${./robots.txt} $out/robots.txt
  '';
in

{

  ###### interface

  options = {

    custom.applications.tobias-happ.enable = mkEnableOption "tobias-happ.de";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    services.nginx.virtualHosts = {
      "tobias-happ.de" = {
        root = website;
        enableACME = true;
        forceSSL = true;
        extraConfig = "error_page 404 @notfound;";
        locations = {
          "/".index = "index.html";
          "@notfound".extraConfig = "return 302 /;";
        };
      };

      "*.tobias-happ.de".extraConfig = "return 302 https://tobias-happ.de/;";
    };

  };

}
