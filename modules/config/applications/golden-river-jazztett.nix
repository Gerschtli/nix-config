{ config, lib, pkgs, ... } @ args:

with lib;

let
  inherit (builtins) listToAttrs;

  cfg = config.custom.applications.golden-river-jazztett;

  path = "httpd/golden-river-jazztett.de";
in

{

  ###### interface

  options = {

    custom.applications.golden-river-jazztett = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install goldenriverjazztett.de.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services = {
      httpd = {
        enable = true;
        virtualHosts = [
          {
            hostName = "goldenriverjazztett.de";
            serverAliases = [ "www.goldenriverjazztett.de" ];
            documentRoot = "/etc/${path}";
          }
        ];
      };
    };

    environment.etc = listToAttrs
      (map
        (file:
          let filePath = "${path}/${file}"; in
          nameValuePair
            filePath
            { source = ../../files + "/${filePath}"; }
        )
        ["index.html" "robots.txt"]
      );

  };

}
