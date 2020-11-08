{ config, lib, pkgs, ... }:

with lib;

let
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
      inherit (cfg) forwardX11;
      enable = true;
      openFirewall = true;
      permitRootLogin = mkIf (!cfg.rootLogin) "no";
      passwordAuthentication = false;
      extraConfig = "MaxAuthTries 3";
    };

    users.users = {
      root.openssh.authorizedKeys.keyFiles = mkIf cfg.rootLogin [
        (config.lib.custom.path.files + "/keys/id_rsa.tobias.pub")
      ];

      tobias.openssh.authorizedKeys.keyFiles = [
        (config.lib.custom.path.files + "/keys/id_rsa.tobias.pub")
      ];
    };

  };

}
