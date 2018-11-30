{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.openssh;
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

      forwardX11 = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable x11 forwarding.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.openssh = {
      inherit (cfg) forwardX11;
      enable = true;
      openFirewall = true;
      permitRootLogin = mkIf (!cfg.rootLogin) "no";
      passwordAuthentication = false;
      extraConfig = "MaxAuthTries 3";
    };

    users.users = {
      root.openssh.authorizedKeys.keyFiles = mkIf cfg.rootLogin [
        ../../../files/keys/id_rsa.tobias-login.pub
      ];

      tobias.openssh.authorizedKeys.keyFiles = [
        ../../../files/keys/id_rsa.tobias-login.pub
      ];
    };

  };

}
