{ config, lib, pkgs, rootPath, ... }:

with lib;

let
  cfg = config.custom.misc.homeage;

  buildSshConfig = name: {
    name = "ssh-config-${name}";
    source = "${rootPath}/secrets/ssh/${name}/config.age";
    copies = [ "${config.home.homeDirectory}/.ssh/config.d/${name}" ];
  };

  buildSshKey = module: name: [
    {
      name = "ssh-key-${name}";
      source = "${rootPath}/secrets/ssh/${module}/id-rsa-${name}.age";
      copies = [ "${config.home.homeDirectory}/.ssh/keys/id_rsa.${name}" ];
    }
    {
      name = "ssh-key-${name}-pub";
      source = "${rootPath}/secrets/ssh/${module}/id-rsa-${name}-pub.age";
      copies = [ "${config.home.homeDirectory}/.ssh/keys/id_rsa.${name}.pub" ];
    }
  ];
in

{

  ###### interface

  options = {

    custom.misc.homeage = {
      secrets = mkOption {
        type = types.listOf (types.enum [ "sedo" "ssh-nixinate" "ssh-private" "ssh-sedo" "ssh-vcs" ]);
        default = [ ];
        description = ''
          Secrets to install.
        '';
      };

      directory = mkOption {
        type = types.nullOr types.string;
        default = "${config.xdg.dataHome}/secrets";
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
      pkgs.agenix-cli
    ];

    homeage = {
      identityPaths = [
        "${config.home.homeDirectory}/.age/key.txt"
      ];

      installationType = "activation";
      mount = cfg.directory;

      file = listToAttrs (
        map
          (entry: nameValuePair entry.name (builtins.removeAttrs entry [ "name" ]))
          (flatten (
            (optional (elem "sedo" cfg.secrets) [
              {
                name = "sedo-aliases";
                source = "${rootPath}/secrets/M386/aliases.sh.age";
                copies = [ "${config.home.homeDirectory}/.aliases.sh" ];
              }
              {
                name = "sedo-settings";
                source = "${rootPath}/secrets/M386/settings.xml.age";
                copies = [ "${config.home.homeDirectory}/.m2/settings.xml" ];
              }
            ])
            ++ (optional (elem "ssh-nixinate" cfg.secrets) [
              (buildSshConfig "nixinate")
              (buildSshKey "nixinate" "nixinate")
            ])
            ++ (optional (elem "ssh-private" cfg.secrets) [
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
