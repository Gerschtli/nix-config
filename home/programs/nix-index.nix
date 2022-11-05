{ config, lib, pkgs, inputs, ... }:

with lib;

let
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
      inputs.nix-index-database.legacyPackages.${pkgs.system}.database;

    programs.nix-index.enable = true;

  };

}
