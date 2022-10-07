{ config, lib, pkgs, rootPath, ... }:

with lib;

let
  cfg = config.custom.nixinate;
in

{

  ###### interface

  options = {

    custom.nixinate.enable = mkEnableOption "nixinate";

  };


  ###### implementation

  config = mkIf cfg.enable {

    _module.args.nixinate = {
      host = "nixinate.${config.custom.base.general.hostname}";
      sshUser = "tobias";
    };

    custom.services.openssh.enable = true;

    users.users.tobias.openssh.authorizedKeys.keyFiles = [
      (rootPath + "/files/keys/id_rsa.nixinate.pub")
    ];

  };

}
