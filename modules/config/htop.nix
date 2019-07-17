{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.htop;
in

{

  ###### interface

  options = {

    custom.htop.enable = mkEnableOption "htop config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs.htop = {
      enable = true;

      hideUserlandThreads    = true;
      shadowOtherUsers       = true;
      showThreadNames        = true;
      highlightBaseName      = true;
      treeView               = true;
      headerMargin           = false;
      detailedCpuTime        = true;
      cpuCountFromZero       = true;
      updateProcessNames     = true;
      accountGuestInCpuMeter = true;
    };

  };

}
