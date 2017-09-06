{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.server;
in

{

  ###### interface

  options = {

    custom.server = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable basic desktop config with dwm.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      boot.isEFI = false;

      general.enable = true;
    };

    networking.firewall.enable = true;

    services = {
      fail2ban.enable = true;

      openssh = {
        enable = true;
        permitRootLogin = "yes";
        passwordAuthentication = false;
        extraConfig = ''
          MaxAuthTries 3
        '';
      };
    };

    users.users.tobias.openssh.authorizedKeys.keyFiles = [
      ../keys/id_rsa.tobias-login.pub
    ];

  };

}
