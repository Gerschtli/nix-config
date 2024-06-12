{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.nix-index;
in

{

  ###### interface

  options = {

    custom.programs.nix-index.enable = mkEnableOption "nix-index";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.file.".cache/nix-index/files".source =
      inputs.nix-index-database.packages.${pkgs.system}.nix-index-database;

    programs.nix-index.enable = true;

  };

}
