{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.custom.programs.idea-ultimate;
in

{

  ###### interface

  options = {

    custom.programs.idea-ultimate = {
      enable = mkEnableOption "idea-ultimate";

      packages = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "List of packages that should be put on PATH for idea-ultimate.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      misc.sdks = {
        enable = true;
        links = mkMerge [
          { inherit (pkgs) jdk11 python3; }

          (mkIf config.custom.programs.go.enable {
            go-1-15 = pkgs.go;
          })
        ];
      };

      programs.idea-ultimate.packages = with pkgs; [
        # node
        nodejs

        # rust
        gcc

        # python
        pipenv
      ];
    };

    home.packages = [
      (config.lib.custom.wrapProgram {
        inherit (cfg) packages;
        name = "idea-ultimate";
        source = pkgs.jetbrains.idea-ultimate;
        path = "/bin/idea-ultimate";
      })

      pkgs.rustup # needs to be globally installed for ide integration
    ];

  };

}
