{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.development.jbang;
in

{

  ###### interface

  options = {

    custom.development.jbang = {
      enable = mkEnableOption "jbang config";

      trustedSources = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "URL's matching one or more entries in the list below will be trusted to be runnable by jbang.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.initExtra = ''
      source <(jbang completion)
    '';

    home = {
      file.".jbang/trusted-sources.json".text = builtins.toJSON cfg.trustedSources;
      packages = [ pkgs.jbang ];
      sessionPath = [ "${config.home.homeDirectory}/.jbang/bin" ];
    };

  };

}
