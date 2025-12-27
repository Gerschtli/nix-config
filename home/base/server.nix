{ config, lib, pkgs, nixosConfig, ... }:

let
  inherit (lib)
    mkIf
    ;
in

{

  ###### interface

  options = { };


  ###### implementation

  config = mkIf (nixosConfig != null && nixosConfig.custom.base.server.enable) {

    # needed because of https://github.com/NixOS/nix/issues/8508
    nix.gc = mkIf (config.home.username != "root") {
      automatic = true;
      dates = "*-*-* 00:30:00";
      options = "--delete-older-than 14d";
    };

  };

}
