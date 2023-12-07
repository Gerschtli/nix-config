{ config, lib, pkgs, inputs, rootPath, ... }:

let
  inherit (builtins)
    removeAttrs
    ;
  inherit (lib)
    elem
    flatten
    listToAttrs
    mkOption
    nameValuePair
    optional
    types
    ;

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

  imports = [ inputs.homeage.homeManagerModules.homeage ];


  ###### interface

  options = {

    custom.misc.homeage = {
      secrets = mkOption {
        type = types.listOf (types.enum [ "ssh-private" "ssh-vcs" ]);
        default = [ ];
        description = ''
          Secrets to install.
        '';
      };

      directory = mkOption {
        type = types.nullOr types.str;
        default = "${config.xdg.dataHome}/secrets";
        description = ''
          Directory to save secrets in. See `homeage.mount`.
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
          (entry: nameValuePair entry.name (removeAttrs entry [ "name" ]))
          (flatten (
            (optional (elem "ssh-private" cfg.secrets) [
              (buildSshConfig "private")
              (buildSshKey "private" "private")
              (buildSshKey "private" "strato")
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
