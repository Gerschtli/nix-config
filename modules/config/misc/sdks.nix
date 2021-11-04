{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.misc.sdks;

  sdksDirectory = "${config.home.homeDirectory}/.sdks";
in

{

  ###### interface

  options = {

    custom.misc.sdks = {
      enable = mkEnableOption "sdk links";

      links = mkOption {
        type = types.attrs;
        default = {};
        example = { "link-name" = pkgs.python3; };
        description = ''
          Links to generate in <literal>~/.sdks</literal> directory.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.file = mapAttrs'
      (name: package: nameValuePair "${sdksDirectory}/${name}" { source = package; })
      cfg.links;

  };

}
