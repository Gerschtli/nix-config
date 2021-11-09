{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.misc.homeage;

  buildSshConfig = name: {
    path = "ssh-config-${name}";
    source = config.lib.custom.path.modules + "/../secrets/ssh-config-${name}.age";
    cpOnService = [ "${config.home.homeDirectory}/.ssh/config.d/${name}" ];
  };

  buildSshKey = name: [
    {
      path = "ssh-key-${name}";
      source = config.lib.custom.path.modules + "/../secrets/ssh-key-${name}.age";
      cpOnService = [ "${config.home.homeDirectory}/.ssh/keys/id_rsa.${name}" ];
    }
    {
      path = "ssh-key-${name}-pub";
      source = config.lib.custom.path.modules + "/../secrets/ssh-key-${name}-pub.age";
      cpOnService = [ "${config.home.homeDirectory}/.ssh/keys/id_rsa.${name}.pub" ];
    }
  ];
in

{

  imports = [ <homeage/module> ];


  ###### interface

  options = {

    custom.misc.homeage.secrets = mkOption {
      type = types.listOf (types.enum [ "ssh-private" "ssh-vcs" ]);
      default = [ ];
      description = ''
        Secrets to install.
      '';
    };

  };


  ###### implementation

  config = {

    home.packages = [
      (import <agenix-cli>).default
    ];

    homeage = {
      identityPaths = [ "${config.home.homeDirectory}/.ssh-age/id_rsa.age" ];

      file = builtins.listToAttrs (
        map
          (entry: nameValuePair entry.path entry)
          (flatten (
            (optional (elem "ssh-private" cfg.secrets) [
              (buildSshConfig "private")
              (buildSshKey "private")
              (buildSshKey "strato")
            ])
            ++ (optional (elem "ssh-vcs" cfg.secrets) [
              (buildSshConfig "vcs")
              (buildSshKey "vcs")
            ])
          ))
      );
    };

  };

}
