{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.vagrant;
in

{

  ###### interface

  options = {

    custom.vagrant.enable = mkEnableOption "vagrant aliases";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.shell.initExtra = ''
      if available vagrant; then
        alias cdv="cd vagrant"

        alias vauto="vagrant rsync-auto"
        alias vdes="vagrant destroy && rm -rf .vagrant"
        alias vhalt="vagrant halt"
        alias vpro="vagrant provision"
        alias vrel="vagrant reload --provision"
        alias vssh="vagrant ssh"
        alias vst="vagrant status"
        alias vsync="vagrant rsync"
        alias vup="vagrant up --provision"

        alias cdvpro="cdv && vpro && cd -"
      fi
    '';

  };

}
