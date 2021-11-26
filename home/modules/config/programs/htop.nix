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
        color_scheme = 0;
        cpu_count_from_zero = true;
        delay = 15;
        detailed_cpu_time = true;
        enable_mouse = true;
        fields = with config.lib.htop.fields; [
          PID
          USER
          PRIORITY
          NICE
          M_SIZE
          M_RESIDENT
          M_SHARE
          STATE
          PERCENT_CPU
          PERCENT_MEM
          TIME
          COMM
        ];
        header_margin = false;
        hide_kernel_threads = true;
        hide_threads = false;
        hide_userland_threads = true;
        highlight_base_name = true;
        highlight_megabytes = true;
        highlight_threads = true;
        shadow_other_users = true;
        show_cpu_frequency = false;
        show_cpu_usage = false;
        show_program_path = true;
        show_thread_names = true;
        sort_direction = 1;
        sort_key = config.lib.htop.fields.PERCENT_CPU;
        tree_view = true;
        update_process_names = true;
        vim_mode = false;
      } // (with config.lib.htop; leftMeters [
        (bar "AllCPUs")
        (bar "Memory")
        (bar "Swap")
      ]) // (with config.lib.htop; rightMeters [
        (text "Tasks")
        (text "LoadAverage")
        (text "Uptime")
      ]);
    };

  };

}
