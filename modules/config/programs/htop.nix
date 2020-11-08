{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.htop;
in

{

  ###### interface

  options = {

    custom.programs.htop.enable = mkEnableOption "htop config";

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
