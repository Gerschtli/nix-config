{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.httpd;
in

{

  ###### interface

  options = {

    custom.services.httpd = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install and configure httpd.
        '';
      };

      virtualHosts = mkOption {
        type = types.listOf (
          types.submodule (
            {
              options = {

                hostName = mkOption {
                  type = types.str;
                  description = "Canonical hostname for the server.";
                };

                serverAliases = mkOption {
                  type = types.listOf types.str;
                  default = [];
                  description = ''
                    Additional names of virtual hosts served by this virtual
                    host configuration.
                  '';
                };

                documentRoot = mkOption {
                  type = types.path;
                  description = ''
                    The path of Apache's document root directory.
                  '';
                };

                php = mkOption {
                  type = types.bool;
                  default = false;
                  description = ''
                    Whether to add php specific settins in extra config.
                  '';
                };

              };
            }
          )
        );
        default = [];
        description = ''
          List of virtualHosts.
        '';
      };


    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services.httpd = {
      enable = true;
      logPerVirtualHost = true;
      adminAddr = "tobias.happ@gmx.de";
      enablePHP = any (host: host.php) cfg.virtualHosts;
      maxClients = 4;
      virtualHosts = flip map cfg.virtualHosts (
        host:
        {
          inherit (host) hostName serverAliases documentRoot;

          extraConfig = mkIf host.php ''
            <Directory ${host.documentRoot}>
              Options -Indexes
              DirectoryIndex index.php
              AllowOverride All
            </Directory>
          '';
        }
      );
    };

  };

}
