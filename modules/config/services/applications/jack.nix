{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.jack;
in

{

  ###### interface

  options = {

    custom.applications.jack = {
      enable = mkEnableOption "jack";

      enableService = mkEnableOption "jack" // { default = cfg.enable; };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    /*
    boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
    hardware.pulseaudio.package = pkgs.pulseaudio.override { jackaudioSupport = true; };

    systemd.user.services.pulseaudio.environment = {
      JACK_PROMISCUOUS_SERVER = "jackaudio";
    };

    services.jack = {
      jackd.enable = true;
      # support ALSA only programs via ALSA JACK PCM plugin
      alsa.enable = false;
      # support ALSA only programs via loopback device (supports programs like Steam)
      loopback = {
        enable = true;
        # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
        #dmixConfig = ''
        #  period_size 2048
        #'';
      };
    };
    */

    services.jack.jackd = {
      enable = cfg.enableService;

      extraOptions = [
        "--realtime"
        "-dalsa"
        "--device" "hw:1"
      ];
    };

    users = {
      # groups.jackaudio = {};

      users.tobias = {
        extraGroups = [ "audio" "jackaudio" ];
        packages = with pkgs; [
          cadence jamulus qjackctl
        ];
      };
    };

  };

}
