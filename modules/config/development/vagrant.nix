{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.development.vagrant;
in

{

  ###### interface

  options = {

    custom.development.vagrant.enable = mkEnableOption "vagrant aliases";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.dynamicShellInit = [
      {
        condition = "available vagrant";

        shellAliases = {
          cdv = "cd vagrant";

          vauto = "vagrant rsync-auto";
          vdes = "vagrant destroy && rm -rf .vagrant";
          vhalt = "vagrant halt";
          vpro = "vagrant provision";
          vrel = "vagrant reload --provision";
          vssh = "vagrant ssh";
          vst = "vagrant status";
          vsync = "vagrant rsync";
          vup = "vagrant up --provision";

          cdvpro = "cdv && vpro && cd -";
        };
      }
    ];

  };

}
