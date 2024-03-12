{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkOption
    types
    ;

  workOpts = { name, config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        description = ''
          The name of the client. If undefined, the name of the attribute set
          will be used.
        '';
      };

      directory = mkOption {
        type = types.str;
        description = ''
          Directory in `~/projects` where git projects are saved.
        '';
      };
    };

    config = {
      name = mkDefault name;
    };
  };
in

{

  ###### interface

  options = {

    custom.misc.work = mkOption {
      type = types.attrsOf (types.submodule workOpts);
      default = { };
      description = ''
        Client configurations.
      '';
    };

  };


  ###### implementation

  config = { };

}
