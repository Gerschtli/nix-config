{ config, lib, pkgs, rootPath, ... }:

with lib;

let
  cfg = config.custom.misc.homeage;

  buildSshConfig = name: {
    path = "ssh-config-${name}";
    source = rootPath + "/secrets/ssh/${name}/config.age";
    cpOnService = [ "${config.home.homeDirectory}/.ssh/config.d/${name}" ];
  };

  buildSshKey = module: name: [
    {
      path = "ssh-key-${name}";
      source = rootPath + "/secrets/ssh/${module}/id-rsa-${name}.age";
      cpOnService = [ "${config.home.homeDirectory}/.ssh/keys/id_rsa.${name}" ];
    }
    {
      path = "ssh-key-${name}-pub";
      source = rootPath + "/secrets/ssh/${module}/id-rsa-${name}-pub.age";
      cpOnService = [ "${config.home.homeDirectory}/.ssh/keys/id_rsa.${name}.pub" ];
    }
  ];
in

{

  ###### interface

  options = {

    custom.misc.homeage = {
      secrets = mkOption {
        type = types.listOf (types.enum [ "ssh-private" "ssh-sedo" "ssh-vcs" ]);
        default = [ ];
        description = ''
          Secrets to install.
        '';
      };

      directory = mkOption {
        type = types.nullOr types.string;
        default = null;
        description = ''
          Directory to save secrets in. See <literal>homeage.mount</literal>.
        '';
      };
    };

  };


  ###### implementation

  config = {

    home.packages = [
      pkgs.age
      pkgs.agenix
    ];

    homeage = {
      identityPaths = [
        "${config.home.homeDirectory}/.age/key.txt"
      ];

      installationType = "activation";
      mount = mkIf (cfg.directory != null) cfg.directory;

      file = builtins.listToAttrs (
        map
          (entry: nameValuePair entry.path entry)
          (flatten (
            (optional (elem "ssh-private" cfg.secrets) [
              (buildSshConfig "private")
              (buildSshKey "private" "private")
              (buildSshKey "private" "strato")
            ])
            ++ (optional (elem "ssh-sedo" cfg.secrets) [
              (buildSshConfig "sedo")
              (buildSshKey "sedo" "sedo")
            ])
            ++ (optional (elem "ssh-vcs" cfg.secrets) [
              (buildSshConfig "vcs")
              (buildSshKey "vcs" "vcs")
            ])
          ))
      );
    };

  };

}
