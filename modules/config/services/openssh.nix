{ config, dirs, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.openssh;

  tobiasKey = dirs.keys + "/id_rsa.tobias-login.pub";
in

{

  ###### interface

  options = {

    custom.services.openssh = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable openssh.
        '';
      };

      rootLogin = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable root login via pubkey.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.firewall.enable = true;

    services.openssh = {
      enable = true;
      permitRootLogin = mkIf (!cfg.rootLogin) "no";
      passwordAuthentication = false;
      extraConfig = "MaxAuthTries 3";
    };

    users.users = {
      root.openssh.authorizedKeys.keyFiles = mkIf cfg.rootLogin [
        tobiasKey
      ];

      tobias.openssh.authorizedKeys.keyFiles = [
        tobiasKey
      ];
    };

  };

}
