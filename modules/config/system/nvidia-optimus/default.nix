{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.nvidia-optimus;
in

{

  ###### interface

  options = {

    custom.system.nvidia-optimus = {

      enable = mkEnableOption "nvidia optimus";

      enableOffload = mkEnableOption "offload per default";

      amdgpuBusId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Bus ID of the AMD GPU.
        '';
      };

      nvidiaBusId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Bus ID of the NVIDIA GPU.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.enable -> cfg.amdgpuBusId != null && cfg.nvidiaBusId != null;
        message = "You need to configure bus ID options if you enable the module.";
      }
    ];

    environment.systemPackages = [
      (config.lib.custom.mkScript
        "nvidia-offload"
        ./nvidia-offload.sh
        [ ]
        { _doNotClearPath = true; }
      )
    ];

    hardware.nvidia.prime = {
      inherit (cfg) amdgpuBusId nvidiaBusId;
      offload.enable = cfg.enableOffload;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    specialisation = mapAttrs
      (name: option: {
        configuration = {
          hardware.nvidia.prime.offload.enable = lib.mkForce option;

          system.nixos.tags = [ name ];
        };
      })
      {
        external-display = false;
        offload = true;
      };

  };

}
