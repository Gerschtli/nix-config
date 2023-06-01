{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.openssh;
in

{

  ###### interface

  options = {

    custom.services.openssh = {
      enable = mkEnableOption "openssh";

      rootLogin = mkEnableOption "root login via pubkey";

      forwardX11 = mkEnableOption "x11 forwarding";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.openssh = {
      enable = true;
      openFirewall = true;

      settings = {
        MaxAuthTries = 3;
        PasswordAuthentication = false;
        PermitRootLogin = mkIf (!cfg.rootLogin) "no";
        X11Forwarding = cfg.forwardX11;
      };
    };

    users.users = {
      root.openssh.authorizedKeys.keyFiles = mkIf cfg.rootLogin [
        "${rootPath}/files/keys/id_rsa.tobias.pub"
      ];

      tobias.openssh.authorizedKeys.keyFiles = [
        "${rootPath}/files/keys/id_rsa.tobias.pub"
      ];
    };

  };

}
