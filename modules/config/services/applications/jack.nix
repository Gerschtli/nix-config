{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.jack;
in

{

  ###### interface

  options = {

    custom.applications.jack = {
      enable = mkEnableOption "jack";

      enableService = mkEnableOption "jack" // { default = cfg.enable; };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.jack.jackd = {
      enable = cfg.enableService;

      extraOptions = [
        "--realtime"
        "-dalsa"
        "--device" "hw:1"
      ];
    };

    users = {
      groups.jackaudio = {};

      users.tobias = {
        extraGroups = [ "jackaudio" ];
        packages = with pkgs; [
          jamulus qjackctl
        ];
      };
    };

  };

}
