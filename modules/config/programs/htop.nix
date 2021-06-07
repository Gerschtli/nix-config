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

      settings = {
        account_guest_in_cpu_meter = true;
        cpu_count_from_zero = true;
        detailed_cpu_time = true;
        header_margin = false;
        hide_userland_threads = true;
        highlight_base_name = true;
        shadow_other_users = true;
        show_thread_names = true;
        tree_view = true;
        update_process_names = true;
      };
    };

  };

}
